//
//  QuantitySampleService.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/29/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import HealthKit

/**
 * Protocol for service that allows to save and fetch Quantity Samples.
 * Has two main implementations: HealthKitUtil and LocalQuantitySampleService.
 * Also there is a decorator implementation QuantitySampleStorage
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - new API methods
 */
protocol QuantitySampleService {

    /// Add new sample
    ///
    /// - Parameters:
    ///   - sample: the sample
    ///   - callback: the callback to invoke when completed: true - successfully saved, false - else
    func addSample(_ sample: QuantitySample, callback: @escaping ((Bool)->()))

    /// Get per month statistics
    ///
    /// - Parameters:
    ///   - quantityType: the quantityType
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getPerMonthStatistics(_ quantityType: QuantityType, callback: @escaping ([(Date, Double)], String)->(), customTypeCallback: @escaping ()->())

    /// Get today statistics
    ///
    /// - Parameters:
    ///   - quantityType: the quantity type
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getTodayStatistics(_ quantityType: QuantityType, callback: @escaping (HKQuantity)->(), customTypeCallback: @escaping ()->())

    /// Check if has data for given type
    ///
    /// - Parameters:
    ///   - quantityType: the quantityType
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func hasData(_ quantityType: QuantityType, callback: @escaping (Bool)->(), customTypeCallback: @escaping ()->())

    /// Get data for today
    ///
    /// - Parameters:
    ///   - quantityType: the quantityType
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getTodayData(_ quantityType: QuantityType, callback: @escaping (HKQuantity?, HKUnit)->(), customTypeCallback: @escaping ()->())

    /// Get discrete values
    ///
    /// - Parameters:
    ///   - quantityType: the quantity type
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getDiscreteValues(_ quantityType: QuantityType, callback: @escaping ([(Date, Double)], String)->(), customTypeCallback: @escaping ()->())
}
