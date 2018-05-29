//
//  FoodDetailsServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/31/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * API for getting food details. Covers NDB service.
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - new method
 */
protocol FoodDetailsServiceApi {

    /// Search food item. First try to find "raw" product because it's more appropriate to take info from non-manufactured product,
    /// if nothing found, then try to find food item as is.
    ///
    /// - Parameters:
    ///   - foodItem: the food item
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchFoodItemNutrients(foodItem: FoodItem, callback: @escaping ([NDBNutrient]?)->(), failure: @escaping FailureCallback)

    /// Search food (sorted by relevance)
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - limit: the limit
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchFood(title: String, limit: Int, callback: @escaping (JSON)->(), failure: @escaping FailureCallback)

    /// Search food in database and return FoodItem objects (`id` and `title`).
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchFoodItems(string: String, callback: @escaping ([FoodItem])->(), failure: @escaping FailureCallback)

    /// Search nutrients ordered by its content in food
    ///
    /// - Parameters:
    ///   - nutrientIds: the IDs
    ///   - offset: the offset
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchNutrients(nutrientIds: [String], offset: Int?, callback: @escaping (JSON)->(), failure: @escaping FailureCallback)

    /// Search food details
    ///
    /// - Parameters:
    ///   - id: the ID
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchFoodDetails(id: String, callback: @escaping (JSON)->(), failure: @escaping FailureCallback)
}
