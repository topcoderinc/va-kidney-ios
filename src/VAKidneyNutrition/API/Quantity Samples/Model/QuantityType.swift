//
//  LabValue.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/3/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON
import HealthKit

/// All custom quanity types
enum QuantityTypeCustom: String {
    case alcohol = "alcohol", meat = "meat", vegetables = "vegetables"

    /// All custom types as strings. It must be ready to use [String] because used very intensively.
    /// It should not be calculated from existing types.
    static let allAsStrings = ["alcohol", "meat", "vegetables"]
}

/**
 * Model class for quantity type (lab value, nutrition, etc.)
 *
 * - author: TCCODER
 * - version: 1.0
 */
class QuantityType: CustomStringConvertible {

    /// the fields
    let id: String // 
    var title = ""

    /// All possible types
    static var allTypes: [String:QuantityType] = {
        if let json = JSON.resource(named: "labValues") {
            let types = json["labValues"].arrayValue.map{QuantityType.fromJson($0)}
            return types.hashmapWithKey({$0.id})
        }
        return [:]
    }()

    /// Private initializer
    private init(id: String) {self.id = id}

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> QuantityType {
        let object = QuantityType(id: json["id"].stringValue)
        object.title = json["title"].stringValue
        return object
    }

    /// Get type by ID
    ///
    /// - Parameter id: the ID
    /// - Returns: the type
    class func fromId(_ id: String) -> QuantityType {
        return allTypes[id] ?? QuantityType(id: id)
    }

    /// Convert to HKQuantityTypeIdentifier
    ///
    /// - Returns: HKQuantityTypeIdentifier
    func toHKType() -> HKQuantityTypeIdentifier {
        return HKQuantityTypeIdentifier(rawValue: id)
    }

    /// debug description
    var description: String {
        return "QuantityType[id=\(id)]"
    }
}
