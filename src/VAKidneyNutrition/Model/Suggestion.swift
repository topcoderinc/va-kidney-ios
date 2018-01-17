//
//  Suggestion.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Suggestion model object
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Suggestion: CacheableObject {

    /// the fields
    var title = ""
    var text = ""
    var imageUrl: String?
    var status = ""

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Suggestion {
        let object = Suggestion(id: UUID().uuidString)
        object.title = json["title"].stringValue
        object.text = json["text"].stringValue
        object.imageUrl = json["imageUrl"].string
        object.status = json["status"].stringValue
        return object
    }
}
