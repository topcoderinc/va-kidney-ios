//
//  Goal.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/// Possible frequencies for the goals
enum GoalFrequency: String {
    case daily = "daily", weekly = "weekly", monthly = "monthly"

    /// Get all possible values
    ///
    /// - Returns: the list of values
    static func getAll() -> [GoalFrequency] {
        return [.daily, .weekly, .monthly]
    }

    /// To singular
    ///
    /// - Returns: string
    func toSingular() -> String {
        switch self {
        case .daily:
            return NSLocalizedString("day", comment: "day")
        case .weekly:
            return NSLocalizedString("week", comment: "week")
        case .monthly:
            return NSLocalizedString("month", comment: "month")
        }
    }
}

/**
 * Goal model object
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - new fields
 *
 * 1.2:
 * - Integration changes
 */
public class Goal: CacheableObject {

    /// fields
    var title = ""
    var categoryId = ""
    var category: GoalCategory!
    var frequency: GoalFrequency = .daily
    var dateStart = Date()
    var points: Int = 0

    /// the current value of the progress
    var value: Float = 0
    /// the type of the goal:
    ///   .orderedDescending - user has 0 value initially and positive `target`. He increments value to reach >= `target`, e.g. "Distance" goal
    ///   .orderedAscending - user has X value initially and positive `target` < X. He decrements value to reach <= `target`, e.g. "Weight Loss" goal (make sence for `frequency == .month`)
    ///   .orderedSame - user has any X value initially and target is defined by two thresholds: `min` and `max`. User tries to be in between the thresholds. `target` value is not taken into account. Example: "Blood Sugar".
    var goalType: ComparisonResult = .orderedDescending

    // MARK: - Style

    /// fields that define how goal is rendered (style)
    var iconName: String = ""
    var valueText1 = ""
    var valueTextMultiple = ""
    var valueText = ""
    /// the color
    var color: UIColor = .red
    // the index used to sort
    var sOrder = 0

    // true - the data can be taken from external devices/sensors, false - else
    var hasExternalData = false
    /// flag: true - the app will remind about the goal, false - else
    var isReminderOn = false

    // MARK: - "Reach Target" goal fields

    /// true - the target is above the initial value, false - else
    var isAscendantTarget: Bool {
        return goalType == .orderedAscending
    }
    var targetValue: Float = 0
    var initialValue: Float = 0

    // MARK: - "Equality" goal fields

    // the two thresholds that define goals in Chart
    var min: Float?
    var max: Float?

    // MARK: - Calculated fields

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
        goal.valueText = json["valueText"].stringValue
        goal.valueTextMultiple = json["valueTextMultiple"].stringValue
        goal.hasExternalData = json["hasExternalData"].boolValue
        goal.overrideFieldsFrom(json)
        return goal
    }

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON, withStyles styles: [Goal]) -> Goal {
        let goal = Goal.fromJson(json)
        if let style = styles.filter({$0.title == json["style"].stringValue}).first {
            goal.category = style.category
            goal.iconName = style.iconName
            goal.valueText1 = style.valueText1
            goal.valueTextMultiple = style.valueTextMultiple
            goal.valueText = style.valueText
            goal.hasExternalData = style.hasExternalData
            goal.color = style.color
            goal.goalType = style.goalType
            goal.min = style.min
            goal.max = style.max
            goal.overrideFieldsFrom(json)
        }
        return goal
    }

    /// Override fields from given JSON
    ///
    /// - Parameter json: JSON
    private func overrideFieldsFrom(_ json: JSON) {
        if let alternativeColor = json["color"].string, let color = UIColor.fromString(alternativeColor) {
            self.color = color
        }
        if let alternativeIcon = json["iconName"].string {
            iconName = alternativeIcon
        }
        if let goalType = json["goalType"].string {
            switch goalType {
            case "orderedAscending":
                self.goalType = .orderedAscending
            case "orderedSame":
                self.goalType = .orderedSame
            default:
                self.goalType = .orderedDescending
            }
        }
        if let min = json["min"].float {
            self.min = min
        }
        if let max = json["max"].float {
            self.max = max
        }
        if let value = json["valueText1"].string {
            self.valueText1 = value
        }
        if let value = json["valueText"].string {
            self.valueText = value
        }
        if let value = json["valueTextMultiple"].string {
            self.valueTextMultiple = value
        }
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

    /// Get nutrition name
    ///
    /// - Returns: the name
    func getRelatedNutrition() -> String? {
        if title.contains("Intake") {
            return title.replace("Intake", withString: "").trim()
        }
        return nil
    }
}
