//
//  FoodItem.swift
//  VAKidneyNutrition
//
//  Created by Volkov Alexander on 2/23/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Food Intake item model object
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class FoodItem: CacheableObject {

    /// the fields
    var title = ""
    var units = ""
    var amount: Float = 0

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> FoodItem {
        let object = FoodItem(id: json["id"].stringValue)
        object.title = json["items"].stringValue
        object.units = json["units"].stringValue
        object.amount = json["amount"].floatValue
        return object
    }
}

