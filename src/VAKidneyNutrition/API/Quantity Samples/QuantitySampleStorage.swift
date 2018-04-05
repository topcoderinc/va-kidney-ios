//
//  QuantitySampleStorage.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/29/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import HealthKit

/**
 * QuantitySampleService implementation that tries to use HealthKit and if it fails, then uses LocalQuantitySampleService.
 *
 * - author: TCCODER
 * - version: 1.0
 */
class QuantitySampleStorage: QuantitySampleService {

    /// the singleton
    static let shared = QuantitySampleStorage()

    /// Add new sample
    ///
    /// - Parameters:
    ///   - sample: the sample
    ///   - callback: the callback to invoke when completed: true - successfully saved, false - else
    func addSample(_ sample: QuantitySample, callback: @escaping ((Bool)->())) {
        HealthKitUtil.shared.addSample(sample) { (success) in
            if success {
                callback(success)
            }
            else {
                LocalQuantitySampleService.shared.addSample(sample, callback: callback)
            }
        }
    }

    /// Get per month statistics
    ///
    /// - Parameters:
    ///   - quantityType: the quantityType
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getPerMonthStatistics(_ quantityType: QuantityType, callback: @escaping ([(Date, Double)], String)->(), customTypeCallback: @escaping ()->()) {
        HealthKitUtil.shared.getPerMonthStatistics(quantityType, callback: { data, unit in
            if data.isEmpty {
                LocalQuantitySampleService.shared.getPerMonthStatistics(quantityType, callback: callback, customTypeCallback: customTypeCallback)
            }
            else {
                callback(data, unit)
            }
        }, customTypeCallback: {
            LocalQuantitySampleService.shared.getPerMonthStatistics(quantityType, callback: callback, customTypeCallback: customTypeCallback)
        })
    }

    /// Get today statistics
    ///
    /// - Parameters:
    ///   - quantityType: the quantity type
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getTodayStatistics(_ quantityType: QuantityType, callback: @escaping (HKQuantity)->(), customTypeCallback: @escaping ()->()) {
        HealthKitUtil.shared.getTodayStatistics(quantityType, callback: { quantity in
            let value = quantity.doubleValue(for: HealthKitUtil.shared.getUnit(forType: quantityType))
            if value > 0 {
                callback(quantity)
            }
            else {
                LocalQuantitySampleService.shared.getTodayStatistics(quantityType, callback: callback, customTypeCallback: customTypeCallback)
            }
        }) {
            LocalQuantitySampleService.shared.getTodayStatistics(quantityType, callback: callback, customTypeCallback: customTypeCallback)
        }
    }

    /// Check if has data for given type
    ///
    /// - Parameters:
    ///   - quantityType: the quantityType
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func hasData(_ quantityType: QuantityType, callback: @escaping (Bool)->(), customTypeCallback: @escaping ()->()) {
        HealthKitUtil.shared.hasData(quantityType, callback: { result in
            if !result {
                LocalQuantitySampleService.shared.hasData(quantityType, callback: callback, customTypeCallback: customTypeCallback)
            }
            else {
                callback(result)
            }
        }, customTypeCallback: {
            LocalQuantitySampleService.shared.hasData(quantityType, callback: callback, customTypeCallback: customTypeCallback)
        })
    }
}
