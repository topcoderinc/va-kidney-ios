//
//  Measurement.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 5/26/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Medication model object
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class Measurement: CacheableObject {

    /// the fields
    var title = ""
    var relatedQuantityIds = [String]()
    var quantityTitles = [String]()
    var info: String?
    var comorbidCondition: ComorbidCondition?

    var iconName: String = ""
    var value = ""
    var valueText = ""
    var color: UIColor = .red

    /// Set quantity value
    ///
    /// - Parameter value: the value
    func setQuantityValue(_ quantityValue: Double) {
        let newValue = Float(quantityValue)
        if value.isEmpty {
            value = "\(newValue.toString())"
        }
        else if let currentValue = Float(value) {
            value = "\(max(newValue, currentValue).toString())/\(min(newValue, currentValue).toString())"
        }
    }

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Measurement {
        let object = Measurement(id: json["id"].stringValue)
        object.title = json["title"].stringValue
        object.relatedQuantityIds = json["relatedQuantityIds"].arrayValue.map({$0.stringValue})
        if let id = json["relatedQuantityId"].string {
            object.relatedQuantityIds.append(id)
        }
        object.quantityTitles = json["quantityTitles"].arrayValue.map({$0.stringValue})
        object.info = json["info"].string
        object.comorbidCondition = ComorbidCondition(rawValue: json["comorbidCondition"].stringValue)
        object.iconName = json["iconName"].stringValue
        object.valueText = json["valueText"].stringValue
        object.color = UIColor.fromString(json["color"].stringValue) ?? .red
        return object
    }
}
