//
//  SimpleRecommendationSolver.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
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
 * - version: 1.0
 */
class SimpleRecommendationSolver: RecommendationSolver {

    func checkGoal(goal: Goal, info: [FoodItem : [NDBNutrient]]) -> RecommendationSolution {
        if let title = goal.getRelatedNutrition() {
            for (food,v) in info {
                for item in v {
                    if item.0.lowercased().contains(title.lowercased()) {

                        // The food has related nutrition -> suggest to reduce
                        return .reduce(food.title.capitalized)
                    }
                }
            }
        }
        return .none
    }

    /// Generates .unsafeFood recommendation
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - solution: the solution
    /// - Returns: recommmendation
    func genedateRecommendation(goal: Goal, solution: RecommendationSolution) -> Recommendation? {
        let report = Recommendation(id: UUID().uuidString)
        switch solution {
        case .reduce(let info):
            report.relatedFoodInfo = info
            report.title = NSLocalizedString("Reduce", comment: "Reduce")
        default:
            report.title = NSLocalizedString("Increase", comment: "Increase")
        }
        report.title += " " + (goal.getRelatedNutrition() ?? "")
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
