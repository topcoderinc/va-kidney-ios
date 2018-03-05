//
//  RESTApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/// option: true - will print HTTP requests and responses in console, false - else
let OPTION_PRINT_REST_API_LOGS = true

/// type alias for the callback used to return an occurred error and JSON content if pesented
public typealias RestFailureCallback = (String, JSON?)->()

/// Content types that the server supports
enum ContentType: String {
    case JSON = "application/json"
    case FORM = "application/x-www-form-urlencoded"
    case OTHER = ""
}

/**
 * RESTError
 * ErrorType for RESTApi
 *
 * - author: TCCODER
 * - version: 1.0
 */
enum RESTError: Error, CustomStringConvertible {

    // common network and API errors
    case NoNetworkConnection
    case InvalidResponse
    case Failure(message: String)
    case WrongParameters(message: String)

    /// error description
    var description: String {
        switch self {
        case .NoNetworkConnection: return NSLocalizedString("No network connection available",
                                                            comment: "No network connection available")
        case .InvalidResponse: return NSLocalizedString("Invalid response from server",
                                                        comment: "Invalid response from server")
        case .Failure(let message): return "\(message)"
        case .WrongParameters(let message): return message
        }
    }
}

/// HTTP methods for requests
public enum RESTMethod: String {
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
}

/// the key for storing access token
let kAccessToken = "kAccessToken"

/**
 * RESTApi
 * Basic class to implement Rest API
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RESTApi {

    private struct Static {
        static var instance: RESTApi?
        static var token: Int = 0
    }

    private static var __once: () = {
        Static.instance = RESTApi(baseUrl: "")
    }()

    /// the singleton
    public class var sharedInstance : RESTApi {
        _ = RESTApi.__once
        return Static.instance!
    }

    /// the base URL for API
    private let baseUrl: String

    /// The access token. Has public setter `setAccessToken()`.
    private var accessToken: String?

    // This prevents others from using the default '()' initializer for this class.
    internal init(baseUrl: String) {
        self.baseUrl = baseUrl
    }

    /// the authorization header
    fileprivate let AUTH_HEADER = "Authorization"

    /// the list of endpoints that should be invoked without access token in the header
    internal var endpointsToSkipAccessToken: [String] {
        get {
            return []
        }
    }

    /// the list of HTTP codes (and related endpoints) that are not critical
    internal var extraAllowedHttpCodes: [Int] { get { return [401] } }
    internal var endpointsForExtraAllowedHttpCodes: [String] { get { return ["logout"] } }

    /// Set the access token
    ///
    /// - Parameter token: the token. If nil, then clean up.
    func setAccessToken(_ token: String?) {
        accessToken = token
    }

    /// Check is has access token
    func hasAccessToken() -> Bool {
        return accessToken != nil
    }

    deinit {
        print("deinit: RESTApi")
    }

    // MARK: - Common methods

    /**
     Create request with JSON parameters

     - parameter method:     the method
     - parameter endpoint:   the endpoint
     - parameter parameters: the parameters
     - parameter failure:    the callback to invoke when an error occurred

     - returns: the request
     */
    func createJsonRequest(method: RESTMethod, endpoint: String, parameters: [String: Any],
                           failure: RestFailureCallback) -> URLRequest  {
        return createRequest(method: method, endpoint: endpoint, contentType: ContentType.JSON, parameters: parameters, failure: failure)
    }

    /**
     Create request with JSON parameters

     - parameter method:     the method
     - parameter endpoint:   the endpoint
     - parameter parameters: the parameters
     - parameter failure:    the callback to invoke when an error occurred

     - returns: the request
     */
    func createFormRequest(method: RESTMethod, endpoint: String, parameters: [String: Any],
                           failure: RestFailureCallback) -> URLRequest  {

        return createRequest(method: method, endpoint: endpoint, contentType: ContentType.FORM, parameters: parameters, failure: failure)
    }

    /**
     Create request with JSON parameters

     - parameter method:     the method
     - parameter endpoint:   the endpoint
     - parameter contentType: the content type
     - parameter parameters: the parameters
     - parameter failure:    the callback to invoke when an error occurred

     - returns: the request
     */
    func createRequest(method: RESTMethod, endpoint: String, contentType: ContentType, parameters: [String: Any],
                       failure: RestFailureCallback) -> URLRequest  {
        var url = endpoint.hasPrefix("http://") ? endpoint : "\(baseUrl)\(endpoint)"
        var body: Data?
        if method == .GET {
            if !parameters.isEmpty {
                let params = parameters.toURLString()
                url = "\(url)?\(params)"
            }
        }
        else {
            if contentType == .FORM {
                body = parameters.toURLString().data(using: String.Encoding.utf8)
            }
            else if contentType == .JSON {
                do {
                    body = try JSONSerialization.data(withJSONObject: parameters,
                                                      options: JSONSerialization.WritingOptions(rawValue: 0))
                }
                catch let error {
                    failure(error.localizedDescription, nil)
                }
            }
        }

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue
        if let accessToken = accessToken, !endpointsToSkipAccessToken.contains(endpoint) {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: AUTH_HEADER)
        }
        request.httpBody = body
        request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        return request
    }

    /**
     Send request and handle common errors

     - parameter request:  the request
     - parameter success:  the callback to return JSON response
     - parameter failure:  the callback to invoke when an error occurred

     - throws: exceptions from NSURLSession.dataTaskWithRequest
     */
    func sendRequestAndParseJson(request: URLRequest, log: Bool? = nil, success: @escaping (JSON)->(), failure: @escaping RestFailureCallback) {
        sendRequest(request: request, log: log, success: { (data, code) in

            // read json from data
            var json: JSON!
            if data.count > 0 {
                json = (try? JSON(data: data, options: JSONSerialization.ReadingOptions.allowFragments)) ?? JSON.null
            }
            else {
                json = JSON.null // Threat the empty content as success JSON response
            }

            DispatchQueue.main.async {
                if code >= 400 { // check common errors in response
                    // Check if the endpoint allows such HTTP code
                    let endpoint = (request.url?.absoluteString ?? "").replace(self.baseUrl, withString: "")
                    if self.extraAllowedHttpCodes.contains(code) && self.endpointsForExtraAllowedHttpCodes.contains(endpoint) {
                        print("WARNING: HTTP CODE \(code)")
                        success(json)
                    }
                    else if code == 401 && AuthenticationUtil.sharedInstance.isAuthenticated() { // need to logout
                        let showMessage: ()->() = {
                            showAlert(NSLocalizedString("Session expired", comment: "Session expired"),
                                      message: NSLocalizedString("Please login. The session has expired.", comment: "Please login. The session has expired."))
                        }
                        showMessage()
                    }
                    else if let errorMessage = json["message"].string ?? json["message"].array?.first?["message"].string {
                        failure(errorMessage, json)           // probably "code" is 40*, e.g. 404.
                    }
                    else {
                        failure("Unknown error", json)
                    }
                }
                else {
                    success(json)
                }
            }
        }, failure: failure)
    }

    /// Send request and handle common errors
    ///
    /// - Parameters:
    ///   - request: the request
    ///   - success: the callback to return data response and HTTP code (NOT in main queue, you must wrap it using DispatchQueue.main.async()
    ///   - failure: the callback to invoke when an error occurred (in main queue)
    func sendRequest(request: URLRequest, log: Bool? = nil, success: @escaping (Data, Int)->(), failure: @escaping RestFailureCallback) {
        // Check for network first
        if !Reachability.isConnectedToNetwork() {
            failure(RESTError.NoNetworkConnection.description, nil)
            return
        }
        let needToLog = log != nil ? log! : OPTION_PRINT_REST_API_LOGS
        if needToLog {
            logRequest(request)
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if needToLog {
                self.logResponse(data as AnyObject)
            }
            if let error = error {
                DispatchQueue.main.async {
                    failure(RESTError.Failure(message: error.localizedDescription).description, nil)
                }
                return
            }
            else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if let data = data {
                    if data.count < 10000 && !OPTION_PRINT_REST_API_LOGS {
                        print("HTTP \(statusCode)" + String(data: data, encoding: .utf8)!)
                    }
                    success(data, statusCode)
                    return
                }
            }
            DispatchQueue.main.async {
                failure(RESTError.InvalidResponse.localizedDescription, nil)
            }
        }
        task.resume()
    }


    /**
     Create FailureCallback for validating empty parameters.
     Wraps initial failure callback to return correct error message

     - parameter failure: the initial FailureCallback

     - returns: FailureCallback wrapper
     */
    func createFailureCallbackForEmptyParameters(_ failure: @escaping FailureCallback) -> FailureCallback {
        return { (_)->() in
            failure(RESTError.WrongParameters(message: NSLocalizedString("Please fill all fields",
                                                                         comment: "Please fill all fields")).description)
        }
    }

    /**
     Notifies with given request URL, Method and body

     - parameter request:       URLRequest to log
     - parameter needToLogBody: flag used to decide either to log body or not
     */
    private func logRequest(_ request: URLRequest, _ needToLogBody: Bool = true) {
        // Log request URL
        var info = "url"
        if let m = request.httpMethod { info = m }
        var logMessage = "[REQUEST] \(info): \(request.url!.absoluteString)"

        if needToLogBody {
            // log body if set
            if let body = request.httpBody {
                if let bodyAsString = String(data: body, encoding: .utf8) {
                    logMessage += "\n\tbody: \(bodyAsString)"
                }
            }
        }
        if let accessToken = request.allHTTPHeaderFields?[AUTH_HEADER] {
            logMessage += "\n\t\(AUTH_HEADER): \(accessToken)"
        }
        print(logMessage)
    }

    /**
     Notifies with given response object.

     - parameter object: response object
     */
    private func logResponse(_ object: AnyObject?) {
        var info: String = "[RESPONSE]:\n"
        if let o: AnyObject = object {
            if let data = o as? Data {
                let json = (try? JSON(data: data, options: JSONSerialization.ReadingOptions.allowFragments)) ?? JSON.null
                if json != JSON.null {
                    info += "\(json)"
                }
                else {
                    info += "Data[length=\(data.count)]"
                    if data.count < 10000 {
                        info += "\n" + (String(data: data, encoding: .utf8) ?? "")
                    }
                }
            }
            else {
                info += String(describing: o)
            }
        }
        else {
            info += "<null response>"
        }
        print(info)
    }

    // MARK: - Internal helpful methods

    /// Create and send GET request
    ///
    /// - Parameters:
    ///   - endpoint: the endpoint (without starting "/")
    ///   - parameters: the parameters
    ///   - success: the callback to invoke when success (returns JSON response)
    ///   - failure: the failure callback to return an error
    internal func get(_ endpoint: String, parameters: [String: Any] = [:], success: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        request(method: .GET, endpoint, parameters: parameters, success: success, failure: failure)
    }

    /// Create and send POST request
    ///
    /// - Parameters:
    ///   - endpoint: the endpoint (without starting "/")
    ///   - parameters: the parameters
    ///   - success: the callback to invoke when success (returns JSON response)
    ///   - failure: the failure callback to return an error
    internal func post(_ endpoint: String, parameters: [String: Any], success: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        request(method: .POST, endpoint, parameters: parameters, success: success, failure: failure)
    }

    /// Create and send PUT request
    ///
    /// - Parameters:
    ///   - endpoint: the endpoint (without starting "/")
    ///   - parameters: the parameters
    ///   - success: the callback to invoke when success (returns JSON response)
    ///   - failure: the failure callback to return an error
    internal func put(_ endpoint: String, parameters: [String: Any], success: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        request(method: .PUT, endpoint, parameters: parameters, success: success, failure: failure)
    }

    /// Create and send DELETE request
    ///
    /// - Parameters:
    ///   - endpoint: the endpoint (without starting "/")
    ///   - parameters: the parameters
    ///   - success: the callback to invoke when success (returns JSON response)
    ///   - failure: the failure callback to return an error
    internal func delete(_ endpoint: String, parameters: [String: Any], success: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        request(method: .DELETE, endpoint, parameters: parameters, success: success, failure: failure)
    }

    /// Create and send request
    ///
    /// - Parameters:
    ///   - method: HTTP method
    ///   - endpoint: the endpoint (without starting "/")
    ///   - parameters: the parameters
    ///   - success: the callback to invoke when success (returns JSON response)
    internal func request(method: RESTMethod, _ endpoint: String, parameters: [String: Any] = [:], success: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        let request = createJsonRequest(method: method, endpoint: endpoint, parameters: parameters, failure: wrapFailureCallback(failure))
        self.sendRequestAndParseJson(request: request, success: success, failure: wrapFailureCallback(failure))
    }

    /// Get next page index
    ///
    /// - Parameters:
    ///   - offset: the offset
    ///   - limit: the limit
    /// - Returns: the next page index
    internal func nextPage(_ offset: Any?, _ limit: Int) -> Int {
        if let offset = offset as? Int {
            return offset
        }
        return 0
    }

    /// Wraps failure callback
    ///
    /// - Parameter failure: FailureCallback
    /// - Returns: RestFailureCallback
    internal func wrapFailureCallback(_ failure: @escaping FailureCallback) -> RestFailureCallback {
        return { error, json in
            print("ERROR: response: \(String(describing: json))")
            failure(error)
        }
    }
}


