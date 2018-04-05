//
//  RecommendationGenerator.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/30/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation

/**
 * Protocol that is used to generate recommendations based on RecommendationSolution
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol RecommendationGenerator {

    /// Generates report with recommendation based on the solution
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - solution: the solution
    ///   - callback: the callback to return recommendations
    func genedateRecommendation(goal: Goal, solution: RecommendationSolution, callback: @escaping ([Recommendation])->())
}
