//
//  ComplexRecommendationGenerator.swift
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
class ComplexRecommendationGenerator: RecommendationGenerator {

    /// the generators used to generate reports based on RecommendationSolutions
    private var staticGenerator: RecommendationGenerator = StaticResourceBasedRecommendationGenerator()
    private var ndbGenerator: RecommendationGenerator = NDBBasedRecommendationGenerator()

    /// Generates report with recommendation based on the solution
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - solution: the solution
    ///   - callback: the callback to return recommendation
    func genedateRecommendation(goal: Goal, solution: RecommendationSolution, callback: @escaping ([Recommendation]) -> ()) {
        staticGenerator.genedateRecommendation(goal: goal, solution: solution) { (list) in
            if list.isEmpty {
                self.ndbGenerator.genedateRecommendation(goal: goal, solution: solution, callback: callback)
            }
            else {
                callback(list)
            }
        }
    }
}
