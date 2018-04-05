//
//  GoalServiceCache.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/24/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIComponents
import CoreData

/**
 * Model object for Core Data related to Goal
 *
 * - author: TCCODER
 * - version: 1.3
 *
 * changes:
 * 1.1:
 * - new fields
 *
 * 1.2:
 * - goal type
 *
 * 1.3:
 * - changes in fields
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
        object.frequency = GoalFrequency(rawValue: frequency ?? "") ?? .daily
        object.dateStart = dateStart ?? Date()
        object.points = Int(points)
        object.value = value

        object.goalType = ComparisonResult(rawValue: Int(goalType)) ?? .orderedDescending
        object.relatedQuantityId = relatedQuantityId

        object.iconName = iconName ?? ""
        object.valueText1 = valueText1 ?? ""
        object.valueTextMultiple = valueTextMultiple ?? ""
        object.valueText = valueText ?? ""
        object.color = UIColor.fromString(color ?? "") ?? .red
        object.sOrder = Int(sOrder)

        object.hasExternalData = hasExternalData
        object.isReminderOn = isReminderOn

        object.targetValue = targetValue
        object.initialValue = initialValue

        object.min = min > 0 ? min : nil
        object.max = max > 0 ? max : nil
        object.oneUnitValue = oneUnitValue
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
        targetValue = object.targetValue
        frequency = object.frequency.rawValue
        dateStart = object.dateStart

        points = Int32(object.points)
        initialValue = object.initialValue
        value = object.value
        userId = AuthenticationUtil.sharedInstance.userInfo?.id ?? ""

        valueText1 = object.valueText1
        valueText = object.valueText
        valueTextMultiple = object.valueTextMultiple
        hasExternalData = object.hasExternalData
        goalType = Int32(object.goalType.rawValue)
        relatedQuantityId = object.relatedQuantityId
        sOrder = Int32(object.sOrder)
        color = object.color.toString()
        isReminderOn = object.isReminderOn
        min = object.min ?? -1
        max = object.max ?? -1
        oneUnitValue = object.oneUnitValue
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

    /// Remove all goals for the current user
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback used to return an error
    func removeAllGoals(callback: @escaping ()->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<GoalMO>(entityName: GoalMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = self.createStringPredicate("userId", value: AuthenticationUtil.sharedInstance.userInfo?.id ?? "")
        self.removeInstancesOfRequest(fetchRequest as! NSFetchRequest<NSFetchRequestResult>, success: callback, failure: failure)
    }
}


