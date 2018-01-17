//
//  CacheableObjectMOExtension.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation

/**
 * Methods for using by concrete subclasses of CacheableObjectMO
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension CacheableObjectMO {

    /// Update entity
    ///
    /// - Parameters:
    ///   - object: the object
    public func updateEntity(object: CacheableObject) {
        //        object.id = id // Not modified. Specified in initializer.

        object.deletedLocally = deletedLocally
        object.retrievalDate = retrievalDate ?? Date()

        object.managedObjectID = self.objectID
    }

    /// Fill fields of Core Data object from model object
    ///
    /// - Parameters:
    ///   - object: the object
    ///   - relatedObjects: the related objects (optional)
    public func fillDataFromCacheableObject(_ object: CacheableObject, relatedObjects: Any?) {
        id = object.id

        deletedLocally = object.deletedLocally
        retrievalDate = object.retrievalDate
    }
}

