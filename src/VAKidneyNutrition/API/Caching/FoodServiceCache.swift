//
//  FoodServiceCache.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import CoreData

/**
 * Model object for Core Data related to Food
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension FoodMO: CoreDataEntity {

    public typealias Entity = Food

    /// Convert to enity
    ///
    /// - Returns: the entity
    public func toEntity() -> Food {
        let object = Food(id: self.id ?? "")
        updateEntity(object: object)

        object.time = FoodIntakeTime(rawValue: (time ?? "").lowercased()) ?? .breakfast
        object.items = (items as! Set<FoodItemMO>).map({$0.toEntity()})
        object.date = date ?? Date()


        if (imageUrls ?? []).isEmpty {
            object.images = (images ?? []).map{UIImage(data: $0) ?? UIImage()}
        }
        else {
            object.images = imageUrls ?? []
        }
        return object
    }

    /// Update fields from given object
    ///
    /// - Parameters:
    ///   - object: the object
    ///   - relatedObjects: the related objects
    public func fillDataFrom(_ object: Food, relatedObjects: Any?) {
        super.fillDataFromCacheableObject(object, relatedObjects: relatedObjects)

        time = object.time.rawValue
        let items: [FoodItemMO] = (relatedObjects as? [FoodItemMO]) ?? []
        self.items = NSSet(array: items)
        date = object.date
        let urls: [String] = object.images.filter({$0 is String}).map{$0 as! String}
        let rawImages: [Data] = object.images.filter({$0 is UIImage}).map{($0 as! UIImage).toData() ?? Data()}
        imageUrls = urls
        images = rawImages
        userId = AuthenticationUtil.sharedInstance.userInfo?.id ?? ""
    }
}

/**
 * Service caching Food
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodServiceCache: DataService<FoodMO, Food> {

    /// Get all food for the current user
    ///
    /// - Parameters:
    ///   - callback: the callback used to return data
    ///   - failure: the failure callback used to return an error
    func getAll(callback: @escaping ([Food])->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<FoodMO>(entityName: FoodMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = self.createStringPredicate("userId", value: AuthenticationUtil.sharedInstance.userInfo?.id ?? "")
        self.get(withRequest: fetchRequest, callback, failure: failure)
    }
}
