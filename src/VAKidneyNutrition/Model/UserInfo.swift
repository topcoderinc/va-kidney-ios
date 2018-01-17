//
//  UserInfo.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * Class for storing user info
 *
 *  author: TCCODER
 *  version: 1.0
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
    var isSetupCompleted = false

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
        object.isSetupCompleted = json["isSetupCompleted"].boolValue
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
            "lastName": self.lastName,
            "isSetupCompleted": self.isSetupCompleted
        ]
        return JSON(dic)
    }
}
