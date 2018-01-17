//
//  UserInfoServiceCache.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation

/**
 * Model object for Core Data related to UserInfo
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UserInfoMO: CoreDataEntity {

    public typealias Entity = UserInfo

    /// Convert to enity
    ///
    /// - Returns: the entity
    public func toEntity() -> UserInfo {
        let object = UserInfo(id: self.id ?? "")
        updateEntity(object: object)

        object.email = email ?? ""
        object.firstName = firstName ?? ""
        object.lastName = lastName ?? ""
        object.password = password ?? ""
        object.isSetupCompleted = isSetupCompleted

        return object
    }

    /// Update fields from given object
    ///
    /// - Parameters:
    ///   - object: the object
    ///   - relatedObjects: the related objects
    public func fillDataFrom(_ object: UserInfo, relatedObjects: Any?) {
        super.fillDataFromCacheableObject(object, relatedObjects: relatedObjects)

        email = object.email
        firstName = object.firstName
        lastName = object.lastName
        password = object.password
        isSetupCompleted = object.isSetupCompleted 
    }
}

/**
 * Service caching User data
 *
 * - author: TCCODER
 * - version: 1.0
 */
class UserInfoServiceCache: DataService<UserInfoMO, UserInfo> {
}

