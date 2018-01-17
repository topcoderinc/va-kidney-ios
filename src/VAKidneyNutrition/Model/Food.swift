//
//  Food.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Food Intake model object
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class Food: CacheableObject {

    /// the fields
    var time: FoodIntakeTime!
    var items = ""
    var date: Date = Date()
    var image: UIImage?

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Food {
        let object = Food(id: json["id"].stringValue)
        object.time = FoodIntakeTime(rawValue: json["time"].stringValue.lowercased()) ?? .breakfast
        object.items = json["items"].stringValue
        return object
    }
}
