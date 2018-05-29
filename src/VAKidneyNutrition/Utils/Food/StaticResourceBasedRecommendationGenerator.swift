//
//  StaticResourceBasedRecommendationGenerator.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 4/13/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Uses embedded resource file to provide recommendations
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StaticResourceBasedRecommendationGenerator: RecommendationGenerator {

    /// Generates report with recommendation based on the solution
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - solution: the solution
    ///   - callback: the callback to return recommendation
    func genedateRecommendation(goal: Goal, solution: RecommendationSolution, callback: @escaping ([Recommendation]) -> ()) {
        if let report = NDBBasedRecommendationGenerator.generateStubReduceReport(goal: goal, solution: solution) {
            var typeString = ""
            switch solution {
            case .reduce(_, _):
                typeString = "reduce"
            case .increase(_):
                typeString = "increase"
            default:
                break
            }
            if let json = JSON.resource(named: "recommendations") {
                if let item = json["goalBased"].arrayValue.filter({$0["goalTitle"].stringValue == goal.title && $0["type"].stringValue == typeString}).first {
                    report.text = item["text"].stringValue
                    callback([report])
                    return
                }
            }
        }
        callback([])
    }
}
