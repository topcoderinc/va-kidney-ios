//
//  ServiceResponse.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/31/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * Model object represending cached HTTP response
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class ServiceResponse: CacheableObject {

    /// fields
    var url: String = ""
    var json: JSON!
}
