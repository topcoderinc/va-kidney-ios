//
//  QuantitySample.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/29/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import HealthKit

/**
 * Model class for quantity sample. Amount in grams for all types.
 *
 * - author: TCCODER
 * - version: 1.0
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
        var amount = amount
        var unit = HKUnit(from: unit)
        if type.id != HKQuantityTypeIdentifier.dietaryWater.rawValue {
            /// If not `water` and `unit==*L` (liter), then convert to grams
            if unit.unitString == HKUnit.liter().unitString {
                unit = HKUnit.gram()
                amount = amount * 1000
            }
            else if unit.unitString == HKUnit.literUnit(with: HKMetricPrefix.milli).unitString {
                unit = HKUnit.gram()
            }
            else if unit.unitString == HKUnit.literUnit(with: HKMetricPrefix.deci).unitString {
                unit = HKUnit.gram()
                amount = amount * 100
            }
            else if unit.unitString == HKUnit.kilocalorie().unitString {
                unit = HKUnit.calorie()
                amount = amount * 1000
            }
        }
        else if unit.unitString == HKUnit.literUnit(with: HKMetricPrefix.milli).unitString {
            unit = HKUnit.liter()
            amount = amount / 1000
        }
        else if unit.unitString == HKUnit.literUnit(with: HKMetricPrefix.deci).unitString {
            unit = HKUnit.liter()
            amount = amount / 10
        }
        else if unit.unitString == HKUnit.kilocalorie().unitString {
            unit = HKUnit.calorie()
            amount = amount * 1000
        }

        let quantity = HKQuantity(unit: unit, doubleValue: amount)
        if unit.unitString == HKUnit.calorie().unitString {
            object.amount = quantity.doubleValue(for: HKUnit.calorie()) // get value in calories
            object.customUnits = HKUnit.calorie()
        }
        else if unit.unitString == HKUnit.liter().unitString {
            object.amount = quantity.doubleValue(for: HKUnit.liter()) // get value in liter
            object.customUnits = HKUnit.liter()
        }
        else {
            object.amount = quantity.doubleValue(for: HKUnit.gram()) // get value in grams
        }
        return object
    }

    /// debug description
    override public var description: String {
        return "QuantitySample[amount=\(amount), type=\(type.id)]"
    }
}
