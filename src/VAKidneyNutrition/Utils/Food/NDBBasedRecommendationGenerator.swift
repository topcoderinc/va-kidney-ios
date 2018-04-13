//
//  NDBBasedRecommendationGenerator.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/30/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * Implementation of RecommendationGenerator that request "good" and "bad" food suggessions from NDB database
 *
 * - author: TCCODER
 * - version: 1.0
 */
class NDBBasedRecommendationGenerator: RecommendationGenerator {

    /// the references to API
    private let foodDetailsApi: FoodDetailsServiceApi = CachingNDBServiceApi.sharedWrapper

    /// Generates report with recommendation based on the solution
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - solution: the solution
    ///   - callback: the callback to return recommendation
    func genedateRecommendation(goal: Goal, solution: RecommendationSolution, callback: @escaping ([Recommendation])->()) {
        switch solution {
        case .reduce(let nutrients, let food):
            let foodType = food.first?.type ?? FoodItemType.food
            self.searchLowAndHighContentFood(nutrients: nutrients, callback: { (suggestedLowFood, suggestedHighFood) in
                var reports = [Recommendation]()
                if !suggestedHighFood.isEmpty {
                    if let reportHigh = NDBBasedRecommendationGenerator.generateStubReduceReport(goal: goal, solution: solution) {
                        let foodList = suggestedHighFood.map({"- \($0)"}).joined(separator: ";\n")
                        reportHigh.text = "\(foodList)\n\nThis food contains high amount of the nutrients you need to reduce."
                        reports.append(reportHigh)
                    }
                }
                if !suggestedLowFood.isEmpty {
                    if let reportLow = NDBBasedRecommendationGenerator.generateStubReduceReport(goal: goal, solution: solution) {
                        reportLow.type = foodType == .food ? RecommendationType.foodSuggestion : RecommendationType.drugConsumption
                        let foodList = suggestedLowFood.map({"- \($0)"}).joined(separator: ";\n")
                        reportLow.text = "\(foodList)\n\nThis food contains low amount of the nutrient you need to reduce."
                        reports.append(reportLow)
                    }
                }
                callback(reports)
            })
        default:
            callback([])
        }
    }

    /// Create almost ready Recommendation object. The only fields to tweak are `.text` and `.type` (optional)
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - solution: the solution
    /// - Returns: recommendation
    class func generateStubReduceReport(goal: Goal, solution: RecommendationSolution) -> Recommendation? {
        switch solution {
        case .reduce(let nutrients, let food):
            let foodType = food.first?.type ?? FoodItemType.food
            let foodString = food.map({$0.title}).joined(separator: ", ")
            let nutrientsString = nutrients.map({$0.title}).joined(separator: ", ")
            let title = NSLocalizedString("Reduce", comment: "Reduce") + " \(foodString)"

            let report = SimpleRecommendationSolver.createStubRecommendation(goal: goal, solution: solution)
            report.type = foodType == .food ? RecommendationType.unsafeFood : RecommendationType.drugConsumption
            report.title = title
            report.relatedFoodInfo = nutrientsString
            return report
        case .increase(let food):
            let title = NSLocalizedString("Increase \(goal.title)", comment: "Increase \(goal.title)") // TODO check if all goals has correct report title
            let report = SimpleRecommendationSolver.createStubRecommendation(goal: goal, solution: solution)
            report.type = food.type == .food ? RecommendationType.foodSuggestion : RecommendationType.drugConsumption
            report.title = title
            return report
        default:
            return nil
        }
    }
    
    /// Search food with high and low content of given nutrients
    ///
    /// - Parameters:
    ///   - nutrients: the nutrients
    ///   - callback: the callback to return recommendation
    private func searchLowAndHighContentFood(nutrients: [NDBNutrient], callback: @escaping ([String], [String])->()) {
        let failure: FailureCallback = { error in
            print("ERROR:searchLowAndHighContentFood: \(error)")
            callback([], [])
        }
        var foodLowContent = [String]()
        var foodHighContent = [String]()
        let responseCallback: (JSON)->([String]) = { (json)->[String] in
            return json["report"]["foods"].arrayValue.map{$0["name"].stringValue}
        }
        let processHighContentCallback: ([NDBNutrient], JSON, @escaping ()->())->() = { (list, json, completion) in
            foodHighContent.append(contentsOf: responseCallback(json))
            self.searchLowContentFood(nutrients: nutrients, response: json, callback: { (jsonLow) in
                foodLowContent.append(contentsOf: responseCallback(jsonLow))
                completion()
            }, failure: { error in
                print("ERROR:searchLowAndHighContentFood: \(error)")
                completion()
            })
        }

        self.foodDetailsApi.searchNutrients(nutrientIds: nutrients.map({$0.id}), offset: nil, callback: { (json) in
            if json["report"]["total"].intValue > 0 {
                processHighContentCallback(nutrients, json, {
                    callback(foodLowContent, foodHighContent)
                })
            }
            else {
                // if there are no food with all that nutrients, then search separately
                let g = DispatchGroup()
                for nutrient in nutrients {
                    g.enter()
                    self.foodDetailsApi.searchNutrients(nutrientIds: [nutrient.id], offset: nil, callback: { (json) in
                        processHighContentCallback([nutrient], json, {
                            g.leave()
                        })
                    }, failure: { error in
                        print("ERROR:searchLowAndHighContentFood:searchNutrients: \(error)")
                        g.leave()
                    })
                }
                g.notify(queue: DispatchQueue.main, execute: {
                    callback(foodLowContent, foodHighContent)
                })
            }
        }, failure: failure)
    }


    /// Search food with low content of given nutrients
    ///
    /// - Parameters:
    ///   - nutrients: the nutrients
    ///   - response: "high content" response
    ///   - callback: the callback to return recommendation
    ///   - failure: the failure callback to return an error
    private func searchLowContentFood(nutrients: [NDBNutrient], response: JSON, callback: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        let total = response["report"]["total"].intValue
        let limit = NDBServiceApi.MAX_ITEMS_IN_NUTRIENT_RESULTS
        if total > limit {
            let offset = max(total - limit, limit)
            self.foodDetailsApi.searchNutrients(nutrientIds: nutrients.map({$0.id}), offset: offset, callback: callback, failure: failure)
            return
        }
        callback(JSON.null)
    }
}
