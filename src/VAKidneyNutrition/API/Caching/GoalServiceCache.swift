//
//  GoalServiceCache.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/24/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import CoreData

/**
 * Model object for Core Data related to Goal
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension GoalMO: CoreDataEntity {

    public typealias Entity = Goal

    /// Convert to enity
    ///
    /// - Returns: the entity
    public func toEntity() -> Goal {
        let object = Goal(id: self.id ?? "")
        updateEntity(object: object)

        object.title = title ?? ""
        object.iconName = iconName ?? ""
        object.categoryId = categoryId ?? ""
        object.targetValue = targetValue
        object.frequency = GoalFrequency(rawValue: frequency ?? "") ?? .daily
        object.dateStart = dateStart ?? Date()

        object.points = Int(points)
        object.initialValue = initialValue
        object.value = value

        object.valueText1 = valueText1 ?? ""
        object.valueTextMultiple = valueTextMultiple ?? ""
        object.hasExternalData = hasExternalData
        object.isAscendantTarget = isAscendantTarget
        object.sOrder = Int(sOrder)
        return object
    }

    /// Update fields from given object
    ///
    /// - Parameters:
    ///   - object: the object
    ///   - relatedObjects: the related objects
    public func fillDataFrom(_ object: Goal, relatedObjects: Any?) {
        super.fillDataFromCacheableObject(object, relatedObjects: relatedObjects)

        title = object.title
        iconName = object.iconName
        categoryId = object.categoryId
        targetValue = object.targetValue
        frequency = object.frequency.rawValue
        dateStart = object.dateStart

        points = Int32(object.points)
        initialValue = object.initialValue
        value = object.value
        userId = AuthenticationUtil.sharedInstance.userInfo?.id ?? ""

        valueText1 = object.valueText1
        valueTextMultiple = object.valueTextMultiple
        hasExternalData = object.hasExternalData
        isAscendantTarget = object.isAscendantTarget
        sOrder = Int32(object.sOrder)
    }
}

/**
 * Service caching Profile data
 *
 * - author: TCCODER
 * - version: 1.0
 */
class GoalServiceCache: DataService<GoalMO, Goal> {

    /// Get all goals for the current user
    ///
    /// - Parameters:
    ///   - callback: the callback used to return data
    ///   - failure: the failure callback used to return an error
    func getAllGoals(callback: @escaping ([Goal])->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<GoalMO>(entityName: GoalMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = self.createStringPredicate("userId", value: AuthenticationUtil.sharedInstance.userInfo?.id ?? "")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "sOrder", ascending: true)]
        self.get(withRequest: fetchRequest, callback, failure: failure)
    }
}


