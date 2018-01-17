//
//  Medication.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Medication model object
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class Medication: CacheableObject {

    /// the fields
    var title = ""
    var times = [MedicationTime]()

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Medication {
        let object = Medication(id: json["id"].stringValue)
        object.title = json["title"].stringValue
        object.times = json["times"].arrayValue.map{MedicationTime.fromJson($0)}
        return object
    }
}
