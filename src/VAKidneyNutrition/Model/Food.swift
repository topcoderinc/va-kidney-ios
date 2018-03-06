//
//  Food.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Food Intake model object
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - multiple images support
 *
 * 1.2:
 * - Integration changes
 */
public class Food: CacheableObject {

    /// the fields
    var time: FoodIntakeTime!
    var items = [FoodItem]()
    var date: Date = Date()
    var images = [Any]() // UIImage or String

    // in-memory fields
    /// the amount of food added after update
    var extraAddedItems = [FoodItem:Double]()

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Food {
        let object = Food(id: json["id"].stringValue)
        object.time = FoodIntakeTime(rawValue: json["time"].stringValue.lowercased()) ?? .breakfast
        object.items = json["items"].arrayValue.map({FoodItem.fromJson($0)})
        object.images = json["imageUrls"].arrayValue.map{$0.stringValue}
        return object
    }
}
