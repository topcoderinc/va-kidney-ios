//
//  NDBNutrient.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/30/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation

/**
 * Nutrient model object. Used to represent nutrient from NDB response.
 *
 * - author: TCCODER
 * - version: 1.0
 */
struct NDBNutrient {

    /// the fields
    let id: String
    let title: String
    let percent: Double // Percent of the nutrient in the related product.
    let unit: String
}
