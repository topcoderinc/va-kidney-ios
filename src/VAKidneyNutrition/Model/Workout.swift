//
//  Workout.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Workout model object
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class Workout: CacheableObject {

    /// fields
    var title = ""
    var iconName: String = ""
    var initialValue: Float = 0
    var value: Float = 0
    var targetValue: Float = 0

    /// fields depending on a task
    var valueText1 = ""
    var valueTextMultiple = ""

    /// true - user can add data manually, false - only from devices
    var canBeManuallyChanged = false

    /// true - if today goal is achieved, false - else
    var isGoalAchived: Bool {
        return value >= targetValue
    }

    /// the progress
    var progress: Float {
        let total = abs(initialValue - targetValue)
        let progressValue = abs(value - initialValue)
        if total > 0 {
            return progressValue / total
        }
        return 0
    }

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Workout {
        let object = Workout(id: json["id"].stringValue)
        object.title = json["title"].stringValue
        object.iconName = json["iconName"].stringValue
        object.initialValue = json["initialValue"].floatValue
        object.value = json["value"].floatValue
        object.targetValue = json["targetValue"].floatValue
        object.valueText1 = json["valueText1"].stringValue
        object.valueTextMultiple = json["valueTextMultiple"].stringValue
        object.canBeManuallyChanged = json["canBeManuallyChanged"].boolValue
        return object
    }

    /// Get icon for the goal
    ///
    /// - Returns: the icon image
    func getIcon() -> UIImage? {
        return UIImage(named: iconName)
    }

    /// Get value as a text, e.g. "2 Glasses"
    ///
    /// - Returns: the text
    func getValueText() -> String {
        return "\(value.toString()) \(value == 1 ? valueText1 : valueTextMultiple)".capitalized
    }

    /// Get target value as a text, e.g. "2 Glasses"
    ///
    /// - Returns: the text
    func getTargetText() -> String {
        return "\(targetValue.toString()) \(targetValue == 1 ? valueText1 : valueTextMultiple)".capitalized
    }
}
