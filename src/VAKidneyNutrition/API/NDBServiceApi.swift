//
//  NDBServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/// Type alias for (title, amount, unit) of one nutrient in NDB response.
/// Percent of the nutrient in the related product.
typealias NDBNutrient = (String, Double, String)

/**
 * NDB API
 *
 * - author: TCCODER
 * - version: 1.0
 */
class NDBServiceApi: RESTApi {

    /// The number of items to request. Currently we need only one item because logic on how to select one item from multiple results is simple - the most relevant
    let MAX_ITEMS_IN_RESULTS = 1

    /// singleton
    static let shared = NDBServiceApi(baseUrl: Configuration.shared.ndbApiBaseUrl)

    /// the API key
    private let key = Configuration.shared.ndbApiKey

    /// Search food item. First try to find "raw" product because it's more appropriate to take info from non-manufactured product,
    /// if nothing found, then try to find food item as is.
    ///
    /// - Parameters:
    ///   - foodItem: the food item
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchFoodItem(foodItem: FoodItem, callback: @escaping ([NDBNutrient]?)->(), failure: @escaping FailureCallback) {
        self.searchFood(title: foodItem.title, callback: { json in
            if let id = json["list"]["item"].arrayValue.first?["ndbno"].string {

                // Get details
                self.searchFoodDetails(id: id, callback: { json in
                    callback(NDBServiceApi.parseFoodItemDetailsIntoNutrients(json, foodItem: foodItem))
                }, failure: failure)
            }
            else {
                callback(nil)
            }
        }, failure: failure)
    }

    /// Search food (sorted by relevance)
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchFood(title: String, callback: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        let endpoint = "search/?format=json&q=\(title.urlEncodedString())&sort=r&max=\(MAX_ITEMS_IN_RESULTS)&offset=0&api_key=\(key)"
        self.get(endpoint, success: callback, failure: failure)
    }

    /// Search food (sorted by relevance)
    ///
    /// - Parameters:
    ///   - id: the ID
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchFoodDetails(id: String, callback: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        let endpoint = "reports/?ndbno=\(id)&type=b&format=json&api_key=\(key)"
        self.get(endpoint, success: callback, failure: failure)
    }

    /// Parse Food Item details into nutrients
    ///
    /// - Parameters:
    ///   - json: JSON
    ///   - foodItem: the food item
    /// - Returns: the list of nutrients
    class func parseFoodItemDetailsIntoNutrients(_ json: JSON, foodItem: FoodItem) -> [NDBNutrient] {
        var list = [NDBNutrient]()
        for item in json["report"]["food"]["nutrients"].arrayValue {
            var percent: Double = 0
            let value = item["value"].doubleValue
            let unit = item["unit"].stringValue
            switch unit {
            case "g":
                percent = value / 100
            case "mg":
                percent = value / 100000
            case "µg":
                percent = value / 100000000
            default:
                continue
            }
            list.append((item["name"].stringValue, percent, foodItem.units))
        }
        return list
    }
}
