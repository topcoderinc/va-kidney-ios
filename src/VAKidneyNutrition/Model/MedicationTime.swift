//
//  MedicationTime.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Medication time
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class MedicationTime: CacheableObject {

    /// the fields
    var weekday = -1 // -1 - every day
    var hour = 0 // the day hour (local time)
    var units = 1

    /// calculated field: true - user taken the pills today, false - else
    var taken = false

    /// Get hour as text
    ///
    /// - Returns: the text
    func getHourText() -> String {
        return hour.toHourText()
    }

    /// Get units text
    ///
    /// - Returns: the text
    func getUnitsText() -> String {
        return "\(units) \(units == 1 ? "unit" : "units")"
    }

    /// Get units text
    ///
    /// - Returns: the text
    func getWeekdayText() -> String {
        if weekday == -1 {
            return NSLocalizedString("Daily", comment: "Daily")
        }
        return DateFormatters.weekday.string(from: Date.create(withWeekday: weekday))
    }
    
    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> MedicationTime {
        let object = MedicationTime(id: json["id"].stringValue)
        object.weekday = json["weekday"].intValue
        object.hour = json["hour"].intValue
        object.units = json["units"].intValue
        return object
    }
}
