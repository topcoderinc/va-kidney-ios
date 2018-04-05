//
//  NDBServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * NDB API
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - FoodDetailsServiceApi support
 */
class NDBServiceApi: RESTApi, FoodDetailsServiceApi {

    /// The number of items to request. Currently we need only one item because logic on how to select one item from multiple results is simple - the most relevant
    let MAX_ITEMS_IN_RESULTS = 1

    /// the number of nutrients to request
    static let MAX_ITEMS_IN_NUTRIENT_RESULTS = 10

    /// singleton
    static let shared: FoodDetailsServiceApi = NDBServiceApi(baseUrl: Configuration.shared.ndbApiBaseUrl)

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

    /// Search nutrients ordered by its content in food
    ///
    /// - Parameters:
    ///   - nutrientIds: the IDs
    ///   - offset: the offset
    ///   - callback: the callback to invoke when success
    ///   - failure: the callback to invoke when an error occurred
    func searchNutrients(nutrientIds: [String], offset: Int? = nil, callback: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        var strs = [String]()
        for id in nutrientIds {
            strs.append("nutrients=\(id)")
        }
        let ids = strs.joined(separator: "&")
        let limit = NDBServiceApi.MAX_ITEMS_IN_NUTRIENT_RESULTS
        var endpoint = "nutrients/?format=json&api_key=\(key)&\(ids)&max=\(limit)&sort=c"
        if let offset = offset {
            endpoint += "&offset=\(offset)"
        }
        self.get(endpoint, success: callback, failure: failure)
    }

    /// Search food details
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
            let nutrient = NDBNutrient(id: item["nutrient_id"].stringValue, title: item["name"].stringValue, percent: percent, unit: foodItem.units)
            list.append(nutrient)
        }
        return list
    }
}
