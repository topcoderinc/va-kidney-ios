//
//  Profile.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Profile info
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class Profile: CacheableObject {

    /// the age
    var age = -1

    /// the height
    var height = -1

    /// the current weight
    var currentWeight = -1

    /// answer to  "Are you on Dialysis?"
    var dialysis: Bool = false

    /// the disease category
    var diseaseCategory = ""

    /// true - will setup goals, false - else
    var setupGoals = false

    /// the profile image
    var image: UIImage?

    /// the name
    var name = ""
}

