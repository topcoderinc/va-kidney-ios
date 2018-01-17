//
//  CacheableObject.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

/**
 * Abstract object for all cacheable model objects
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class CacheableObject: NSObject, CoreDataEntityBridge {

    // the ID
    public var id: String

    //////////////////////////////////////////////////////////////////
    // LOCAL FIELDS (see CoreDataEntityBridge)
    public var deletedLocally: Bool = false
    // The ObjectID of the CoreData object we saved to or loaded from
    open var managedObjectID: NSManagedObjectID?
    /// the date of data retrieval
    open var retrievalDate: Date = Date()

    /// Initializer
    ///
    /// - Parameter id: ID
    public init(id: String) {
        self.id = id
    }

    /// hash value
    public override var hashValue: Int {
        return id.hashValue
    }

    /// Method can be overridden
    ///
    /// - Parameter json: JSON
    public func fillCommonFields(fromJson json: JSON) {
    }
}

/**
 Equatable protocol implementation

 - parameter lhs: the left object
 - parameter rhs: the right object

 - returns: true - if objects are equal, false - else
 */
public func ==<T: CacheableObject>(lhs: T, rhs: T) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

