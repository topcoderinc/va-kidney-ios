//
//  Resource.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/4/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * Resource model object.
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Resource {

    /// the fields
    var title = ""
    var text = ""
    var url: String = ""

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Resource {
        let object = Resource()
        object.title = json["title"].stringValue.trim()
        object.text = json["text"].stringValue.trim()
        object.url = json["url"].stringValue.trim()
        return object
    }
}
