//
//  AuthenticationUtil.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/// the constants used to store profile data
let kProfileImageUrl = "kProfileImageUrl"
let kAuthenticatedUserInfo = "kAuthenticatedUserInfo"

/**
 * Utility for storing and getting current user profile data
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - refactoring
 */
final class AuthenticationUtil {

    /// the user info
    var userInfo: UserInfo? {
        didSet {
            if let userInfo = userInfo {
                _ = userInfo.toJson().saveFile(kAuthenticatedUserInfo)
            }
            else {
                FileUtil.removeFile(kAuthenticatedUserInfo)
            }
        }
    }

    static let sharedInstance = AuthenticationUtil()

    // This prevents others from using the default '()' initializer for this class.
    private init() {
        if let json = JSON.contentOfFile(kAuthenticatedUserInfo) {
            self.userInfo = UserInfo.fromJson(json)
        }
    }

    /**
     Store userInfo

     - parameter userInfo: the data
     */
    func storeUserInfo(userInfo: UserInfo) {
        self.userInfo = userInfo
    }

    /**
     Check if user is already authenticated

     - returns: true - is user is authenticated, false - else
     */
    func isAuthenticated() -> Bool {
        return userInfo != nil
    }

    /**
     Clean up any stored user information
     */
    func cleanUp() {
        userInfo = nil
    }

    /**
     Get value by key

     - parameter key: the key

     - returns: the value
     */
    func getValueByKey<T>(_ key: String) -> T? {
        return UserDefaults.standard.object(forKey: key) as? T
    }

    /**
     Save value to local preferences

     - parameter value: the value to save
     - parameter key:   the key
     */
    func saveValueForKey<T>(_ value: T?, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

}


