//
//  FoodUtils.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON
import HealthKit

/**
 * The utility that isolates the logic for making recommendations
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodUtils {

    /// the singleton
    static let shared = FoodUtils()

    /// the solver used to generate recommendations
    private var solver: RecommendationSolver = SimpleRecommendationSolver()

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
                        DispatchQueue.global(qos: .background).async {
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

                    // Remove all previous recommendations
                    CachingServiceApi.shared.medicationResourceService.removeAllFoodResources(callback: {

                        // For each Goal
                        for goal in goals {

                            // Check if user eats bad food for this goal
                            let solution = self.solver.checkGoal(goal: goal, info: info)
                            switch solution {
                            case .none:
                                break
                            default:
                                print("checkRecommendations: solution: \(solution) for goal: \(goal.title)")
                                if let report = self.solver.genedateRecommendation(goal: goal, solution: solution) {
                                    CachingServiceApi.shared.saveMedicationResource(report, callback: { (_) in
                                        print("checkRecommendations: report saved: \(report)")
                                    }, failure: { (error) in
                                        print("ERROR: \(error)")
                                    })
                                }
                            }
                        }

                    }, failure: { (error) in
                        print("ERROR: \(error)")
                    })

                    callback(info)
                })

                // Remove all previous reports
                CachingServiceApi.shared.medicationResourceService.removeAllDrugResources(callback: {
                    // Get drug interactions
                    for food in foods {
                        let drugs = food.items.filter({$0.type == .drug})
                        if !drugs.isEmpty {
                            FDAServiceApi.shared.searchDrugInteractions(foodItems: drugs, callback: { (json) in
                                self.createDrugInteractionReport(drugs: drugs, json: json)
                            }, failure: { (error) in
                                print("ERROR: \(error)")
                            })
                        }
                    }
                }, failure: { (error) in
                    print("ERROR: \(error)")
                })
            }
        }
    }

    /// Create interaction report
    ///
    /// - Parameters:
    ///   - drugs: the drugs
    ///   - json: the response
    private func createDrugInteractionReport(drugs: [FoodItem], json: JSON) {
        if let _ = json["results"].arrayValue.first {
            // Generate text based on `drug` and `reactions `fields`.
            let report = MedicationResource.drugInteractionReport(json, drugs: drugs)
            CachingServiceApi.shared.saveMedicationResource(report, callback: { (_) in
                print("createDrugInteractionReport: report saved: \(report)")
            }, failure: { (error) in
                print("ERROR: \(error)")
            })
        }
    }

    /// Update taken nutritions
    ///
    /// - Parameters:
    ///   - food: the food
    ///   - info: the info 
    func updateNutritions(food: Food, info: [FoodItem: [NDBNutrient]], callback: ()->()) {
        var infoMap = [String: [NDBNutrient]]()
        for (k,v) in info {
            infoMap[k.title] = v
        }
        /// Add each food item
        for item in food.items {
            let amount: Double = food.extraAddedItems[item] ?? Double(item.amount) // added amount in relation to whole food item amount. Can be negative
            if amount > 0 {

                // for each nutrition
                for nutrition in infoMap[item.title] ?? [] {

                    let nutritionAmount = amount * nutrition.1
                    if let unit = HealthKitUtil.shared.getUnit(byString: nutrition.2),
                        let id = HealthKitUtil.shared.getId(byString: nutrition.0) {
                        HealthKitUtil.shared.addItem(id: id, amount: nutritionAmount, unit: unit, callback: {})
                    }
                }
            }
        }
        callback()
    }

    /// Update goals
    func updateGoals(callback: ()->()) {
        getNutritionGoals { (goals) in
            var goalsToSave = [Goal]()
            let g = DispatchGroup()
            for goal in goals {
                if let id = HealthKitUtil.shared.getId(byString: goal.title) {
                    g.enter()
                    HealthKitUtil.shared.getTodayStatistics(identifier: id, callback: { (quantity) in
                        let gramms = quantity.doubleValue(for: HKUnit.gram())
                        goal.value = Float(gramms)
                        goalsToSave.append(goal)
                        g.leave()
                    }, customTypeCallback: { g.leave() })
                }
            }
            g.notify(queue: DispatchQueue.main, execute: {
                CachingServiceApi.shared.goalServiceCache.upsert(goalsToSave, success: { (_) in
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
        CachingServiceApi.shared.getGoals(callback: { (goals, _) in
            callback(goals.filter({
                $0.goalType == ComparisonResult.orderedSame // goal type is to keep the level
                && $0.getRelatedNutrition() != nil // is related to nutrition
            })) // include only goals with specific level of required nutritions (most of "Pills" styled goals)
        }, failure: createFailureCallback())
    }

    /// Get all iten food to validate.
    ///
    /// - Parameter callback: the callback to return data
    private func getFoods(callback: @escaping ([Food])->()) {
        CachingServiceApi.shared.getFood(callback: callback, failure: createFailureCallback())
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
                NDBServiceApi.shared.searchFoodItem(foodItem: item, callback: { (nutrients) in
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
