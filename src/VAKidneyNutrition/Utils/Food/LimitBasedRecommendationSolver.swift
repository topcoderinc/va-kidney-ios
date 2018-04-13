//
//  LimitBasedRecommendationSolver.swift
//  VAKidneyNutrition
//
//  Created by Volkov Alexander on 4/12/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation

/**
 * Uses goal limits to define what nutrients to reduce
 *
 * - author: TCCODER
 * - version: 1.0
 */
class LimitBasedRecommendationSolver: RecommendationSolver {

    // MARK: - RecommendationSolver

    /// the storage
    private var storage: QuantitySampleService = QuantitySampleStorage.shared

    func checkGoal(goal: Goal, info: [FoodItem : [NDBNutrient]], callback: @escaping (RecommendationSolution)->()) {
        var callbackInvoked = false
        let g = DispatchGroup()
        if let type = goal.getRelatedNutrition() {
            for (foodItem,v) in info {
                for item in v {
                    if item.title.lowercased().contains(type.title.lowercased()) {
                        g.enter()
                        storage.getTodayStatistics(type, callback: { (quantity) in
                            let value = Float(quantity.doubleValue(for: HealthKitUtil.shared.getUnit(forType: type)))
                            if let min = goal.min {
                                if value < min {
                                    if !callbackInvoked {
                                        callback(.increase)
                                        callbackInvoked = true
                                    }
                                    g.leave()
                                    return
                                }
                            }
                            if let max = goal.max {
                                if value > max {
                                    if !callbackInvoked {
                                        callback(.reduce([item], [foodItem]))
                                        callbackInvoked = true
                                    }
                                }
                            }
                            g.leave()
                        }, customTypeCallback: {})
                    }
                }
            }
        }
        g.notify(queue: DispatchQueue.main) {
            if !callbackInvoked {
                callback(.none)
            }
        }
    }

}
