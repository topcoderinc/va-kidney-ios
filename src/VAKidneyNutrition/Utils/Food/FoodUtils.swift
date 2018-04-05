//
//  FoodUtils.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON
import HealthKit

/**
 * The utility that isolates the logic for making recommendations
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API usage added
 * - Issue fixed: water was not added
 */
class FoodUtils {

    /// the singleton
    static let shared = FoodUtils()

    /// the solver used to generate recommendations
    private var solver: RecommendationSolver = SimpleRecommendationSolver()

    /// the generator used to generate reports based on RecommendationSolutions
    private var reportGenerator: RecommendationGenerator = NDBBasedRecommendationGenerator()

    /// the storage
    private var storage: QuantitySampleService = QuantitySampleStorage.shared

    /// the references to API
    private let recommendationApi: RecommendationServiceApi = CachingServiceApi.shared
    private let serviceApi: ServiceApi = CachingServiceApi.shared
    private let foodDetailsApi: FoodDetailsServiceApi = CachingNDBServiceApi.sharedWrapper
    private let drugDetailsApi: DrugDetailsServiceApi = CachingFDAServiceApi.shared

    /// Shortcut method for making all updates in the app after taking food
    ///
    /// - Parameter food: the food
    func process(food: Food) {
        // Update recommendations if needed
        DispatchQueue.global(qos: .background).async {
            FoodUtils.shared.checkRecommendations(food: food, callback: { (info) in

                // Update nutritions
                DispatchQueue.global(qos: .background).async {
                    FoodUtils.shared.updateNutritions(food: food, info: info) {

                        // Update goals
                        // Delay added because HealthKit does not provide updated statistic immidiately after new samples are added
                        delay(1) {
                            FoodUtils.shared.updateGoals {
                                print("FoodUtils.process: DONE")
                            }
                        }
                    }
                }
            })
        }
    }

    /// Check recommendations after taking given food
    ///
    /// - Parameters:
    ///   - food: the food
    ///   - callback: the callback used to return NDB info (will be used to update goals
    func checkRecommendations(food: Food, callback: @escaping ([FoodItem: [NDBNutrient]])->()) {
        // currently check all, but can be optimized in future
        checkRecommendationsForAll(callback: callback)
    }

    /// Top most method for validating taken food and generating/removing recommendations
    ///
    /// - Parameter callback: the callback used to return NDB info (will be used to update goals
    func checkRecommendationsForAll(callback: @escaping ([FoodItem: [NDBNutrient]])->()) {
        getNutritionGoals { goals in
            guard !goals.isEmpty else { return }
            self.getFoods() { foods in

                // Get details about Food
                self.getNDBInfo(foods: foods, callback: { (info) in
                    callback(info)
                    guard !goals.isEmpty else { return }

                    var allRecommendations = [Recommendation]()

                    let g = DispatchGroup()
                    // For each Goal
                    for goal in goals {

                        // Check if user eats bad food for this goal
                        let solution = self.solver.checkGoal(goal: goal, info: info)
                        switch solution {
                        case .none:
                            break
                        default:
                            print("checkRecommendations: solution: \(solution) for goal: \(goal.title)")
                            g.enter()
                            self.reportGenerator.genedateRecommendation(goal: goal, solution: solution, callback: { (list) in
                                allRecommendations.append(contentsOf: list)
                                g.leave()
                            })
                        }
                    }

                    g.notify(queue: DispatchQueue.main, execute: {
                        // Replace all previous food recommendations
                        self.recommendationApi.replaceRecommendations(allRecommendations, ofType: .foodSuggestion, callback: {
                            print("checkRecommendations: reports saved: \(allRecommendations)")
                        }, failure: { (error) in
                            print("ERROR: \(error)")
                        })
                    })

                })

                guard !goals.isEmpty else { return }
                // Get drug interactions
                var allDrugRecommendations = [Recommendation]()
                let g = DispatchGroup()
                for food in foods {
                    let drugs = food.items.filter({$0.type == .drug})
                    if !drugs.isEmpty {
                        g.enter()
                        self.drugDetailsApi.searchDrugInteractions(foodItems: drugs, callback: { (json) in
                            if let report = self.createDrugInteractionReport(drugs: drugs, json: json) {
                                allDrugRecommendations.append(report)
                            }
                            g.leave()
                        }, failure: { (error) in
                            print("ERROR: \(error)")
                            g.leave()
                        })
                    }
                }
                g.notify(queue: DispatchQueue.main, execute: {
                    // Replace all previous drug recommendations
                    self.recommendationApi.replaceRecommendations(allDrugRecommendations, ofType: .drugInteractionWarnings, callback: {
                        print("checkRecommendations: reports saved: \(allDrugRecommendations)")
                    }, failure: { (error) in
                        print("ERROR: \(error)")
                    })
                })
            }
        }
    }

    /// Create interaction report
    ///
    /// - Parameters:
    ///   - drugs: the drugs
    ///   - json: the response
    private func createDrugInteractionReport(drugs: [FoodItem], json: JSON) -> Recommendation? {
        if let _ = json["results"].arrayValue.first {
            // Generate text based on `drug` and `reactions `fields`.
            return Recommendation.drugInteractionReport(json, drugs: drugs)
        }
        return nil
    }

    /// Update taken nutritions
    ///
    /// - Parameters:
    ///   - food: the food
    ///   - info: the info 
    func updateNutritions(food: Food, info: [FoodItem: [NDBNutrient]], callback: @escaping ()->()) {
        var infoMap = [String: [NDBNutrient]]()
        for (k,v) in info {
            infoMap[k.title] = v
        }
        /// Add each food item
        let g = DispatchGroup()
        for item in food.items {
            let amount: Double = food.extraAddedItems[item] ?? Double(item.amount) // added amount in relation to whole food item amount. Can be negative
            if amount > 0 {

                /*
                 NDB returns a lot of ingridients for liquids. We save them as `gramms` and additionally add the same mound of water nutrition.
                 */
                let isLiquid = item.units == HKUnit.liter().unitString // if units == 'L' (liter)

                // for each nutrition
                for nutrition in infoMap[item.title] ?? [] {

                    if nutrition.percent > 0 { // add only if >0
                        let nutritionAmount = amount * nutrition.percent
                        if let unit = HealthKitUtil.shared.getUnit(byString: nutrition.unit),
                            let id = HealthKitUtil.shared.getId(byString: nutrition.title) {
                            let sample = QuantitySample.create(type: QuantityType.fromId(id.rawValue), amount: nutritionAmount, unit: unit.unitString)
                            g.enter()
                            storage.addSample(sample, callback: { _ in g.leave() })
                        }
                        else {
                            print("ERROR: Incorrect unit \(nutrition.unit) or nutrition ID \(nutrition.title)")
                        }
                    }
                }
                if isLiquid {
                    let unit = HKUnit.liter()
                    let id = HKQuantityTypeIdentifier.dietaryWater
                    let sample = QuantitySample.create(type: QuantityType.fromId(id.rawValue), amount: amount, unit: unit.unitString)
                    g.enter()
                    storage.addSample(sample, callback: { _ in g.leave()})
                }
            }
        }
        g.notify(queue: .main, execute: {
            callback()
        })
    }

    /// Update goals
    func updateGoals(callback: ()->()) {
        getNutritionGoals { (goals) in
            var goalsToSave = [Goal]()
            let g = DispatchGroup()
            for goal in goals {
                if let quantityTypeId = goal.relatedQuantityId {
                    g.enter()
                    let quantityType = QuantityType.fromId(quantityTypeId)
                    self.storage.getTodayStatistics(quantityType, callback: { (quantity) in
                        let value = quantity.doubleValue(for: HealthKitUtil.shared.getUnit(forType: quantityType))
                        goal.value = Float(value)
                        goalsToSave.append(goal)
                        g.leave()
                    }, customTypeCallback: { g.leave() })
                }
            }
            g.notify(queue: DispatchQueue.main, execute: {
                self.serviceApi.saveGoals(goals: goalsToSave, callback: { (_) in
                    print("updateGoals: goals updated")
                }, failure: { (error) in
                    print("ERROR: \(error)")
                })
            })
        }
    }

    // MARK: - Private

    /// Get all goals to validate. Filers and includes only goals that can be validated, e.g. "Distance" goal cannot be verified agains taken good (at least with the simple verification like being in the given thresholds)
    ///
    /// - Parameter callback: the callback to return data
    func getNutritionGoals(callback: @escaping ([Goal])->()) {
        serviceApi.getGoals(profile: nil, callback: { (goals) in
            callback(goals.filter({
                $0.getRelatedNutrition() != nil // is related to nutrition
            })) // include only goals with specific level of required nutritions (most of "Pills" styled goals)
        }, failure: createFailureCallback())
    }

    /// Get all iten food to validate.
    ///
    /// - Parameter callback: the callback to return data
    private func getFoods(callback: @escaping ([Food])->()) {
        serviceApi.getFood(callback: callback, failure: createFailureCallback())
    }

    /// Get info for all food
    ///
    /// - Parameter foods: the foods
    private func getNDBInfo(foods: [Food], callback: @escaping ([FoodItem: [NDBNutrient]])->()) {
        var info = [FoodItem: [NDBNutrient]]()
        let g = DispatchGroup()
        // For each Food (today)
        for food in foods {
            for item in food.items.filter({$0.type == .food}) {
                g.enter()
                // find information in NDB
                self.foodDetailsApi.searchFoodItem(foodItem: item, callback: { (nutrients) in
                    if let nutrients = nutrients {
                        info[item] = nutrients
                    }
                    g.leave()
                }, failure: { (error) in
                    g.leave()
                    print("ERROR: \(error)")
                })
            }
        }
        g.notify(queue: DispatchQueue.main, execute: {
            print("getNDBInfo: \(info.count) info objects")
            callback(info)
        })
    }

    /// Create FailureCallback
    ///
    /// - Returns: FailureCallback
    private func createFailureCallback() -> FailureCallback {
        return { error in
            showError(errorMessage: error)
        }
    }
}
