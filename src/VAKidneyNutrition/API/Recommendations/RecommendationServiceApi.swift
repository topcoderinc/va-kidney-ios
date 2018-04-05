//
//  RecommendationServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/31/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation

/**
 * API related to getting/storing recommendations
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol RecommendationServiceApi {

    /// Get medication resources
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getMedicationRecommendations(callback: @escaping ([(String,[Recommendation])])->(), failure: @escaping FailureCallback)

    /// Get drag resources
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getDragRecommendations(callback: @escaping ([(String,[Recommendation])])->(), failure: @escaping FailureCallback)

    /// Replace medication resources of given type
    ///
    /// - Parameters:
    ///   - item: the items
    ///   - type: the type
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func replaceRecommendations(_ item: [Recommendation], ofType type: RecommendationType, callback: @escaping ()->(), failure: @escaping FailureCallback)
}
