//
//  RecommendationServiceCache.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import CoreData

/**
 * Model object for Core Data related to MedicationResource
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - renamed from MedicationResourceMO
 */
extension RecommendationMO: CoreDataEntity {

    public typealias Entity = Recommendation

    /// Convert to enity
    ///
    /// - Returns: the entity
    public func toEntity() -> Recommendation {
        let object = Recommendation(id: self.id ?? "")
        updateEntity(object: object)

        object.title = title ?? ""
        object.text = text ?? ""
        object.imageUrl = imageUrl ?? ""
        object.type = RecommendationType(rawValue: type ?? "") ?? RecommendationType.unsafeFood
        object.tintColor = UIColor.fromString(tintColor ?? "")
        object.relatedFoodInfo = relatedFoodInfo ?? ""
        return object
    }

    /// Update fields from given object
    ///
    /// - Parameters:
    ///   - object: the object
    ///   - relatedObjects: the related objects
    public func fillDataFrom(_ object: Recommendation, relatedObjects: Any?) {
        super.fillDataFromCacheableObject(object, relatedObjects: relatedObjects)

        title = object.title
        text = object.text
        imageUrl = object.imageUrl
        type = object.type.rawValue
        tintColor = object.tintColor?.toString()
        relatedFoodInfo = object.relatedFoodInfo
        
        userId = AuthenticationUtil.sharedInstance.userInfo?.id ?? ""
    }
}

/**
 * Service caching Medication Resources
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - renamed from MedicationResourceServiceCache
 */
class RecommendationServiceCache: DataService<RecommendationMO, Recommendation> {
    
    /// predicate for all food resources
    ///
    /// - Returns: return NSCompoundPredicate for all food resource
    func getAllFoodResourcesPredicate() -> NSCompoundPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                self.createStringPredicate("type", value: RecommendationType.foodSuggestion.rawValue),
                self.createStringPredicate("type", value: RecommendationType.unsafeFood.rawValue)
                ]),
            self.createStringPredicate("userId", value: AuthenticationUtil.sharedInstance.userInfo?.id ?? "")
            ])
    }
    
    /// predicate for all drug resources
    ///
    /// - Returns: return NSCompoundPredicate for all drug resource
    func getAllDrugResourcesPredicate() -> NSCompoundPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                self.createStringPredicate("type", value: RecommendationType.drugConsumption.rawValue),
                self.createStringPredicate("type", value: RecommendationType.drugInteractionWarnings.rawValue)
                ]),
            self.createStringPredicate("userId", value: AuthenticationUtil.sharedInstance.userInfo?.id ?? "")
            ])
    }

    /// Get all food resources
    ///
    /// - Parameters:
    ///   - callback: the callback used to return data
    ///   - failure: the failure callback used to return an error
    func getAllFoodResources(callback: @escaping ([Recommendation])->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<RecommendationMO>(entityName: RecommendationMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        fetchRequest.predicate = getAllFoodResourcesPredicate()
        self.get(withRequest: fetchRequest, callback, failure: failure)
    }

    /// Get all drug resources
    ///
    /// - Parameters:
    ///   - callback: the callback used to return data
    ///   - failure: the failure callback used to return an error
    func getAllDrugResources(callback: @escaping ([Recommendation])->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<RecommendationMO>(entityName: RecommendationMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        fetchRequest.predicate = getAllDrugResourcesPredicate()
        self.get(withRequest: fetchRequest, callback, failure: failure)
    }

    /// Remove all food resources
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when complete
    ///   - failure: the failure callback used to return an error
    func removeAllFoodResources(callback: @escaping ()->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<RecommendationMO>(entityName: RecommendationMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        fetchRequest.predicate = getAllFoodResourcesPredicate()
        removeInstancesOfRequest(fetchRequest as! NSFetchRequest<NSFetchRequestResult>, success: callback, failure: failure)
    }

    /// Remove all drug resources
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when complete
    ///   - failure: the failure callback used to return an error
    func removeAllDrugResources(callback: @escaping ()->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<RecommendationMO>(entityName: RecommendationMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        fetchRequest.predicate = getAllDrugResourcesPredicate()
        removeInstancesOfRequest(fetchRequest as! NSFetchRequest<NSFetchRequestResult>, success: callback, failure: failure)
    }
}
