//
//  GoalCategory.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/24/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Goal category model object
 *
 * - author: TCCODER
 * - version: 1.0
 */
class GoalCategory: CacheableObject {

    /// fields
    var title = ""
    var numberOfGoals = 0

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> GoalCategory {
        let object = GoalCategory(id: json["id"].stringValue)
        object.title = json["title"].stringValue
        return object
    }
}
