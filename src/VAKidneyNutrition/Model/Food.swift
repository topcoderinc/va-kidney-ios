//
//  Food.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Food Intake model object
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - multiple images support
 */
public class Food: CacheableObject {

    /// the fields
    var time: FoodIntakeTime!
    var items = ""
    var date: Date = Date()
    var images = [Any]() // UIImage or String

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Food {
        let object = Food(id: json["id"].stringValue)
        object.time = FoodIntakeTime(rawValue: json["time"].stringValue.lowercased()) ?? .breakfast
        object.items = json["items"].stringValue
        object.images = json["imageUrls"].arrayValue.map{$0.stringValue}
        return object
    }
}
