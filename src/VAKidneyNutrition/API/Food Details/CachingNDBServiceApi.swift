//
//  CachingNDBServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/31/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * Caching implementation of FoodDetailsServiceApi.
 *
 * - author: TCCODER
 * - version: 1.0
 */
class CachingNDBServiceApi: NDBServiceApi {

    /// singleton
    static let sharedWrapper: FoodDetailsServiceApi = CachingNDBServiceApi(baseUrl: Configuration.shared.ndbApiBaseUrl)

    /// Core Data service
    private let service = ServiceResponseCache()

    /// Tries to reuse cached response
    ///
    /// - Parameters:
    ///   - endpoint: the endpoint
    ///   - parameters: the parameters
    ///   - success: the callback to invoke when success (returns JSON response)
    ///   - failure: the failure callback to return an error
    override func get(_ endpoint: String, parameters: [String : Any], success: @escaping (JSON) -> (), failure: @escaping FailureCallback) {
        service.getCachedResponse(url: endpoint, callback: { (response) in
            if self.service.isExpired(response, timeInterval: Double(self.cachePeriod)) {
                super.get(endpoint, parameters: parameters, success: { (json) in
                    var response: ServiceResponse? = response
                    if response == nil {
                        response = ServiceResponse(id: UUID().uuidString)
                        response?.url = endpoint
                        response?.json = json
                    }
                    self.service.upsert([response!], success: { (_) in
                        success(json)
                    }, failure:  { error in
                        failure(error.localizedDescription)
                    })
                }, failure: failure)
            }
            else {
                success(response!.json)
            }
        }, failure: { error in
            failure(error.localizedDescription)
        })
    }
}
