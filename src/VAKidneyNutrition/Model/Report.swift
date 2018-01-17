//
//  Report.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Possible report statuses in relation to the limit
///
/// - below: below the limit
/// - overflow: overflow the limit
/// - within: within the limit
enum ReportLimitStatus: String {
    case below = "below", overflow = "overflow", within = "within"

    /// Get icon image
    ///
    /// - Returns: the image
    func getIconImage() -> UIImage {
        switch self {
        case .below:
            return UIImage(named: "limitBelow") ?? UIImage()
        case .overflow:
            return UIImage(named: "limitOverflow") ?? UIImage()
        case .within:
            return UIImage(named: "limitWithin") ?? UIImage()
        }
    }

    /// Get smile
    ///
    /// - Returns: the image
    func getSmile() -> UIImage {
        switch self {
        case .within:
            return UIImage(named: "smileHappy") ?? UIImage()
        default:
            return UIImage(named: "smileSad") ?? UIImage()
        }
    }
}

/**
 * Report model object
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Report: CacheableObject {

    /// the fields
    var title = ""
    var units = 0
    var lastEventDate: Date?
    var limitStatus: ReportLimitStatus = .within
    var showTwoButtons = true

    /// Get units
    ///
    /// - Returns: the units
    func getUnitsText() -> String {
        return "\(units) unit/unit"
    }

    /// Get text representing when the report was updated
    ///
    /// - Returns: the text
    func getDaysText() -> String {
        if let date = lastEventDate {
            return date.timeAgo(useFullText: true)
        }
        return ""
    }

    /// Get full text representing when the report was updated
    ///
    /// - Returns: the text
    func getDaysFullText() -> String {
        if let date = lastEventDate {
            return NSLocalizedString("last added", comment: "last added") + " " + date.timeAgo(useFullText: true)
        }
        return ""
    }

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Report {
        let object = Report(id: json["id"].stringValue)
        object.title = json["title"].stringValue
            object.units = json["units"].intValue
        object.lastEventDate = DateFormatters.responseDate.date(from: json["lastEventDate"].stringValue)
        object.limitStatus = ReportLimitStatus(rawValue: json["limitStatus"].stringValue) ?? .within
        object.showTwoButtons = json["showTwoButtons"].boolValue
        return object
    }
}
