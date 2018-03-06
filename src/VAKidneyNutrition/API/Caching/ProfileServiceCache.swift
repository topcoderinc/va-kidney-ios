//
//  ProfileServiceCache.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import CoreData

/**
 * Model object for Core Data related to Profile
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - birthday instead of age
 *
 * 1.2:
 * - minor changes
 */
extension ProfileMO: CoreDataEntity {

    public typealias Entity = Profile

    /// Convert to enity
    ///
    /// - Returns: the entity
    public func toEntity() -> Profile {
        let object = Profile(id: self.id ?? "")
        updateEntity(object: object)

        if let data = image as Data? {
            object.image = UIImage.fromData(data)
        }
        object.name = name ?? ""
        object.birthday = birthday
        object.height = height
        object.currentWeight = currentWeight
        object.dialysis = dialysis
        object.diseaseCategory = diseaseCategory ?? ""
        object.setupGoals = setupGoals
        object.addDevice = addDevice
        return object
    }

    /// Update fields from given object
    ///
    /// - Parameters:
    ///   - object: the object
    ///   - relatedObjects: the related objects
    public func fillDataFrom(_ object: Profile, relatedObjects: Any?) {
        super.fillDataFromCacheableObject(object, relatedObjects: relatedObjects)

        image = object.image?.toData() as Data?
        name = object.name
        birthday = object.birthday
        height = object.height
        currentWeight = object.currentWeight
        dialysis = object.dialysis

        userId = AuthenticationUtil.sharedInstance.userInfo?.id ?? ""
        
        diseaseCategory = object.diseaseCategory
        setupGoals = object.setupGoals
        addDevice = object.addDevice

    }
}

/**
 * Service caching Profile data
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileServiceCache: DataService<ProfileMO, Profile> {

    /// Get my profile
    ///
    /// - Parameters:
    ///   - callback: the callback used to return data
    ///   - failure: the failure callback used to return an error
    func getMyProfiles(callback: @escaping ([Profile])->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<ProfileMO>(entityName: ProfileMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = self.createStringPredicate("userId", value: AuthenticationUtil.sharedInstance.userInfo?.id ?? "")
        self.get(withRequest: fetchRequest, callback, failure: failure)
    }
}

