//
//  LocalQuantitySampleService.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/29/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import HealthKit

/**
 * QuantitySampleService implementation that read/save data from local storage (not from HealthKit)
 *
 * - author: TCCODER
 * - version: 1.0
 */
class LocalQuantitySampleService: QuantitySampleService {

    /// Core Data service to read/store data
    private var quantitySampleService = QuantitySampleCache()

    /// the singleton
    static let shared = LocalQuantitySampleService()

    /// Private initializer
    private init() {}

    /// Add new sample
    ///
    /// - Parameters:
    ///   - sample: the sample
    ///   - callback: the callback to invoke when completed: true - successfully saved, false - else
    func addSample(_ sample: QuantitySample, callback: @escaping ((Bool)->())) {
        quantitySampleService.insert([sample], success: { (_) in
            callback(true)
            print("addSample: saved locally \(sample)")
        }) { (error) in
            print("ERROR:addSample: \(error)")
            callback(false)
        }
    }

    /// Get per month statistics
    ///
    /// - Parameters:
    ///   - quantityType: the quantityType
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getPerMonthStatistics(_ quantityType: QuantityType, callback: @escaping ([(Date, Double)], String)->(), customTypeCallback: @escaping ()->()) {
        let now = Date()
        let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: now)!

        let unit = HealthKitUtil.shared.getUnit(forType: quantityType).unitString
        quantitySampleService.getAll(from: lastYear, to: now, ofType: quantityType, callback: { (samples) in
            var converted = [(Date, Double)]()
            for item in samples {
                converted.append((item.createdAt, item.amount))
            }
            callback(converted, unit)
        }, failure: { (error) in
            print("ERROR:getPerMonthStatistics: \(error)")
            callback([], unit)
        })
    }

    /// Get today statistics
    ///
    /// - Parameters:
    ///   - quantityType: the quantity type
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getTodayStatistics(_ quantityType: QuantityType, callback: @escaping (HKQuantity)->(), customTypeCallback: @escaping ()->()) {
        let todayStart = Calendar.current.date(from: Calendar.current.dateComponents([.month, .year, .day], from: Date()))!
        quantitySampleService.getAll(from: todayStart, to: Date(), ofType: quantityType, callback: { (samples) in
            var value: Double = 0
            for item in samples {
                value += item.amount
            }
            let quantity = HKQuantity(unit: HealthKitUtil.shared.getUnit(forType: quantityType), doubleValue: value)
            callback(quantity)
        }, failure: { (error) in
            print("ERROR:getTodayStatistics: \(error)")
            customTypeCallback()
        })
    }

    /// Check if has data for given type
    ///
    /// - Parameters:
    ///   - quantityType: the quantityType
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func hasData(_ quantityType: QuantityType, callback: @escaping (Bool)->(), customTypeCallback: @escaping ()->()) {
        let now = Date()
        let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: now)!

        quantitySampleService.getAll(from: lastYear, to: now, ofType: quantityType, callback: { (samples) in
            callback(!samples.isEmpty)
        }, failure: { (error) in
            print("ERROR:hasData: \(error)")
            callback(false)
        })
    }
}
