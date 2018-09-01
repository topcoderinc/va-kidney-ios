//
//  CachingServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON
import HealthKit

/// option: true - will show weight measurement warning for patients who are not on dialysis only, false - will always show that warning.
let OPTION_SHOW_CHART_INFO_FOR_NOT_IN_DIALYSIS_PATIENTS = false

/**
 * Caching implementation of ServiceApi that wraps another (actual) service implementation.
 * Each method first tries to use cached data, but if it's expired, then requests API and cache it.
 *
 * - author: TCCODER
 * - version: 1.4
 *
 * changes:
 * 1.1:
 * - UI changes support
 *
 * 1.2:
 * - integration related changes
 *
 * 1.3:
 * - changes in API
 * - bug fixes
 * 1.4:
 * - new API methods
 */
class CachingServiceApi: ServiceApi {

    /// the singleton
    static let shared: CachingServiceApi = CachingServiceApi(service: MockServiceApi.shared)

    /// the wrapped service
    private let service: ServiceApi

    /// Core Data services
    private let userInfoService = UserInfoServiceCache()
    private let profileService = ProfileServiceCache()
    private let goalServiceCache = GoalServiceCache()
    private let foodServiceCache = FoodServiceCache()
    private let foodItemServiceCache = FoodItemServiceCache()
    internal let medicationResourceService = RecommendationServiceCache()

    /// Initializer
    ///
    /// - Parameter service: the wrapped service
    private init(service: ServiceApi) {
        self.service = service
    }
    
    /// Authenticate using given email and password
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - password: the password
    ///   - callback: the callback to invoke when successfully authenticated and return UserInfo and Profile
    ///   - failure: the callback to invoke when an error occurred
    func authenticate(email: String, password: String, callback: @escaping (UserInfo) -> (), failure: @escaping (String?, String?)->()) {
        if !ValidationUtils.validateStringNotEmpty(email, { error in failure(ERROR_EMPTY_CREDENTIALS, nil) })
            || !ValidationUtils.validateEmail(email, { error in failure(error, nil) })
            || !ValidationUtils.validateStringNotEmpty(password, { error in failure(nil, ERROR_EMPTY_CREDENTIALS) }) {
            return
        }

        // Check the cached accounts
        self.userInfoService.getAll({ list in
            for userInfo in list {
                if userInfo.email == email && userInfo.password == password {
                    AuthenticationUtil.sharedInstance.userInfo = userInfo
                    
                    // update `retrievalDate`
                    userInfo.retrievalDate = Date()
                    self.userInfoService.update([userInfo], success: {}, failure: { error in
                        print("ERROR: \(error.localizedDescription)")
                    })
                    
                    callback(userInfo)
                    return
                }
            }
            /// Check demo account
            self.service.authenticate(email: email, password: password, callback: { userInfo in
                AuthenticationUtil.sharedInstance.userInfo = userInfo
                self.getProfile(callback: { (profile) in
                    self.updateProfile(profile, callback: {
                        callback(userInfo)
                    }, failure: { error in failure(error, error) })
                }, failure: { error in failure(error, error) })
            }, failure: failure)
        }, failure: wrapFailure({ (error) in
            failure(error, error)
        }))
    }

    /// Check if account not exists and verify the used field
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - password: the password
    ///   - confirmPassword: the password from the second field
    ///   - callback: the callback to invoke when success (the new account can be created)
    ///   - failure: the failure callback to return an error
    func checkIfAccountCanBeCreated(email: String, password: String, confirmPassword: String, callback: @escaping (UserInfo) -> (), failure: @escaping FailureCallback) {
        service.checkIfAccountCanBeCreated(email: email, password: password, confirmPassword: confirmPassword, callback: {userInfo in

            // Check the existing accounts
            self.userInfoService.getAll({ list in
                for userInfo in list {
                    if userInfo.email == email {
                        failure(ERROR_ACCOUNT_EXISTS_EMAIL)
                        return
                    }
                }
                callback(userInfo)
            }, failure: self.wrapFailure(failure))
        }, failure: failure)
    }

    /// Register account. Will "remember" password.
    ///
    /// - Parameters:
    ///   - userInfo: the user info
    ///   - profile: the profile
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func register(userInfo: UserInfo, profile: Profile, callback: @escaping (UserInfo) -> (), failure: @escaping FailureCallback) {
        self.service.register(userInfo: userInfo, profile: profile, callback: { userInfo in

            // Save userInfo
            userInfo.firstName = profile.name
            self.userInfoService.insert([userInfo], success: { userInfoMO in
                AuthenticationUtil.sharedInstance.userInfo = userInfo

                self.updateProfile(profile, callback: {
                    callback(userInfo)
                }, failure: self.wrapFailure(failure))
            }, failure: self.wrapFailure(failure))
        }, failure: failure)
    }

    /// Get profile
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getProfile(callback: @escaping (Profile) -> (), failure: @escaping FailureCallback) {
        let callback: (Profile) -> () = { profile in
            HealthKitUtil.shared.getHKProfile(callback: { (hkProfile) in
                profile.merge(with: hkProfile)
                callback(profile)
            })
        }
        self.profileService.getMyProfiles(callback: { (profiles) in
            if let profile = profiles.first {
                callback(profile)
            }
            else {
                self.service.getProfile(callback: callback, failure: failure)
            }
        }, failure: wrapFailure(failure))
    }
    
    /// Get last used profile
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getLastAccount(callback: @escaping (UserInfo?) -> (), failure: @escaping FailureCallback) {
        self.userInfoService.getLastProfile(callback: callback, failure: wrapFailure(failure))
    }

    /// Update profile. R->C
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func updateProfile(_ profile: Profile, callback: @escaping () -> (), failure: @escaping FailureCallback) {
        let callback: () -> () = {
            HealthKitUtil.shared.saveHKProfile(profile: profile, callback: callback)
        }
        self.profileService.getMyProfiles(callback: { (list) in
            if let _ = list.last {
                profile.retrievalDate = Date()
                self.profileService.update([profile], success: {
                    callback()
                }, failure: self.wrapFailure(failure))
            }
            else {
                self.profileService.insert([profile], success: { (_) in
                    callback()
                }, failure: self.wrapFailure(failure))
            }
        }, failure: self.wrapFailure(failure))
    }

    /// Initiate password reset
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func forgotPassword(email: String, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        service.forgotPassword(email: email, callback: callback, failure: failure)
    }

    /// Logout
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func logout(callback: @escaping ()->(), failure: @escaping FailureCallback) {
        service.logout(callback: callback, failure: failure)
        removeAll(callback: {}, failure: failure)
    }

    /// Remove all Core Data objects
    ///
    /// - Parameters:
    ///   - callback: the callback to invoken when success
    ///   - failure: the failure block
    func removeAll(callback: @escaping ()->(), failure: @escaping FailureCallback) {
        callback()
    }

    /// Get goals
    ///
    /// - Parameters:
    ///   - profile: the profile
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getGoals(profile: Profile? = nil, callback: @escaping ([Goal])->(), failure: @escaping FailureCallback) {
        goalServiceCache.getAllGoals(callback: { (goals) in
            // Get sample data for the first time
            if self.goalServiceCache.isExpired(goals, timeInterval: nil) {

                self.profileService.getMyProfiles(callback: { (profiles) in
                    self.service.getGoals(profile: profile ?? profiles.first, callback: { (goals) in

                        // Cache data
                        self.goalServiceCache.insert(goals, success: { (goals) in

                            callback(goals)
                        }, failure: self.wrapFailure(failure))

                    }, failure: failure)
                }, failure: self.wrapFailure(failure))
            }
            else {
                callback(goals)
            }
        }, failure: wrapFailure(failure))
    }

    /// Get goal patterns (for "Add Goal" screen)
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getGoalPatterns(profile: Profile?, callback: @escaping ([Goal]) -> (), failure: @escaping FailureCallback) {
        service.getGoalPatterns(profile: profile, callback: callback, failure: failure)
    }

    /// Save goal
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func saveGoal(goal: Goal, callback: @escaping (Goal)->(), failure: @escaping FailureCallback) {
        if goal.id.isEmpty {
            goal.id = UUID().uuidString
            goalServiceCache.insert([goal], success: { (cachedGoals) in
                callback(cachedGoals.first!)
            }, failure: wrapFailure(failure))
        }
        else {
            goalServiceCache.upsert([goal], success: { (goals) in
                callback(goals.first!)
            }, failure: wrapFailure(failure))
        }
    }

    /// Save goal
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func saveGoals(goals: [Goal], callback: @escaping ([Goal]) -> (), failure: @escaping FailureCallback) {
        goalServiceCache.upsert(goals, success: { (goals) in
            callback(goals)
        }, failure: wrapFailure(failure))
    }

    /// Delete goal
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func deleteGoal(goal: Goal, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        service.deleteGoal(goal: goal, callback: {
            self.goalServiceCache.delete([goal], success: callback, failure: self.wrapFailure(failure))
        }, failure: failure)
    }

    /// Generate goals
    ///
    /// - Parameters:
    ///   - profile: the profile
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func generateGoals(profile: Profile?, callback: @escaping ([Goal])->(), failure: @escaping FailureCallback) {
        resetAllGoals(callback: {

            self.profileService.getMyProfiles(callback: { (profiles) in
                self.service.generateGoals(profile: profile ?? profiles.first, callback: { (goals) in

                    // Cache data
                    self.goalServiceCache.insert(goals, success: { (goals) in

                        callback(goals)
                    }, failure: self.wrapFailure(failure))

                }, failure: failure)
            }, failure: self.wrapFailure(failure))
        }, failure: failure)
    }

    /// Reset all goals
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func resetAllGoals(callback: @escaping ()->(), failure: @escaping FailureCallback) {
        service.resetAllGoals(callback: {
            self.goalServiceCache.removeAllGoals(callback: callback, failure: self.wrapFailure(failure))
        }, failure: failure)
    }

    /// Get dashboard info
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getDashboardInfo(callback: @escaping ([HomeInfo])->(), failure: @escaping FailureCallback) {
        // Get measurements
        self.getRequiredMeasurements(profile: nil, callback: { (measurements) in
            var list = measurements.map({HomeInfo.fromMeasurement($0)})

            // Get goals
            self.getGoals(profile: nil, callback: { (goals) in
                list.append(contentsOf: goals.map({HomeInfo.fromGoal($0)}))
                callback(list)
            }, failure: failure)
        }, failure: failure)
    }

    /// Get required measurements
    ///
    /// - Parameters:
    ///   - profile: the profile
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getRequiredMeasurements(profile: Profile?, callback: @escaping ([Measurement])->(), failure: @escaping FailureCallback) {
        let callback: (Profile?)->() = { profile in
            if let profile = profile, let json = JSON.resource(named: "measurements") {
                let all = json.arrayValue.map({Measurement.fromJson($0)})
                let list = all.filter({$0.comorbidCondition != nil && profile.comorbidities.contains($0.comorbidCondition!)})

                let g = DispatchGroup()
                for item in list {
                    if OPTION_SHOW_CHART_INFO_FOR_NOT_IN_DIALYSIS_PATIENTS && profile.dialysis {
                        item.info = nil
                    }
                    for id in item.relatedQuantityIds {
                        g.enter()
                        let type = QuantityType.fromId(id)
                        QuantitySampleStorage.shared.getTodayData(type, callback: { (quantity, unit) in
                            if let quantity = quantity {
                                let value = quantity.doubleValue(for: unit)
                                item.setQuantityValue(value)
                            }
                            g.leave()
                        }, customTypeCallback: {
                            g.leave()
                        })
                    }
                }
                g.notify(queue: .main, execute: {
                    callback(list)
                })
            }
            else {
                callback([])
            }
        }
        if let profile = profile { callback(profile) }
        else {
            self.profileService.getMyProfiles(callback: { (profiles) in
                callback(profiles.first)
            }, failure: self.wrapFailure(failure))
        }
    }

    /// Get reports
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getReports(callback: @escaping ([Report])->(), failure: @escaping FailureCallback) {
        service.getReports(callback: callback, failure: failure)
    }
    
    /// Get previous and next reports
    ///
    /// - Parameters:
    ///   - report: the reference report
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getNearbyReports(report: Report, callback: @escaping (Report?, Report?)->(), failure: @escaping FailureCallback) {
        service.getNearbyReports(report: report, callback: callback, failure: failure)
    }

    /// Get suggestion for the report
    ///
    ///   - report: the reference report
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getSuggestion(forReport report: Report, callback: @escaping (Suggestion?)->(), failure: @escaping FailureCallback) {
        service.getSuggestion(forReport: report, callback: callback, failure: failure)
    }

    /// Get suggestions for Home screen
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getMainSuggestions(callback: @escaping ([Suggestion])->(), failure: @escaping FailureCallback) {
        service.getMainSuggestions(callback: callback, failure: failure)
    }

    /// Get rewards
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getRewards(callback: @escaping ([Reward])->(), failure: @escaping FailureCallback) {
        service.getRewards(callback: callback, failure: failure)
    }

    /// Get goal units
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getUnits(goal: Goal, callback: @escaping (TaskUnitLimits, TaskUnitSuffix, TaskExtraData)->(), failure: @escaping FailureCallback) {
        service.getUnits(goal: goal, callback: callback, failure: failure)
    }

    // MARK: - Medication

    /// Get schedule
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success: (hour, list of medications)
    ///   - failure: the failure callback to return an error
    func getMedicationScheduleForToday(callback: @escaping ([MedicationScheduleItem])->(), failure: @escaping FailureCallback) {
        service.getMedicationScheduleForToday(callback: callback, failure: failure)
    }

    /// Get medications
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success: (list of medications)
    ///   - failure: the failure callback to return an error
    func getMedicationForToday(callback: @escaping ([Medication])->(), failure: @escaping FailureCallback) {
        service.getMedicationForToday(callback: callback, failure: failure)
    }

    /// Save medication resource
    ///
    /// - Parameters:
    ///   - item: the item
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    private func saveRecommendation(_ item: Recommendation, callback: @escaping (Recommendation)->(), failure: @escaping FailureCallback) {
        medicationResourceService.upsert([item], success: { (list) in
            callback(list.first!)
        }, failure: wrapFailure(failure))
    }

    /// Get resources
    ///
    ///   - type: the type
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getResources(type: ResourceType, callback: @escaping ([Resource])->(), failure: @escaping FailureCallback) {
        service.getResources(type: type, callback: callback, failure: failure)
    }

    /// Get goal form tips
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getGoalTip(callback: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        service.getGoalTip(callback: callback, failure: failure)
    }

    // MARK: - Food

    /// Get food for "Food Intake" screen
    ///
    /// - Parameters:
    ///   - date: the date
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getFood(date: Date?, callback: @escaping ([Food])->(), failure: @escaping FailureCallback) {
        foodServiceCache.getAll(date: date, callback: { (items) in
            callback(items)
        }, failure: wrapFailure(failure))
    }

    /// Save food intake
    ///
    /// - Parameters:
    ///   - food: the food to save
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func saveFood(food: Food, callback: @escaping (Food)->(), failure: @escaping FailureCallback) {
        if food.id.isEmpty {
            food.id = UUID().uuidString
        }
        foodItemServiceCache.upsert(food.items, success: { (items) in
            food.items = items
            let predicate = self.foodItemServiceCache.createStringArrayPredicate("id", value: items.map { $0.id })
            self.foodItemServiceCache.getMO(withPredicate: predicate, { (itemsMO) in
                self.foodServiceCache.upsert([food], relatedObjects: itemsMO, success: { (cached) in
                    callback(cached.first!)
                }, failure: self.wrapFailure(failure))
            }, failure: self.wrapFailure(failure))
        }, failure: wrapFailure(failure))
    }

    // MARK: - Workout

    /// Get Workouts
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getWorkout(callback: @escaping ([Workout])->(), failure: @escaping FailureCallback) {
        service.getWorkout(callback: callback, failure: failure)
    }

    // MARK: - Lab values

    /// Get possible lab values
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getLabValues(callback: @escaping ([[QuantityType]])->(), failure: @escaping FailureCallback) {
        self.profileService.getMyProfiles(callback: { (profiles) in
            let allLabValues = HealthKitUtil.shared.getLabValues(profile: profiles.last)
            callback(allLabValues)
        }, failure: self.wrapFailure(failure))
    }

    // MARK: - Private methods

    /// Wrap FailureCallback
    ///
    /// - Parameter failure: FailureCallback
    /// - Returns: GeneralFailureBlock
    internal func wrapFailure(_ failure: @escaping FailureCallback) -> GeneralFailureBlock {
        return { error in
            failure(error.localizedDescription)
        }
    }
}
