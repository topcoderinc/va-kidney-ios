//
//  RecommendationSolution.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation

/**
 * Possible recommendation solutions
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - refactoring: nutrients and food items added for .reduce
 */
enum RecommendationSolution {

    /// .reduce provides additional info
    case reduce([NDBNutrient], [FoodItem]), increase, none
}
