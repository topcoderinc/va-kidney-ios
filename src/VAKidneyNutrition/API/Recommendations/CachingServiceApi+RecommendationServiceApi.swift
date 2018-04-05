//
//  CachingServiceApi+RecommendationServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/31/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation

/**
 * RecommendationServiceApi implementation
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension CachingServiceApi: RecommendationServiceApi {

    /// Get medication resources
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getMedicationRecommendations(callback: @escaping ([(String,[Recommendation])])->(), failure: @escaping FailureCallback) {
        medicationResourceService.getAllFoodResources(callback: { (resources) in
            let map = resources.hasharrayWithKey({$0.type})
            var list = [(String,[Recommendation])]()
            list.append((RecommendationType.foodSuggestion.getTitle(), (map[RecommendationType.foodSuggestion] ?? []).sorted(by: {$0.retrievalDate < $1.retrievalDate})))
            list.append((RecommendationType.unsafeFood.getTitle(), (map[RecommendationType.unsafeFood] ?? []).sorted(by: {$0.retrievalDate < $1.retrievalDate})))
            callback(list)
        }, failure: wrapFailure(failure))
    }

    /// Get drag resources
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getDragRecommendations(callback: @escaping ([(String,[Recommendation])])->(), failure: @escaping FailureCallback) {
        medicationResourceService.getAllDrugResources(callback: { (resources) in
            let map = resources.hasharrayWithKey({$0.type})
            var list = [(String,[Recommendation])]()
            list.append((RecommendationType.drugConsumption.getTitle(), (map[RecommendationType.drugConsumption] ?? []).sorted(by: {$0.retrievalDate < $1.retrievalDate})))
            list.append((RecommendationType.drugInteractionWarnings.getTitle(), (map[RecommendationType.drugInteractionWarnings] ?? []).sorted(by: {$0.retrievalDate < $1.retrievalDate})))
            callback(list)
        }, failure: wrapFailure(failure))
    }

    /// Replace medication resources of given type
    ///
    /// - Parameters:
    ///   - item: the items
    ///   - type: the type
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func replaceRecommendations(_ items: [Recommendation], ofType type: RecommendationType, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        let callbackToAddResources: ()->() = {
            self.medicationResourceService.upsert(items, success: { (_) in
                callback()
            }, failure: self.wrapFailure(failure))
        }
        switch type {
        case .foodSuggestion, .unsafeFood:
            medicationResourceService.removeAllFoodResources(callback: callbackToAddResources, failure: self.wrapFailure(failure))
        case .drugConsumption, .drugInteractionWarnings:
            medicationResourceService.removeAllDrugResources(callback: callbackToAddResources, failure: self.wrapFailure(failure))
        }
    }

}
