//
//  SimpleRecommendationSolver.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/**
 * Most simple implementation of RecommendationDecision:
 *   It checks if the given food includes goal's nutrition and returns RecommendationSolution.reduce. Very simple.
 *   The aim of this implementation to debug the app and may be to incorporate in move complex implementations of RecommendationSolver.
 *   The actually used RecommendationSolver implementation can be re-defined later with consultation with experts. For now it's not nessesary.
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - `RecommendationGenerator` support
 * - `NDBNutrient` structure support
 */
class SimpleRecommendationSolver: RecommendationSolver, RecommendationGenerator {

    // MARK: - RecommendationSolver

    func checkGoal(goal: Goal, info: [FoodItem : [NDBNutrient]], callback: @escaping (RecommendationSolution)->()) {
        if let title = goal.getRelatedNutrition()?.title {
            for (foodItem,v) in info {
                for item in v {
                    if item.title.lowercased().contains(title.lowercased()) {

                        // The food has related nutrition -> suggest to reduce
                        callback(.reduce([item], [foodItem]))
                        return
                    }
                }
            }
        }
        return callback(.none)
    }

    // MARK: - RecommendationGenerator

    /// Generates report with recommendation based on the solution
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - solution: the solution
    ///   - callback: the callback to return recommendation
    func genedateRecommendation(goal: Goal, solution: RecommendationSolution, callback: @escaping ([Recommendation])->()) {
        let report = SimpleRecommendationSolver.createStubRecommendation(goal: goal, solution: solution)
        callback([report])
    }

    /// Create stub recommendation. Can be used as pattern in other RecommendationGenerators
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - solution: the solution
    /// - Returns: the recommendation
    class func createStubRecommendation(goal: Goal, solution: RecommendationSolution) -> Recommendation {
        let report = Recommendation(id: UUID().uuidString)
        switch solution {
        case .reduce(_, let foodItems):
            let string: String = foodItems.map({$0.title}).joined(separator: ", ")
            report.relatedFoodInfo = string
            report.title = NSLocalizedString("Reduce", comment: "Reduce")
        default:
            report.title = NSLocalizedString("Increase", comment: "Increase")
        }
        report.title += " " + (goal.getRelatedNutrition()?.title ?? "")
        report.text = "This simple recommendation is generated to demonstrate how Simple Recommendation Solver works"
        report.imageUrl = goal.iconName.replace("Small", withString: "") + "Large"
        if UIImage(named: report.imageUrl) == nil {
            report.imageUrl = goal.iconName
        }
        report.tintColor = goal.color
        report.type = .unsafeFood
        return report
    }
}
