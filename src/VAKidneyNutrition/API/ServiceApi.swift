//
//  ServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/// type alias for the callback used to return an occurred error
public typealias FailureCallback = (String)->()

/// type alias for a task
public typealias Task = String

/// type alias for suffixes for the units, e.g. ("mile", "miles", "Mile")
public typealias TaskUnitSuffix = (String, String, String)

/// type alias for extra data for the task renrering (iconUrl, color)
public typealias TaskExtraData = (String, UIColor)

/// type alias for limits  for the units, e.g. ((2, 12), 2)
public typealias TaskUnitLimits = (ClosedRange<Float>, Float)

/// type alias for one group of medications
public typealias MedicationScheduleItem = (Int, [(Medication, MedicationTime)])

/// error messages
let ERROR_EMPTY_CREDENTIALS = NSLocalizedString("Please provide valid email and password", comment: "Please provide valid email and password")
let ERROR_WRONG_CREDENTIALS = NSLocalizedString("The email and password you entered are incorrect. Please try again.", comment: "The email and password you entered are incorrect. Please try again.")
let ERROR_WRONG_CREDENTIALS_SIGNUP = NSLocalizedString("The credentials you entered are incorrect. Please fill the fields correctly.", comment: "The credentials you entered are incorrect. Please fill the fields correctly.")
let ERROR_PASSWORDS_NOT_MATCH = NSLocalizedString("The passwords do not match to each other", comment: "The passwords do not match to each other")

/**
 * Protocol for API implementaion
 *
 * - author: TCCODER
 * - version: 1.3
 *
 * changes:
 * 1.1:
 * - UI changes support
 *
 * 1.2:
 * - integration related changes
 *
 * 1.3:
 * - refactoring
 */
protocol ServiceApi {

    /// Authenticate using given email and password
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - password: the password
    ///   - callback: the callback to invoke when successfully authenticated and return UserInfo and Profile
    ///   - failure: the callback to invoke when an error occurred
    /// (nil,error) - password error
    /// (error,nil) - email error
    /// (error,error) - system error or ERROR_WRONG_CREDENTIALS
    func authenticate(email: String, password: String, callback: @escaping (UserInfo) -> (), failure: @escaping (String?, String?)->())

    /// Check if account not exists and verify the used field
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - password: the password
    ///   - confirmPassword: the password from the second field
    ///   - callback: the callback to invoke when success (the new account can be created)
    ///   - failure: the failure callback to return an error
    func checkIfAccountCanBeCreated(email: String, password: String, confirmPassword: String, callback: @escaping (UserInfo) -> (), failure: @escaping FailureCallback)

    /// Register account
    ///
    /// - Parameters:
    ///   - userInfo: the user info
    ///   - profile: the profile
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func register(userInfo: UserInfo, profile: Profile, callback: @escaping (UserInfo) -> (), failure: @escaping FailureCallback)

    /// Get profile
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getProfile(callback: @escaping (Profile) -> (), failure: @escaping FailureCallback)

    /// Update profile
    ///
    /// - Parameters:
    ///   - profile: the profile
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func updateProfile(_ profile: Profile, callback: @escaping () -> (), failure: @escaping FailureCallback)

    /// Initiate password reset
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func forgotPassword(email: String, callback: @escaping ()->(), failure: @escaping FailureCallback)

    /// Logout
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func logout(callback: @escaping ()->(), failure: @escaping FailureCallback)

    // MARK: - Goals

    /// Get goals
    ///
    /// - Parameters:
    ///   - profile: the profile (used to setup goals)
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getGoals(profile: Profile?, callback: @escaping ([Goal])->(), failure: @escaping FailureCallback)

    /// Get goal patterns (for "Add Goal" screen)
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getGoalPatterns(profile: Profile?, callback: @escaping ([Goal])->(), failure: @escaping FailureCallback)

    /// Save goal
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func saveGoal(goal: Goal, callback: @escaping (Goal)->(), failure: @escaping FailureCallback)

    /// Save goals
    ///
    /// - Parameters:
    ///   - goals: the goals
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func saveGoals(goals: [Goal], callback: @escaping ([Goal])->(), failure: @escaping FailureCallback)

    /// Delete goal
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func deleteGoal(goal: Goal, callback: @escaping ()->(), failure: @escaping FailureCallback)

    // MARK: - Reports

    /// Get reports
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getReports(callback: @escaping ([Report])->(), failure: @escaping FailureCallback)

    /// Get previous and next reports
    ///
    /// - Parameters:
    ///   - report: the reference report
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getNearbyReports(report: Report, callback: @escaping (Report?, Report?)->(), failure: @escaping FailureCallback)

    /// Get suggestion for the report
    ///
    ///   - report: the reference report
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getSuggestion(forReport report: Report, callback: @escaping (Suggestion?)->(), failure: @escaping FailureCallback)

    /// Get suggestions for Home screen
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getMainSuggestions(callback: @escaping ([Suggestion])->(), failure: @escaping FailureCallback)

    /// Get rewards
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getRewards(callback: @escaping ([Reward])->(), failure: @escaping FailureCallback)

    /// Get goal units
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getUnits(goal: Goal, callback: @escaping (TaskUnitLimits, TaskUnitSuffix, TaskExtraData)->(), failure: @escaping FailureCallback)

    // MARK: - Medications

    /// Get schedule
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success: (hour, list of medications)
    ///   - failure: the failure callback to return an error
    func getMedicationScheduleForToday(callback: @escaping ([MedicationScheduleItem])->(), failure: @escaping FailureCallback)

    /// Get medications
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success: (list of medications)
    ///   - failure: the failure callback to return an error
    func getMedicationForToday(callback: @escaping ([Medication])->(), failure: @escaping FailureCallback)

    /// Get resources
    ///
    ///   - type: the type
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getResources(type: ResourceType, callback: @escaping ([Resource])->(), failure: @escaping FailureCallback)

    /// Get goal form tips
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getGoalTip(callback: @escaping (JSON)->(), failure: @escaping FailureCallback)

    // MARK: - Food

    /// Get food for "Food Intake" screen
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getFood(callback: @escaping ([Food])->(), failure: @escaping FailureCallback)

    /// Save food intake
    ///
    /// - Parameters:
    ///   - food: the food to save
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func saveFood(food: Food, callback: @escaping (Food)->(), failure: @escaping FailureCallback)

    // MARK: - Workout

    /// Get Workouts
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getWorkout(callback: @escaping ([Workout])->(), failure: @escaping FailureCallback)

    // MARK: - Lab values

    /// Get possible lab values
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getLabValues(callback: @escaping ([[QuantityType]])->(), failure: @escaping FailureCallback)
}
