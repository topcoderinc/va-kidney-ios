//
//  Profile.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 * Profile info
 *
 * - author: TCCODER
 * - version: 1.1
 */
/* changes:
 * 1.1:
 * - JSON parsing
 */
public class Profile: CacheableObject {

    /// the name
    var name = ""

    /// the birthday day
    var birthday: Date?

    /// the height
    var height = -1

    /// the current weight
    var currentWeight = -1

    /// answer to  "Are you on Dialysis?"
    var dialysis: Bool = false

    /// the disease category
    var diseaseCategory = ""

    /// true - will setup goals, false - else
    var setupGoals = false

    /// the profile image
    var image: UIImage?

    /// is device added
    var addDevice: Bool = false

    /// Parse JSON into object
    ///
    /// - Parameter json: JSON object
    /// - Returns: object
    class func fromJson(_ json: JSON) -> Profile {
        let object = Profile(id: json["id"].stringValue)
        object.birthday = DateFormatters.responseDate.date(from: json["birthday"].stringValue) ?? Date()
        object.height = json["height"].intValue
        object.currentWeight = json["currentWeight"].intValue
        object.dialysis = json["dialysis"].boolValue
        object.diseaseCategory = json["diseaseCategory"].stringValue
        object.setupGoals = json["setupGoals"].boolValue
        object.image = UIImage(named: json["imageUrl"].stringValue)
        object.addDevice = json["addDevice"].boolValue
        object.name = json["name"].stringValue
        return object
    }
}

