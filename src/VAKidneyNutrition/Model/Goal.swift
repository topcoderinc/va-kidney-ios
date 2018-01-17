//
//  Goal.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import SwiftyJSON

/// Possible frequencies for the goals
enum GoalFrequency: String {
    case daily = "daily", weekly = "weekly"

    /// Get all possible values
    ///
    /// - Returns: the list of values
    static func getAll() -> [GoalFrequency] {
        return [GoalFrequency.daily, GoalFrequency.weekly]
    }
}

/**
 * Goal model object
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class Goal: CacheableObject {

    /// fields
    var title = ""
    var iconName: String = ""
    var categoryId = ""
    var category: GoalCategory!
    var targetValue: Float = 0
    var frequency: GoalFrequency = .daily
    var dateStart = Date()

    /// fields that have aggregated info
    var points: Int = 0
    var initialValue: Float = 0
    var value: Float = 0

    /// fields depending on a task
    var valueText1 = ""
    var valueTextMultiple = ""
    // true - the data can be taken from external devices/sensors, false - else
    var hasExternalData = false
    /// true - the target is above the initial value, false - else
    var isAscendantTarget = true

    // the index used to sort
    var sOrder = 0

    /// true - if today goal is achieved, false - else
    var isGoalAchived: Bool {
        return isAscendantTarget ? (value >= targetValue) : (value <= targetValue)
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
    class func fromJson(_ json: JSON) -> Goal {
        let goal = Goal(id: json["id"].stringValue)
        goal.title = json["title"].stringValue
        goal.iconName = json["iconName"].stringValue
        goal.categoryId = json["categoryId"].stringValue
        goal.points = json["points"].intValue
        goal.initialValue = json["initialValue"].floatValue
        goal.value = json["value"].floatValue
        goal.targetValue = json["targetValue"].floatValue
        goal.valueText1 = json["valueText1"].stringValue
        goal.valueTextMultiple = json["valueTextMultiple"].stringValue
        goal.hasExternalData = json["hasExternalData"].boolValue
        goal.isAscendantTarget = json["isAscendantTarget"].bool ?? true

        return goal
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
