//
//  RecommendationSolver.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Protocol that is used to define utility that implements logic for Recommendations. Is used in RecommendationsUtil
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - one method moved to `RecommendationGenerator`
 */
protocol RecommendationSolver {

    /// Check given goal against the food info
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - info: the info
    /// - Returns: recommendation solution
    func checkGoal(goal: Goal, info: [FoodItem: [NDBNutrient]], callback: @escaping (RecommendationSolution)->())
}
