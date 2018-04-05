//
//  DrugDetailsServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/31/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * API for getting drug details. Covers FDA service.
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol DrugDetailsServiceApi {

    /// Search for drug interactions
    ///
    /// - Parameters:
    ///   - foodItems: the food items
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchDrugInteractions(foodItems: [FoodItem], callback: @escaping (JSON)->(), failure: @escaping FailureCallback)
}
