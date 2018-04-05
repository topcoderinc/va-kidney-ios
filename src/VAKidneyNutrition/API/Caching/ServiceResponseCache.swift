//
//  ServiceResponseCache.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/31/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

/**
 * Model object for Core Data related to ServiceResponse
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension ServiceResponseMO: CoreDataEntity {

    public typealias Entity = ServiceResponse

    /// Convert to enity
    ///
    /// - Returns: the entity
    public func toEntity() -> ServiceResponse {
        let object = ServiceResponse(id: self.id ?? "")
        updateEntity(object: object)

        object.url = url ?? ""
        object.json = try? JSON(data: json ?? Data())
        if object.json == nil {
            object.json = JSON.null
        }
        return object
    }

    /// Update fields from given object
    ///
    /// - Parameters:
    ///   - object: the object
    ///   - relatedObjects: the related objects
    public func fillDataFrom(_ object: ServiceResponse, relatedObjects: Any?) {
        super.fillDataFromCacheableObject(object, relatedObjects: relatedObjects)

        url = object.url
        do {
            json = try object.json.rawData()
        }
        catch (_) {
            json = Data()
        }
    }
}

/**
 * Service caching ServiceResponse
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ServiceResponseCache: DataService<ServiceResponseMO, ServiceResponse> {

    /// Get cached response
    ///
    /// - Parameters:
    ///   - url: the url
    ///   - callback: the callback to invoke when complete
    ///   - failure: the failure callback used to return an error
    func getCachedResponse(url: String, callback: @escaping (ServiceResponse?)->(), failure: @escaping GeneralFailureBlock) {
        let fetchRequest = NSFetchRequest<ServiceResponseMO>(entityName: ServiceResponseMO.entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = self.createStringPredicate("url", value: url)
        self.get(withRequest: fetchRequest, { list in
            callback(list.last)
        }, failure: failure)
    }
}
