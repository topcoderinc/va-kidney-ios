//
//  Recommendation.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/4/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON
import UIComponents

/// Possible types for MedicationResource
enum RecommendationType: String {
    case foodSuggestion = "Food Suggestion", unsafeFood = "Unsafe Food",
    drugConsumption = "Drug Consumption",
    drugInteractionWarnings = "Drug Interaction Warnings"

    /// Get human readable string
    ///
    /// - Returns: string
    func getTitle() -> String {
        return self.rawValue
    }
}

/**
 * Model object for resource in medication tab
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - MedicationResource renamed to Recommendation
 */
public class Recommendation: CacheableObject {

    /// the fields
    var title = ""
    var text = ""
    var imageUrl: String = ""
    var tintColor: UIColor?
    var type: RecommendationType = .foodSuggestion
    var relatedFoodInfo = ""

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Recommendation {
        let object = Recommendation(id: json["id"].stringValue)
        object.title = json["title"].stringValue
        object.text = json["text"].stringValue
        object.imageUrl = json["imageUrl"].stringValue
        return object
    }

    /// Create report from FDA response
    ///
    /// - Parameters:
    ///   - json: the JSON
    ///   - drugs: the drugs
    /// - Returns: the report
    class func drugInteractionReport(_ json: JSON, drugs: [FoodItem]) -> Recommendation {
        let object = Recommendation(id: UUID().uuidString)
        object.title = drugs.map({$0.title}).joined(separator: " + ").capitalized
        object.type = .drugInteractionWarnings

        // Add all results
        var str = ""
        for json in json["results"].arrayValue {
            // Using structure as at https://open.fda.gov/drug/event/
            str = "Report: #\(json["safetyreportid"].stringValue)\n"
            if let date = DateFormatters.pdaDate.date(from: json["receivedate"].stringValue) {
                str += "Date: \(DateFormatters.profileDate.string(from: date))\n"
            }
            str += "\n"

            for drug in json["patient"]["drug"].arrayValue {
                var roleStr = ""
                let role = drug["drugcharacterization"].stringValue
                switch role {
                case "1": roleStr = "Suspect"
                case "2": roleStr = "Concomitant"
                default: roleStr = "Interacting"
                }
                str += drug["medicinalproduct"].stringValue + " (\(roleStr))\n"
            }
            str += "\n"

            for reaction in json["patient"]["reaction"].arrayValue {
                var reactionResultStr = ""
                let reactionResult = reaction["reactionoutcome"].stringValue
                switch reactionResult { // see https://open.fda.gov/drug/event/reference/
                case "1": reactionResultStr = "Recovered/resolved"
                case "2": reactionResultStr = "Recovering/resolving"
                case "3": reactionResultStr = "Not recovered/not resolved"
                case "4": reactionResultStr = "Recovered/resolved with sequelae (consequent health issues)"
                case "5": reactionResultStr = "Fatal"
                default: reactionResultStr = "Unknown"
                }
                str += reaction["reactionmeddrapt"].stringValue + ": \(reactionResultStr)\n"
            }
            str += "\n\n"
        }
        object.text = str.trim()
        object.imageUrl = "iconPillLarge"
        object.tintColor = Colors.blue
        return object
    }
}
