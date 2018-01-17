//
//  CachingServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation

/**
 * Caching implementation of ServiceApi that wraps another (actual) service implementation.
 * Each method first tries to use cached data, but if it's expired, then requests API and cache it.
 *
 * - author: TCCODER
 * - version: 1.0
 */
class CachingServiceApi: ServiceApi {

    /// the singleton
    static let shared = CachingServiceApi(service: MockServiceApi.shared)

    /// the wrapped service
    private let service: ServiceApi

    /// Core Data services
    private let userInfoService = UserInfoServiceCache()
    private let profileService = ProfileServiceCache()
    private let goalServiceCache = GoalServiceCache()
    private let foodServiceCache = FoodServiceCache()

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
    func authenticate(email: String, password: String, callback: @escaping (UserInfo) -> (), failure: @escaping FailureCallback) {
        let emptyStringCallback: FailureCallback = { (_) -> () in
            failure(ERROR_EMPTY_CREDENTIALS)
        }
        if !ValidationUtils.validateEmail(email, emptyStringCallback)
            || !ValidationUtils.validateStringNotEmpty(password, emptyStringCallback) {
            return
        }

        // Check the cached accounts
        self.userInfoService.getAll({ list in
            for userInfo in list {
                if userInfo.email == email && userInfo.password == password {
                    AuthenticationUtil.sharedInstance.userInfo = userInfo
                    callback(userInfo)
                    return
                }
            }
            /// Check demo account
            self.service.authenticate(email: email, password: password, callback: callback, failure: failure)
        }, failure: self.wrapFailure(failure))
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
            self.userInfoService.insert([userInfo], success: { userInfoMO in
                AuthenticationUtil.sharedInstance.userInfo = userInfo

                self.profileService.insert([profile], success: { _ in
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
        self.profileService.getMyProfiles(callback: { (profiles) in
            if let profile = profiles.first {
                callback(profile)
            }
            else {
                failure(NSLocalizedString("Profile not found", comment: "Profile not found"))
            }
        }, failure: wrapFailure(failure))
    }

    /// Update profile. R->C
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func updateProfile(_ profile: Profile, callback: @escaping () -> (), failure: @escaping FailureCallback) {
        self.profileService.update([profile], success: callback, failure: self.wrapFailure(failure))
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
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getGoals(callback: @escaping ([Goal], [GoalCategory])->(), failure: @escaping FailureCallback) {
        goalServiceCache.getAllGoals(callback: { (goals) in
            self.service.getCategories(callback: { (categories) in

                // Get sample data for the first time
                if self.goalServiceCache.isExpired(goals, timeInterval: nil) {
                    self.service.getGoals(callback: { (goals, categories) in

                        // Cache data
                        self.goalServiceCache.insert(goals, success: { (goals) in

                            callback(goals, categories)
                        }, failure: self.wrapFailure(failure))

                    }, failure: failure)
                }
                else {
                    MockServiceApi.applyCategories(categories, toGoals: goals)
                    callback(goals, categories)
                }
            }, failure: failure)
        }, failure: wrapFailure(failure))
    }

    /// Get goal categories
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getCategories(callback: @escaping ([GoalCategory])->(), failure: @escaping FailureCallback) {
        self.service.getCategories(callback: callback, failure: failure)
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
            goalServiceCache.update([goal], success: {
                callback(goal)
            }, failure: wrapFailure(failure))
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

    /// Get suggestion for Home screen
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getMainSuggestion(callback: @escaping (Suggestion?)->(), failure: @escaping FailureCallback) {
        service.getMainSuggestion(callback: callback, failure: failure)
    }

    /// Get rewards
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getRewards(callback: @escaping ([Reward])->(), failure: @escaping FailureCallback) {
        service.getRewards(callback: callback, failure: failure)
    }

    /// Get tasks
    ///
    /// - Parameters:
    ///   - category: the category
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getTasks(category: GoalCategory, callback: @escaping ([Task])->(), failure: @escaping FailureCallback) {
        service.getTasks(category: category, callback: callback, failure: failure)
    }

    /// Get tasks
    ///
    /// - Parameters:
    ///   - task: the task
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getUnits(task: Task, callback: @escaping (TaskUnitLimits, TaskUnitSuffix) -> (), failure: @escaping FailureCallback) {
        service.getUnits(task: task, callback: callback, failure: failure)
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

    // MARK: - Food

    /// Get food for "Food Intake" screen
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getFood(callback: @escaping ([Food])->(), failure: @escaping FailureCallback) {
        foodServiceCache.getAll(callback: { (items) in
            // Get sample data for the first time
            if self.foodServiceCache.isExpired(items, timeInterval: nil) {
                self.service.getFood(callback: { (items) in

                    // Cache data
                    self.foodServiceCache.insert(items, success: { (items) in

                        callback(items)
                    }, failure: self.wrapFailure(failure))

                }, failure: failure)
            }
            else {
                callback(items)
            }
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
        foodServiceCache.upsert([food], success: { (cached) in
            callback(cached.first!)
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
    
    // MARK: - Private methods

    /// Wrap FailureCallback
    ///
    /// - Parameter failure: FailureCallback
    /// - Returns: GeneralFailureBlock
    private func wrapFailure(_ failure: @escaping FailureCallback) -> GeneralFailureBlock {
        return { error in
            failure(error.localizedDescription)
        }
    }
}
