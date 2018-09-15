//
//  HomeInfo.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Home info model (goal or measurement)
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HomeInfo {

    /// fields
    var title = ""
    var iconName: String = ""
    var value = ""
    var valueText = ""
    var percent: Float = 0
    var color: UIColor = .red
    var relatedQuantityIds = [String]()
    var quantityTitles = [String]()
    var info: String?

    /// Convert goal to info
    ///
    /// - Parameter item: the goal
    /// - Returns: the info
    class func fromGoal(_ item: Goal) -> HomeInfo {
        let object = HomeInfo()
        object.title = item.title
        object.iconName = item.iconName
        object.value = "\(item.value.toString())/\(item.targetValue.toString())"
        object.valueText = item.valueTextMultiple
        object.percent = min(1, item.value / max(1, item.targetValue))
        object.color = item.color
        if let id = item.relatedQuantityId {
            object.relatedQuantityIds = [id]
        }
        return object
    }

    /// Convert measurement to info
    ///
    /// - Parameter item: the goal
    /// - Returns: the info
    class func fromMeasurement(_ item: Measurement) -> HomeInfo {
        let object = HomeInfo()
        object.title = item.title
        object.iconName = item.iconName
        object.value = item.value
        object.valueText = item.valueText
        object.percent = item.value.isEmpty ? 0 : 1
        object.color = item.color
        object.relatedQuantityIds = item.relatedQuantityIds
        object.quantityTitles = item.quantityTitles
        object.info = item.info
        return object
    }
}
