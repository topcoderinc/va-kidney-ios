//
//  Profile.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Possible comorbid conditions
enum ComorbidCondition: String {
    case hypertension = "hypertension", diabetesMellitus = "diabetesMellitus", congestiveHeartFailure = "congestiveHeartFailure"

    /// Get title
    ///
    /// - Returns: the title
    func getTitle() -> String {
        switch self {
        case .hypertension:
            return NSLocalizedString("Hypertension", comment: "Hypertension")
        case .diabetesMellitus:
            return NSLocalizedString("Diabetes mellitus", comment: "Diabetes mellitus")
        case .congestiveHeartFailure:
            return NSLocalizedString("Congestive heart failure", comment: "Congestive heart failure")
        }
    }

    /// all possible values
    static let all: [ComorbidCondition] = [.hypertension, .diabetesMellitus, .congestiveHeartFailure]
}

/**
 * Profile info
 *
 * - author: TCCODER
 * - version: 1.3
 *
 * changes:
 * 1.1:
 * - JSON parsing
 *
 * 1.2:
 * - Integration changes
 *
 * 1.3:
 * - ComorbidCondition added
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

    /// the list of comorbidities
    var comorbidities = [ComorbidCondition]()

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
}

