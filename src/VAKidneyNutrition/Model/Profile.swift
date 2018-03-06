//
//  Profile.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 * Profile info
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - JSON parsing
 *
 * 1.2:
 * - Integration changes
 */
public class Profile: CacheableObject {

    /// the name
    var name = ""

    /// the birthday day
    var birthday: Date?

    /// the height
    var height: Double = -1

    /// the current weight
    var currentWeight: Double = -1

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
        object.height = json["height"].doubleValue
        object.currentWeight = json["currentWeight"].doubleValue
        object.dialysis = json["dialysis"].boolValue
        object.diseaseCategory = json["diseaseCategory"].stringValue
        object.setupGoals = json["setupGoals"].boolValue
        object.image = UIImage(named: json["imageUrl"].stringValue)
        object.addDevice = json["addDevice"].boolValue
        object.name = json["name"].stringValue
        return object
    }

    /// Get current object with data from given profile
    ///
    /// - Parameter profile: the profile
    func merge(with profile: Profile) {
        if let date = profile.birthday { // Hf
            self.birthday = date
        }
        if profile.height > 0 {
            self.height = profile.height
        }
        if profile.currentWeight > 0 {
            self.currentWeight = profile.currentWeight
        }
    }

    /// Check if new profile is changed so that we need to update goals
    ///
    /// - Parameter profile: the profile
    /// - Returns: true - if need to update goals, false - else
    func shouldChangeGoals(with profile: Profile) -> Bool {
        return diseaseCategory != profile.diseaseCategory
        || dialysis != profile.dialysis
        || setupGoals != profile.setupGoals // if switched from "Yes" to "No", then delete, if switched from "No" to "Yes", then also delete (before creating new)
    }
}

