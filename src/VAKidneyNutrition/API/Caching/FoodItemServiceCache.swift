//
//  FoodItemServiceCache.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/23/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import CoreData

/**
 * Model object for Core Data related to FoodItem
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - type added
 */
extension FoodItemMO: CoreDataEntity {

    public typealias Entity = FoodItem

    /// Convert to enity
    ///
    /// - Returns: the entity
    public func toEntity() -> FoodItem {
        let object = FoodItem(id: self.id ?? "")
        updateEntity(object: object)

        object.title = title ?? ""
        object.amount = amount
        object.units = units ?? ""
        object.type = FoodItemType(rawValue: type ?? "") ?? .food
        return object
    }

    /// Update fields from given object
    ///
    /// - Parameters:
    ///   - object: the object
    ///   - relatedObjects: the related objects
    public func fillDataFrom(_ object: FoodItem, relatedObjects: Any?) {
        super.fillDataFromCacheableObject(object, relatedObjects: relatedObjects)

        title = object.title
        amount = object.amount
        units = object.units
        type = object.type.rawValue
    }
}

/**
 * Service caching Food Items
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodItemServiceCache: DataService<FoodItemMO, FoodItem> {

}
