//
//  ValidationUtils.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation

/**
 * Validation utilities.
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class ValidationUtils {

    /**
     Check URL for correctness and callback failure if it's not.

     - parameter url:     the URL to check
     - parameter failure: the closure to invoke if validation fails

     - returns: true if URL is correct
     */
    public class func validateUrl(url: String?, _ failure: ((String) -> ())?) -> Bool {
        if url == nil || url == "" {
            failure?("Empty URL")
            return false
        }
        if !url!.hasPrefix("http") {
            failure?("URL should start with \"http\"")
            return false
        }
        return true
    }

    /**
     Check 'string' if it's correct ID.
     Delegates validation to two other methods.

     - parameter id:      the id string to check
     - parameter failure: the closure to invoke if validation fails

     - returns: true if string is not empty
     */
    public class func validateId(_ id: String, _ failure: ((String) -> ())?) -> Bool {
        if !ValidationUtils.validateStringNotEmpty(id, failure) { return false }
        if id.isNumber() && !ValidationUtils.validatePositiveNumber(id, failure) { return false }
        return true
    }

    /**
     Check 'string' if it's empty and callback failure if it is.

     - parameter string:  the string to check
     - parameter failure: the closure to invoke if validation fails

     - returns: true if string is not empty
     */
    public class func validateStringNotEmpty(_ string: String, _ failure: ((String) -> ())?) -> Bool {
        if string.isEmpty {
            failure?("Empty string")
            return false
        }
        return true
    }

    /**
     Check if the string is positive number and if not, then callback failure and return false.

     - parameter numberString: the string to check
     - parameter failure:      the closure to invoke if validation fails

     - returns: true if given string is positive number
     */
    public class func validatePositiveNumber(_ numberString: String, _ failure: ((String) -> ())?) -> Bool {
        if !numberString.isPositiveNumber() {
            failure?("Incorrect number: \(numberString)")
            return false
        }
        return true
    }

    /**
     Check if the string represents email

     - parameter email:   the text to validate
     - parameter failure: the closure to invoke if validation fails

     - returns: true if the given string is a valid email
     */
    public class func validateEmail(_ email: String, _ failure: FailureCallback?) -> Bool {
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"

        if email.trim() ≈ emailPattern {
            return true
        }
        let errorMessage = NSLocalizedString("Incorrect email format", comment: "Incorrect email format")
        if email.isEmpty {
            failure?("\(errorMessage).")
        }
        else {
            failure?("\(errorMessage): \(email).")
        }
        return false
    }
}

