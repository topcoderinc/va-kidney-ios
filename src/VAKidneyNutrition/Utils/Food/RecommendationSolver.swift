//
//  RecommendationSolver.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

typealias Recommendation = MedicationResource

/**
 * Protocol that is used to define utility that implements logic for Recommendations. Is used in RecommendationsUtil
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol RecommendationSolver {

    /// Check given goal against the food info
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - info: the info
    /// - Returns: recommendation solution
    func checkGoal(goal: Goal, info: [FoodItem: [NDBNutrient]]) -> RecommendationSolution

    /// Generates report with recommendation based on the solution
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - solution: the solution
    /// - Returns: recommendation
    func genedateRecommendation(goal: Goal, solution: RecommendationSolution) -> Recommendation?
}
