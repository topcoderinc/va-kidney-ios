//
//  MedicationResourceServiceCache.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import CoreData

/**
 * Model object for Core Data related to MedicationResource
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension MedicationResourceMO: CoreDataEntity {

    public typealias Entity = MedicationResource

    /// Convert to enity
    ///
    /// - Returns: the entity
    public func toEntity() -> MedicationResource {
        let object = MedicationResource(id: self.id ?? "")
        updateEntity(object: object)

        object.title = title ?? ""
        object.text = text ?? ""
        object.imageUrl = imageUrl ?? ""
        object.type = MedicationResourceType(rawValue: type ?? "") ?? MedicationResourceType.unsafeFood
        object.tintColor = UIColor.fromString(tintColor ?? "")
        object.relatedFoodInfo = relatedFoodInfo ?? ""
        return object
    }

    /// Update fields from given object
    ///
    /// - Parameters:
    ///   - object: the object
    ///   - relatedObjects: the related objects
    public func fillDataFrom(_ object: MedicationResource, relatedObjects: Any?) {
        super.fillDataFromCacheableObject(object, relatedObjects: relatedObjects)

        title = object.title
        text = object.text
        imageUrl = object.imageUrl
        type = object.type.rawValue
        tintColor = object.tintColor?.toString()
        relatedFoodInfo = object.relatedFoodInfo
    }
}

/**
 * Service caching Medication Resources
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MedicationResourceServiceCache: DataService<MedicationResourceMO, MedicationResource> {

    /// Get all food resources
    ///
    /// - Parameters:
    ///   - callback: the callback used to return data
    ///   - failure: the failure callback used to return an error
    func getAllFoodResources(callback: @escaping ([MedicationResource])->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<MedicationResourceMO>(entityName: MedicationResourceMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            self.createStringPredicate("type", value: MedicationResourceType.foodSuggestion.rawValue),
            self.createStringPredicate("type", value: MedicationResourceType.unsafeFood.rawValue)
            ])
        self.get(withRequest: fetchRequest, callback, failure: failure)
    }

    /// Get all drug resources
    ///
    /// - Parameters:
    ///   - callback: the callback used to return data
    ///   - failure: the failure callback used to return an error
    func getAllDrugResources(callback: @escaping ([MedicationResource])->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<MedicationResourceMO>(entityName: MedicationResourceMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            self.createStringPredicate("type", value: MedicationResourceType.drugConsumption.rawValue),
            self.createStringPredicate("type", value: MedicationResourceType.drugInteractionWarnings.rawValue)
            ])
        self.get(withRequest: fetchRequest, callback, failure: failure)
    }

    /// Remove all food resources
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when complete
    ///   - failure: the failure callback used to return an error
    func removeAllFoodResources(callback: @escaping ()->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<MedicationResourceMO>(entityName: MedicationResourceMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            self.createStringPredicate("type", value: MedicationResourceType.foodSuggestion.rawValue),
            self.createStringPredicate("type", value: MedicationResourceType.unsafeFood.rawValue)
            ])
        removeInstancesOfRequest(fetchRequest as! NSFetchRequest<NSFetchRequestResult>, success: callback, failure: failure)
    }

    /// Remove all drug resources
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when complete
    ///   - failure: the failure callback used to return an error
    func removeAllDrugResources(callback: @escaping ()->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<MedicationResourceMO>(entityName: MedicationResourceMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            self.createStringPredicate("type", value: MedicationResourceType.drugConsumption.rawValue),
            self.createStringPredicate("type", value: MedicationResourceType.drugInteractionWarnings.rawValue)
            ])
        removeInstancesOfRequest(fetchRequest as! NSFetchRequest<NSFetchRequestResult>, success: callback, failure: failure)
    }
}
