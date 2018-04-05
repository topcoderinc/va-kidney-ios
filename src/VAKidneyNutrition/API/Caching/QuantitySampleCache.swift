//
//  QuantitySampleCache.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/29/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import CoreData

/**
 * Model object for Core Data related to QuantitySample
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension QuantitySampleMO: CoreDataEntity {

    public typealias Entity = QuantitySample

    /// Convert to enity
    ///
    /// - Returns: the entity
    public func toEntity() -> QuantitySample {
        let object = QuantitySample(id: self.id ?? "")
        updateEntity(object: object)

        object.type = QuantityType.fromId(type ?? "")
        object.amount = amount
        return object
    }

    /// Update fields from given object
    ///
    /// - Parameters:
    ///   - object: the object
    ///   - relatedObjects: the related objects
    public func fillDataFrom(_ object: QuantitySample, relatedObjects: Any?) {
        super.fillDataFromCacheableObject(object, relatedObjects: relatedObjects)

        type = object.type.id
        amount = object.amount
    }
}

/**
 * Service caching Medication Resources
 *
 * - author: TCCODER
 * - version: 1.0
 */
class QuantitySampleCache: DataService<QuantitySampleMO, QuantitySample> {

    /// Get call samples in given dates of given type
    ///
    /// - Parameters:
    ///   - start: the start date
    ///   - end: the end date
    ///   - type: the type
    ///   - callback: the callback to invoke when complete
    ///   - failure: the failure callback used to return an error
    func getAll(from start: Date, to end: Date, ofType type: QuantityType, callback: @escaping ([QuantitySample])->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<QuantitySampleMO>(entityName: QuantitySampleMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "createdAt", ascending: true)]

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            self.createStringPredicate("type", value: type.id),
            self.createDateGreaterOrEqualToPredicate("createdAt", date: start),
            self.createDateLessOrEqualToPredicate("createdAt", date: end)
            ])
        self.get(withRequest: fetchRequest, callback, failure: failure)
    }
}
