//
//  Reward.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/24/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Reward model object
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Reward: CacheableObject {

    /// the fields
    var points = 0
    var text = ""
    var message = ""
    var isCompleted = false

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Reward {
        let object = Reward(id: json["id"].stringValue)
        object.points = json["points"].intValue
        object.text = json["text"].stringValue
        object.message = json["message"].stringValue
        object.isCompleted = json["isCompleted"].boolValue
        return object
    }
}
