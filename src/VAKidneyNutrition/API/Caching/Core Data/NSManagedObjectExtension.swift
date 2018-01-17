//
//  NSManagedObjectExtension.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation
import CoreData

/**
 * Helpful extension for NSManagedObject
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension NSManagedObject {

    /// returns an instance of the object from context matching current thread
    ///
    /// - Parameter context: specific context
    /// - Returns: same object on specified context
    func `in`(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) -> Self {
        return inContext(type: type(of: self), context: context)
    }

    // facilitates method above
    private func inContext<T>(type: T.Type, context: NSManagedObjectContext = CoreDataStack.shared.viewContext) -> T {
        return context.object(with: self.objectID) as! T
    }

}

