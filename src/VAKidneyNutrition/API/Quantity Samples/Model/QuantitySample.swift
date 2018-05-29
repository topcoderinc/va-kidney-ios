//
//  QuantitySample.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/29/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import HealthKit

/**
 * Model class for quantity sample. Amount in grams for all types.
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - refacotring
 */
public class QuantitySample: CacheableObject {

    /// the type
    var type: QuantityType!

    /// the amount in grams
    var amount: Double = 0

    var customUnits: HKUnit?

    /// Get units
    ///
    /// - Returns: HKUnit
    func getHKUnit() -> HKUnit {
        return customUnits ?? HKUnit.gram()
    }

    /// Create from raw data
    ///
    /// - Parameters:
    ///   - type: the type
    ///   - amount: the amount
    ///   - unit: the unit ID from HK
    /// - Returns: the quantity sample
    class func create(type: QuantityType, amount: Double, unit: String) -> QuantitySample {
        let object = QuantitySample(id: UUID().uuidString)
        object.type = type

        // Amount
        let (normalizedUnit, normalizedAmount, isMass) = HealthKitUtil.normalizeUnits(units: unit, amount: amount)
        var amount = normalizedAmount
        var unit = normalizedUnit
        /// If not `water` and `unit==*L` (liter), then convert to grams
        if type.id != HKQuantityTypeIdentifier.dietaryWater.rawValue
            && unit == HKUnit.liter().unitString {
                unit = HKUnit.gram().unitString
                amount = amount * 1000
        }

        let quantity = HKQuantity(unit: HKUnit(from: unit), doubleValue: amount)
        if isMass {
            object.amount = quantity.doubleValue(for: HKUnit.gram()) // get value in grams
        }
        else {
            let customUnits = HKUnit(from: unit)
            object.amount = quantity.doubleValue(for: customUnits)
            object.customUnits = customUnits
        }
        return object
    }

    /// debug description
    override public var description: String {
        return "QuantitySample[amount=\(amount), type=\(type.id)]"
    }
}
