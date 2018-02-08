//
//  UserInfo.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * Class for storing user info
 *
 *  author: TCCODER
 *  version: 1.1
 */
/* changes:
 * 1.1:
 * - minor modification
 */
public class UserInfo: CacheableObject {

    /// the email
    var email: String = ""

    /// the user's first name
    var firstName: String = ""

    /// the user's last name
    var lastName: String = ""

    /// the password
    var password: String = ""

    /// the user's full name
    var fullName: String {
        return firstName + " " + lastName.trim()
    }

    /// true - the (profile) setup is completed, false - else
    /// kept for future
    var isSetupCompleted = true

    /// Parse JSON into UserInfo
    ///
    /// - Parameter json: JSON object
    /// - Returns: UserInfo
    class func fromJson(_ json: JSON) -> UserInfo {
        let object = UserInfo(id: json["id"].stringValue)
        object.email = json["email"].stringValue
        object.password = json["password"].stringValue
        object.firstName = json["firstName"].stringValue
        object.lastName = json["lastName"].stringValue
        return object
    }

    /// Convert UserInfo to JSON object
    ///
    /// - Returns: JSON object
    func toJson() -> JSON {
        let dic: [String: Any] = [
            "id": self.id,
            "email": self.email,
            "password": self.password,
            "firstName": self.firstName,
            "lastName": self.lastName
        ]
        return JSON(dic)
    }
}
