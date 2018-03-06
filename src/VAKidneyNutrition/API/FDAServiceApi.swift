//
//  FDAServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * NDB API
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FDAServiceApi: RESTApi {

    /// singleton
    static let shared = FDAServiceApi(baseUrl: Configuration.shared.fdaApiBaseUrl)

    /// the API key
    private let key = Configuration.shared.fdaApiKey

    /// Search for drug interactions
    ///
    /// - Parameters:
    ///   - foodItems: the food items
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchDrugInteractions(foodItems: [FoodItem], callback: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        let string = foodItems.map({$0.title}).joined(separator: " ")
        let searchString = "\"\(string)\"".urlEncodedString()
        let endpoint = "?api_key=\(key)&search=patient.drug.medicinalproduct:\(searchString)"
        self.get(endpoint, success: callback, failure: failure)
    }
}
