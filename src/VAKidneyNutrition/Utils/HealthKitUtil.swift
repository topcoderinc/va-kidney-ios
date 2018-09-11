//
//  HealthKitUtil.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/3/18.
//  Modified by TCCODER on 4/1/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON
import HealthKit

/**
 * Util that simplifies access to HealthKit storage data
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - QuantitySampleService protocol support
 * - crash fixed
 *
 * 1.2:
 * - new API methods
 * - new types supported
 */
class HealthKitUtil: QuantitySampleService {

    /// the singleton
    static let shared = HealthKitUtil()

    /// the reference to HKHealthStore
    var healthStore: HKHealthStore!

    /// Initializer
    init() {
        healthStore = HKHealthStore()

    }

    /// Authorize HealthKit
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func authorizeHealthKit(callback: @escaping (Bool)->(), failure: @escaping FailureCallback) {
        guard HKHealthStore.isHealthDataAvailable() else { failure("HealthKit not available on the device"); return }

        var shareableTypes = Set<HKSampleType>([
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)!,

            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!
            ])
        var readableTypes = Set<HKObjectType>([
            HKObjectType.activitySummaryType(),
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,

            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,

            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)!,

            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!
            ])

        let allLabIds = getAllLabValueIds().map{HKObjectType.quantityType(forIdentifier: $0)!}
        for item in allLabIds {
            shareableTypes.insert(item)
        }
        for item in allLabIds {
            readableTypes.insert(item)
        }

        healthStore.requestAuthorization(toShare: shareableTypes, read: (readableTypes)) { (fin, error) in
            DispatchQueue.main.async {
                if let error = error {
                    failure(error.localizedDescription)
                }
                else {
                    callback(true)
                }
            }
        }
    }

    // MARK: - Profile

    /// Get profile
    ///
    /// - Parameter callback: the callback to invoke when success
    func getHKProfile(callback: @escaping (Profile)->()) {
        let profile = Profile(id: "")
        if let (_, date) = HealthKitUtil.shared.getUserAgeAndBirth() {
            profile.birthday = date
        }
        HealthKitUtil.shared.getHeight { (height) in
            if let height = height {
                profile.height = height
            }
            HealthKitUtil.shared.getWeight(callback: { (weight) in
                if let weight = weight {
                    profile.currentWeight = weight
                }
                DispatchQueue.main.async {
                    callback(profile)
                }
            })
        }
    }

    /// Save some profile data in HK
    ///
    /// - Parameters:
    ///   - profile: the profile
    ///   - callback: the callback to invoke when completed
    func saveHKProfile(profile: Profile, callback: @escaping ()->()) {
        let height = HKQuantity(unit: HKUnit.inch(), doubleValue: Double(profile.height))
        let weight = HKQuantity(unit: HKUnit.pound(), doubleValue: Double(profile.currentWeight))
        saveItem(identifier: HKQuantityTypeIdentifier.height, quantity: height) { (_) in
            self.saveItem(identifier: HKQuantityTypeIdentifier.bodyMass, quantity: weight) { (_) in
                DispatchQueue.main.async {
                    callback()
                }
            }
        }
    }

    /// Get user age and birthday
    ///
    /// - Returns: the data
    func getUserAgeAndBirth() -> (Int, Date)? {
        if var birthDateComponents = try? healthStore.dateOfBirthComponents() {
            birthDateComponents.calendar = Calendar.current
            if let birthDate = birthDateComponents.date {
                print("userAge: birthDate: \(birthDate)")
                let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
                if let userAge = ageComponents.year {
                    return (userAge, birthDate)
                }
            }
        }
        return nil
    }

    /// Get height in inches
    ///
    ///   - callback: the callback to return data
    func getHeight(callback: @escaping (Double?)->()) {
        getMostResent(identifier: HKQuantityTypeIdentifier.height) { (sample) in
            callback(sample?.quantity.doubleValue(for: HKUnit.inch()))
        }
    }

    /// Get weight in pounds
    ///
    ///   - callback: the callback to return data
    func getWeight(callback: @escaping (Double?)->()) {
        getMostResent(identifier: HKQuantityTypeIdentifier.bodyMass) { (sample) in
            callback(sample?.quantity.doubleValue(for: HKUnit.pound()))
        }
    }

    // MARK: - Workout

    /// Get number of steps today
    ///
    /// - Parameter callback: the callback to return data
    func getSteps(callback: @escaping (Int)->()) {
        getSummaryActivity(identifier: HKQuantityTypeIdentifier.stepCount) { (sample) in
            let steps = Int(sample?.doubleValue(for: HKUnit.count()) ?? 0)
            callback(steps)
        }
    }

    /// Get summary distance of running
    ///
    /// - Parameter callback: the callback to return data
    func getDistance(callback: @escaping (Double)->()) {
        getSummaryActivity(identifier: HKQuantityTypeIdentifier.distanceWalkingRunning) { (sample) in
            let miles = sample?.doubleValue(for: HKUnit.mile()) ?? 0
            callback(miles)
        }
    }

    /// Get summary flights climbed
    ///
    /// - Parameter callback: the callback to return data
    func getFlights(callback: @escaping (Double)->()) {
        getSummaryActivity(identifier: HKQuantityTypeIdentifier.flightsClimbed) { (sample) in
            let flights = sample?.doubleValue(for: HKUnit.count()) ?? 0
            callback(flights)
        }
    }

    /// Get summary activity for given activity identifier
    ///
    /// - Parameters:
    ///   - identifier: the ID
    ///   - callback: the callback to return data
    func getSummaryActivity(identifier: HKQuantityTypeIdentifier, callback: @escaping (HKQuantity?)->()) {
        let type = HKObjectType.quantityType(forIdentifier: identifier)!
        let today = createTodayPredicateForActivitySummary()
        let sumOptions = HKStatisticsOptions.cumulativeSum
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: today, options: sumOptions) { (query, result, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            let sum = result?.sumQuantity()
            print("getSummaryActivity: \(String(describing: sum))")
            DispatchQueue.main.async {
                callback(sum)
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Lab values (QuantitySampleService)

    /// Get all IDs for lab values
    ///
    /// - Returns: the list
    private func getAllLabValueIds() -> [HKQuantityTypeIdentifier] {
        return [
            HKQuantityTypeIdentifier.dietaryEnergyConsumed,
            HKQuantityTypeIdentifier.dietaryFatTotal,
            HKQuantityTypeIdentifier.dietaryFatPolyunsaturated,
            HKQuantityTypeIdentifier.dietaryFatMonounsaturated,
            HKQuantityTypeIdentifier.dietaryFatSaturated,
            HKQuantityTypeIdentifier.dietaryCholesterol,
            HKQuantityTypeIdentifier.dietarySodium,
            HKQuantityTypeIdentifier.dietaryCarbohydrates,
            HKQuantityTypeIdentifier.dietaryFiber,
            HKQuantityTypeIdentifier.dietarySugar,
            HKQuantityTypeIdentifier.dietaryProtein,
            HKQuantityTypeIdentifier.dietaryVitaminA,
            HKQuantityTypeIdentifier.dietaryVitaminB6,
            HKQuantityTypeIdentifier.dietaryVitaminB12,
            HKQuantityTypeIdentifier.dietaryVitaminC,
            HKQuantityTypeIdentifier.dietaryVitaminD,
            HKQuantityTypeIdentifier.dietaryVitaminE,
            HKQuantityTypeIdentifier.dietaryVitaminK,
            HKQuantityTypeIdentifier.dietaryCalcium,
            HKQuantityTypeIdentifier.dietaryIron,
            HKQuantityTypeIdentifier.dietaryThiamin,
            HKQuantityTypeIdentifier.dietaryRiboflavin,
            HKQuantityTypeIdentifier.dietaryNiacin,
            HKQuantityTypeIdentifier.dietaryFolate,
            HKQuantityTypeIdentifier.dietaryBiotin,
            HKQuantityTypeIdentifier.dietaryPantothenicAcid,
            HKQuantityTypeIdentifier.dietaryPhosphorus,
            HKQuantityTypeIdentifier.dietaryIodine,
            HKQuantityTypeIdentifier.dietaryMagnesium,
            HKQuantityTypeIdentifier.dietaryZinc,
            HKQuantityTypeIdentifier.dietarySelenium,
            HKQuantityTypeIdentifier.dietaryCopper,
            HKQuantityTypeIdentifier.dietaryManganese,
            HKQuantityTypeIdentifier.dietaryChromium,
            HKQuantityTypeIdentifier.dietaryMolybdenum,
            HKQuantityTypeIdentifier.dietaryChloride,
            HKQuantityTypeIdentifier.dietaryPotassium,
            HKQuantityTypeIdentifier.dietaryCaffeine,
            HKQuantityTypeIdentifier.dietaryWater,
        ]
    }


    /// Get lab values
    ///
    /// - Returns: the list of all lab values
    func getLabValues(profile: Profile?) -> [[QuantityType]] {
        let allHKIds = getAllLabValueIds()
        var allIds = allHKIds.map({$0.rawValue})
        allIds.append(contentsOf: [
            QuantityTypeCustom.alcohol.rawValue,
            QuantityTypeCustom.meat.rawValue,
            QuantityTypeCustom.vegetables.rawValue,
            QuantityTypeCustom.bloodCholesterol.rawValue
            ])
        if let json = JSON.resource(named: "labValues") {
            let titlesToOverride = json["labValues"].arrayValue.hashmapWithKey({$0["id"].stringValue})

            if let profile = profile {
                let majorIds = (json["diseaseCategories"][profile.diseaseCategory].array ?? json["diseaseCategories"][profile.diseaseCategory + " \(profile.dialysis ? "yes" : "no")"].arrayValue).map({$0.stringValue})
                let minorIds = allIds.filter({!majorIds.contains($0)})
                let majorLabValues = majorIds.map({self.convertIdToLabValue(id: $0, titles: titlesToOverride)}).sorted(by: {$0.title < $1.title})
                let minorLabValues = minorIds.map({self.convertIdToLabValue(id: $0, titles: titlesToOverride)}).sorted(by: {$0.title < $1.title})
                return [majorLabValues, minorLabValues]
            }
            else {
                let majorLabValues = allIds.map({self.convertIdToLabValue(id: $0, titles: titlesToOverride)}).sorted(by: {$0.title < $1.title})
                return [majorLabValues, []]
            }
        }
        else {
            let majorLabValues = allIds.map({self.convertIdToLabValue(id: $0, titles: [:])}).sorted(by: {$0.title < $1.title})
            return [majorLabValues, []]
        }
    }

    /// Convert ID to LabValue
    ///
    /// - Parameters:
    ///   - id: theID
    ///   - titles: the title
    /// - Returns: LabValue
    private func convertIdToLabValue(id: String, titles: [String:JSON]) -> QuantityType {
        let object = QuantityType.fromId(id)
        object.title = titles[id]?["title"].string ?? id
        return object
    }

    /// Get per month statistics
    ///
    /// - Parameters:
    ///   - quantityType: the quantityType
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getPerMonthStatistics(_ quantityType: QuantityType, callback: @escaping ([(Date, Double)], String)->(), customTypeCallback: @escaping ()->()) {
        let type = HKQuantityTypeIdentifier(rawValue: quantityType.id)
        var unit: HKUnit!
        switch type {
        case HKQuantityTypeIdentifier.dietaryWater:
            unit = HKUnit.literUnit(with: HKMetricPrefix.milli)
        case HKQuantityTypeIdentifier.dietaryEnergyConsumed:
            unit = HKUnit.kilocalorie()
        default:
            unit = HKUnit.gramUnit(with: HKMetricPrefix.milli)
        }
        getPerMonthStatistics(identifier: type, callback: { (data) in
            var converted = [(Date, Double)]()
            for (k,quantity) in data {
                converted.append((k, quantity.doubleValue(for: unit)))
            }
            DispatchQueue.main.async {
                callback(converted, unit.unitString)
            }
        }, customTypeCallback: customTypeCallback)
    }

    /// Get per month statistics
    ///
    /// - Parameters:
    ///   - identifier: the ID
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getPerMonthStatistics(identifier: HKQuantityTypeIdentifier, callback: @escaping ([(Date, HKQuantity)])->(), customTypeCallback: @escaping ()->()) {
        if let type = HKQuantityType.quantityType(forIdentifier: identifier) {

            let componentFlags = Set<Calendar.Component>([.month])
            let now = Date()
            let lastYear = Calendar.current.date(from: Calendar.current.dateComponents([.era, .year, .month], from: Calendar.current.date(byAdding: .year, value: -1, to: now)!))!
            let nextReferencePeriodDate = Calendar.current.date(byAdding: .month, value: 1, to: lastYear)!
            let monthComponents = Calendar.current.dateComponents(componentFlags, from: lastYear, to: nextReferencePeriodDate)

            getStatistics(type: type, components: monthComponents, anchorDate: lastYear, toDate: now, callback: { (data) in
                if data.isEmpty {
                    print("Trying to fetch per-day statistics")
                    let componentFlags = Set<Calendar.Component>([.day])
                    let lastMonth = Calendar.current.date(from: Calendar.current.dateComponents([.era, .year, .month, .day], from: Calendar.current.date(byAdding: .month, value: -1, to: now)!))!
                    let nextReferencePeriodDate = Calendar.current.date(byAdding: .day, value: 1, to: lastMonth)!
                    let dayComponents = Calendar.current.dateComponents(componentFlags, from: lastMonth, to: nextReferencePeriodDate)
                    self.getStatistics(type: type, components: dayComponents, anchorDate: lastMonth, toDate: now, callback: callback)
                }
                else {
                    callback(data)
                }
            })
        }
        else {
            customTypeCallback()
        }
    }

    /// Get statistics
    ///
    /// - Parameters:
    ///   - type: the type
    ///   - components: the components
    ///   - anchorDate: the anchor date
    ///   - toDate: the and date
    ///   - callback: the callback to return data
    private func getStatistics(type: HKQuantityType, components: DateComponents, anchorDate: Date, toDate: Date, callback: @escaping ([(Date, HKQuantity)])->()) {
        let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: components)
        query.initialResultsHandler = { query, collection, error in
            if let error = error {
                print("getStatistics: ERROR: \(error.localizedDescription)")
            }
            var data = [(Date, HKQuantity)]()
            collection?.enumerateStatistics(from: anchorDate, to: toDate, with: { (statistics, _) in
                print("statistics: \(statistics)")
                if let quantity = statistics.sumQuantity() {
                    print("getStatistics: \(quantity)\n")
                    data.append((Date.getMeanDate(statistics.startDate, statistics.endDate), quantity))
                }
            })
            callback(data)
        }
        healthStore.execute(query)
    }

    /// Get today statistics
    ///
    /// - Parameters:
    ///   - quantityType: the quantity type
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getTodayStatistics(_ quantityType: QuantityType, callback: @escaping (HKQuantity)->(), customTypeCallback: @escaping ()->()) {
        if let type = HKQuantityType.quantityType(forIdentifier: quantityType.toHKType()) {

            let componentFlags = Set<Calendar.Component>([.day])
            let now = Date()
            let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: now)!
            let lastDayPlusDay = Calendar.current.date(byAdding: .day, value: 1, to: lastDay)!
            let components = Calendar.current.dateComponents(componentFlags, from: lastDay, to: lastDayPlusDay)

            let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: lastDay, intervalComponents: components)
            query.initialResultsHandler = { query, collection, error in
                if let error = error {
                    print("getTodayStatistics: ERROR: \(error.localizedDescription)")
                }
                if let collection = collection {
                    if let statistics = collection.statistics().first {
                        if let quantity = statistics.sumQuantity() {
                            print("getTodayStatistics: \(quantity)")
                            callback(quantity)
                            return
                        }
                    }
                }
                customTypeCallback()
            }
            healthStore.execute(query)
        }
        else {
            customTypeCallback()
        }
    }

    /// Check if has data for given type
    ///
    /// - Parameters:
    ///   - quantityType: the quantityType
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func hasData(_ quantityType: QuantityType, callback: @escaping (Bool)->(), customTypeCallback: @escaping ()->()) {
        if let type = HKQuantityType.quantityType(forIdentifier: quantityType.toHKType()) {

            let componentFlags = Set<Calendar.Component>([.day])
            let now = Date()
            let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: now)!
            let lastDayPlusDay = Calendar.current.date(byAdding: .day, value: 1, to: lastDay)!
            let components = Calendar.current.dateComponents(componentFlags, from: lastDay, to: lastDayPlusDay)

            getStatistics(type: type, components: components, anchorDate: lastDay, toDate: now, callback: { (data) in
                DispatchQueue.main.async {
                    callback(!data.isEmpty)
                }
            })
        }
        else {
            customTypeCallback()
        }
    }

    /// Get data for today
    ///
    /// - Parameters:
    ///   - quantityType: the quantityType
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getTodayData(_ quantityType: QuantityType, callback: @escaping (HKQuantity?, HKUnit)->(), customTypeCallback: @escaping ()->()) {
        let id = HKQuantityTypeIdentifier(rawValue: quantityType.id)
        if let type = HKQuantityType.quantityType(forIdentifier: id) {
            healthStore.preferredUnits(for: [type]) { (res, error) in
                if let error = error {
                    DispatchQueue.main.async { showError(errorMessage: error.localizedDescription) }
                }
                else if let unit = res[type] {
                    let lastMonth = self.createPredicate(daysBefore: 1)
                    let query = HKSampleQuery(sampleType: type, predicate: lastMonth, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                        if let error = error {
                            print("getDiscreteValues: ERROR: \(error.localizedDescription)")
                            customTypeCallback()
                        }
                        else {
                            let quantity = ((results ?? []).last as? HKQuantitySample)?.quantity
                            DispatchQueue.main.async { callback(quantity, unit)}
                        }
                    }
                    self.healthStore.execute(query)
                }
            }
        }
    }

    /// Get discrete values
    ///
    /// - Parameters:
    ///   - quantityType: the quantity type
    ///   - callback: the callback to return data
    ///   - customTypeCallback: the callback to invoke if custom type is requested
    func getDiscreteValues(_ quantityType: QuantityType, callback: @escaping ([(Date, Double)], String)->(), customTypeCallback: @escaping ()->()) {
        let id = HKQuantityTypeIdentifier(rawValue: quantityType.id)
        if let type = HKQuantityType.quantityType(forIdentifier: id) {
            healthStore.preferredUnits(for: [type]) { (res, error) in
                if let error = error {
                    DispatchQueue.main.async { showError(errorMessage: error.localizedDescription) }
                }
                else if let unit = res[type] {

                    let lastMonth = self.createPredicate(monthsBefore: 1)
                    let query = HKSampleQuery(sampleType: type, predicate: lastMonth, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                        if let error = error {
                            print("getDiscreteValues: ERROR: \(error.localizedDescription)")
                            customTypeCallback()
                        }
                        var data = [(Date, Double)]()
                        for item in results ?? [] {
                            if let sample = item as? HKQuantitySample {
                                let date = Date.getMeanDate(sample.startDate, sample.endDate)
                                let value = sample.quantity.doubleValue(for: unit)
                                data.append((date, value))
                            }
                        }
                        DispatchQueue.main.async{ callback(data, unit.unitString) }
                    }
                    self.healthStore.execute(query)
                }
            }
        }
        else {
            customTypeCallback()
        }
    }

    /// Create predicate for HK
    ///
    /// - Parameters:
    ///   - daysBefore: days before current date
    ///   - monthsBefore: months before current date
    /// - Returns: the predicate
    private func createPredicate(daysBefore: Int? = nil, monthsBefore: Int? = nil) -> NSPredicate {
        var startDate = Date().endOfDay()
        let calendar = Calendar.current
        if let days = daysBefore {
            startDate = calendar.date(byAdding: .day, value: -1 * days, to: startDate)!
        }
        if let months = monthsBefore {
            startDate = calendar.date(byAdding: .month, value: -1 * months, to: startDate)!
        }
        let endDate = calendar.date(byAdding: .day, value: 1, to: Date())
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
    }

    // MARK: - Units and IDs

    /// Get list of possible units for given type
    ///
    /// - Parameter type: the type
    /// - Returns: the units
    func getUnits(forType type: QuantityType) -> [String] {
        var units = [HKUnit]()
        switch type.id {
        case HKQuantityTypeIdentifier.dietaryWater.rawValue, QuantityTypeCustom.alcohol.rawValue:
            units = [
                HKUnit.literUnit(with: HKMetricPrefix.milli),
                HKUnit.liter(),
                HKUnit.literUnit(with: HKMetricPrefix.deci)
            ]
        case HKQuantityTypeIdentifier.dietaryEnergyConsumed.rawValue:
            units = [
                HKUnit.kilocalorie(),
                HKUnit.calorie()
            ]
        case HKQuantityTypeIdentifier.bloodGlucose.rawValue:
            units = [
                HKUnit(from: "mg/dL")
            ]
        case HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue, HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue:
            units = [
                HKUnit(from: "mmHg")
            ]
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            units = [
                HKUnit(from: "lb"),
                HKUnit.gramUnit(with: .kilo)
            ]
        default:
            units = [
                HKUnit.gramUnit(with: HKMetricPrefix.milli),
                HKUnit.gram()
            ]
        }
        return units.map({$0.unitString})
    }

    /// Get unit for given type
    ///
    /// - Parameter type: the type
    /// - Returns: the units
    func getUnit(forType type: QuantityType) -> HKUnit {
        switch type.id {
        case HKQuantityTypeIdentifier.dietaryWater.rawValue, QuantityTypeCustom.alcohol.rawValue:
            return HKUnit.liter()
        case HKQuantityTypeIdentifier.dietaryEnergyConsumed.rawValue:
            return HKUnit.calorie()
        default:
            return HKUnit.gram()
        }
    }

    /// Get food units
    ///
    /// - Returns: the list of units
    func getFoodUnits() -> [HKUnit] {
        let units = [HKUnit.ounce(), HKUnit.fluidOunceUS(),
                     HKUnit.gram(), HKUnit.gramUnit(with: HKMetricPrefix.milli),
                     HKUnit.liter(), HKUnit.literUnit(with: HKMetricPrefix.milli),
                     HKUnit.pound(), HKUnit.stone(),
                     HKUnit.cupUS(), HKUnit.pintUS()]
        return units
    }

    /// Get volume units
    ///
    /// - Returns: the list of units
    func getVolumeUnits() -> [HKUnit] {
        return [HKUnit.fluidOunceUS(), HKUnit.liter(), HKUnit.literUnit(with: HKMetricPrefix.milli), HKUnit.literUnit(with: HKMetricPrefix.deci), HKUnit.cupUS(), HKUnit.pintUS()]
    }

    /// Get mass units
    ///
    /// - Returns: the list of units
    func getMassUnits() -> [HKUnit] {
        return [HKUnit.ounce(), HKUnit.gram(), HKUnit.gramUnit(with: HKMetricPrefix.milli), HKUnit.gramUnit(with: HKMetricPrefix.kilo), HKUnit.pound(), HKUnit.stone(),]
    }

    /// Get unit by string
    ///
    /// - Parameter string: the string
    /// - Returns: the unit
    func getUnit(byString string: String) -> HKUnit? {
        let knownUnits = getFoodUnits()
        for unit in knownUnits {
            if string == unit.unitString {
                return unit
            }
        }
        print("ERROR: getUnit: Unknown unit")
        return nil
    }

    /// Get HK Id by raw nutrition title
    ///
    /// - Parameters:
    ///   - string: the ID
    ///   - cleaned: true - cleaned string (no spaces or other symbols)
    /// - Returns: HKQuantityTypeIdentifier
    func getId(byString string: String, cleaned: Bool = false) -> HKQuantityTypeIdentifier? {
        let map = getTitleByIdMap()
        let string = string.lowercased()
        for (id, title) in map {
            if string.contains(title.lowercased()) {
                return id
            }
        }
        if !cleaned {
            return getId(byString: string.replace("-", withString: ""), cleaned: true)
        }
        return nil
    }

    /// Get nutrition titles by ID
    ///
    /// - Returns: the map
    func getTitleByIdMap() -> [HKQuantityTypeIdentifier: String] {
        let allHKIds = getAllLabValueIds()
        if let json = JSON.resource(named: "labValues") {
            let titles = json["labValues"].arrayValue.hashmapWithKey({$0["id"].stringValue})
            var map = [HKQuantityTypeIdentifier: String]()
            for id in allHKIds {
                if let title = titles[id.rawValue]?["title"].string {
                    map[id] = title
                }
            }
            return map
        }
        return [:]
    }

    // MARK: - Save items (QuantitySampleService)

    /// Add new sample
    ///
    /// - Parameters:
    ///   - sample: the sample
    ///   - callback: the callback to invoke when completed: true - successfully saved, false - else
    func addSample(_ sample: QuantitySample, callback: @escaping ((Bool)->())) {
        addSample(id: sample.type.toHKType(), amount: sample.amount, unit: sample.getHKUnit(), date: sample.createdAt, callback: callback)
    }

    /// Add item into HK
    ///
    /// - Parameters:
    ///   - id: the ID
    ///   - amount: the amount
    ///   - unit: the unit
    ///   - date: the date
    func addSample(id: HKQuantityTypeIdentifier, amount: Double, unit: HKUnit, date: Date, callback: @escaping (Bool)->()) {
        if let type = HKQuantityType.quantityType(forIdentifier: id) {
            var amount = amount
            var unit = unit
            if id == HKQuantityTypeIdentifier.dietaryWater {
                if unit.unitString != HKUnit.liter().unitString {
                    unit = HKUnit.liter()
                    amount = amount / 1000 // 1000g in 1 liter
                }
            }
            /// If not `water` and `unit==L` (liter), then convert to gramms
            else if unit.unitString == HKUnit.liter().unitString {
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
            let quantity = HKQuantity(unit: unit, doubleValue: amount)
            let sample = HKQuantitySample.init(type: type, quantity: quantity, start: date, end: date, metadata: nil)
            healthStore.save(sample) { (success, error) in
                if let error = error {
                    print("addSample: ERROR: \(error.localizedDescription)")
                }
                if success {
                    print("addSample: Saved in HK \(sample) of \(id.rawValue)")
                    DispatchQueue.main.async {
                        callback(true)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        callback(false)
                    }
                }
            }
        }
        else {
            callback(false)
        }
    }

    // MARK: - Common

    /// Get most recent data for given ID
    ///
    /// - Parameters:
    ///   - identifier: the ID
    ///   - callback: the callback to return data
    private func getMostResent(identifier: HKQuantityTypeIdentifier, callback: @escaping (HKQuantitySample?)->()) {
        let type = HKQuantityType.quantityType(forIdentifier: identifier)!
        let sortByEndDate = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortByEndDate]) { (qeury, results, error) in
            let sample = results?.last
            print("getMostResent sample: \(String(describing: sample))")
            callback(sample as? HKQuantitySample)
        }
        healthStore.execute(query)
    }

    func getDataForLastYear(identifier: String, callback: ([HKQuantitySample])->()) {

    }

    /// Save sample
    ///
    /// - Parameters:
    ///   - identifier: the ID
    ///   - quantity: the quantity
    ///   - callback: the callback to invoke when completed
    func saveItem(identifier: HKQuantityTypeIdentifier, quantity: HKQuantity, callback: @escaping (Bool)->()) {

        let type = HKQuantityType.quantityType(forIdentifier: identifier)!
        let date = Date()
        let metaData: [String: Any] = [
            "userId": AuthenticationUtil.sharedInstance.userInfo?.id ?? ""
        ]
        let sample = HKQuantitySample.init(type: type, quantity: quantity, start: date, end: date, metadata: metaData)
        healthStore.save(sample) { (success, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            if success {
                print("saveItem: Saved \(sample)")
            }
            callback(success)
        }
    }

    /// Create predicate for current day or any day before
    ///
    /// - Parameter daysBefore: the number of days before. If 0, then today
    /// - Returns: the predicate
    private func createTodayPredicateForActivitySummary(daysBefore: Int = 0) -> NSPredicate {
        let date = Calendar.current.date(byAdding: .day, value: -1 * daysBefore, to: Date()) ?? Date()
        let componentFlags = Set<Calendar.Component>([.day, .month, .year, .era])
        let components = Calendar.current.dateComponents(componentFlags, from: date)
        let startDate = Calendar.current.date(from: components)!
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
    }

    /// Convert units to grams (Mass), L (Volume, only for water) or Calorie (Energy)
    ///
    /// - Parameters:
    ///   - units: current units
    ///   - amount: the amount
    /// - Returns: the normalized unit, value and mass flag
    class func normalizeUnits(units: String, amount: Double) -> (String, Double, Bool) {
        var units = units
        var amount = amount
        var isVolume = false
        for unit in HealthKitUtil.shared.getVolumeUnits() { if unit.unitString == units { isVolume = true; break } }

        var isMass = false
        for unit in HealthKitUtil.shared.getMassUnits() { if unit.unitString == units { isMass = true; break } }

        // Energy -> convert to calorie
        if units == HKUnit.kilocalorie().unitString || units == HKUnit.calorie().unitString || units == HKUnit.joule().unitString {
            let sample = HKQuantity(unit: HKUnit(from: units), doubleValue: amount)
            amount = sample.doubleValue(for: HKUnit.calorie())
            units = HKUnit.calorie().unitString
        }
        else if isVolume { // Volume -> convert to L
            let sample = HKQuantity(unit: HKUnit(from: units), doubleValue: amount)
            amount = sample.doubleValue(for: HKUnit.liter())
            units = HKUnit.liter().unitString
        }
        else if isMass { // Mass -> convert to grams
            let sample = HKQuantity(unit: HKUnit(from: units), doubleValue: amount)
            amount = sample.doubleValue(for: HKUnit.gram())
            units = HKUnit.gram().unitString
        }
        return (units, amount, isMass)
    }
}

/**
 * Helpful extension
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension HKUnit {

    /// Get human readable unit representation
    ///
    /// - Returns: the string
    func humanReadable() -> String {
        switch self.unitString {
        case HKUnit.ounce().unitString:
            return "oz (mass)"
        case HKUnit.cupUS().unitString:
            return "cups"
        case HKUnit.fluidOunceUS().unitString:
            return "oz (fluid)"
        case HKUnit.pintUS().unitString:
            return "pints"
        default:
            return self.unitString
        }
    }
}

/**
 * Helpful extension
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension String {

    /// Get human readable unit representation
    ///
    /// - Returns: the string
    func humanReadableUnit() -> String {
        return HKUnit(from: self).humanReadable()
    }
}
