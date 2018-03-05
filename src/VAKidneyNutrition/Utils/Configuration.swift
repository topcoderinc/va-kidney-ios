//
//  Configuration.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation

/**
 * Configuration reads config from configuration.plist in the app bundle
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Configuration: NSObject {

    /// NDB base URL for API.
    var ndbApiBaseUrl = ""

    /// NDB API key
    var ndbApiKey = ""

    /// FDA base URL for API.
    var fdaApiBaseUrl = ""

    /// FDA API key
    var fdaApiKey = ""

    // singleton
    static let shared = Configuration()

    /// Reads configuration file
    override init() {
        super.init()
        self.readConfigs()
    }

    // MARK: private methods

    /// Read configs from plist
    func readConfigs() {
        if let path = getConfigurationResourcePath() {
            let configDicts = NSDictionary(contentsOfFile: path)

            self.ndbApiBaseUrl = getUrl("ndbApiBaseUrl") ?? ""
            self.ndbApiKey = configDicts?["ndbApiKey"] as? String ?? self.ndbApiKey
            self.fdaApiBaseUrl = getUrl("fdaApiBaseUrl") ?? ""
            self.fdaApiKey = configDicts?["fdaApiKey"] as? String ?? self.fdaApiKey
        }
        else {
            assert(false, "configuration is not found")
        }
    }

    /// Get URL
    ///
    /// - Parameter key: the key
    /// - Returns: the URL option or nil
    private func getUrl(_ key: String) -> String? {
        if let path = getConfigurationResourcePath() {
            let configDicts = NSDictionary(contentsOfFile: path)

            if let url = configDicts?[key] as? String {
                var clearUrl = url.trim()
                if !clearUrl.isEmpty {
                    if clearUrl.hasPrefix("http") {
                        // Fix "/" at the end if needed
                        if !clearUrl.hasSuffix("/") {
                            clearUrl += "/"
                        }
                        return clearUrl
                    }
                }
            }
        }
        return nil
    }

    /// Get the path to the configuration.plist.
    ///
    /// - Returns: the path to configuration.plist
    func getConfigurationResourcePath() -> String? {
        return Bundle(for: Configuration.classForCoder()).path(forResource: "configuration", ofType: "plist")
    }
}

