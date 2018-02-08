//
//  MedicationResource.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Model object for resource in medication tab
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MedicationResource: CacheableObject {

    /// the fields
    var title = ""
    var text = ""
    var imageUrl: String = ""

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> MedicationResource {
        let object = MedicationResource(id: json["id"].stringValue)
        object.title = json["title"].stringValue
        object.text = json["text"].stringValue
        object.imageUrl = json["imageUrl"].stringValue
        return object
    }
}
