//
//  HelpfulFunctions.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/**
 A set of helpful functions and extensions
 */
/**
 * Extenstion adds helpful methods to String
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension String {

    /// the length of the string
    var length: Int {
        return self.count
    }

    /// Get string without spaces at the end and at the start.
    ///
    /// - Returns: trimmed string
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }

    /**
     Checks if string contains given substring

     - parameter substring:     the search string
     - parameter caseSensitive: flag: true - search is case sensitive, false - else

     - returns: true - if the string contains given substring, false - else
     */
    func contains(_ substring: String, caseSensitive: Bool = true) -> Bool {
        if let _ = self.range(of: substring,
                              options: caseSensitive ? NSString.CompareOptions(rawValue: 0) : .caseInsensitive) {
            return true
        }
        return false
    }

    /// Checks if string contains given substring
    ///
    /// - Parameter find: the search string
    /// - Returns: true - if the string contains given substring, false - else
    func contains(_ find: String) -> Bool{
        if let _ = self.range(of: find){
            return true
        }
        return false
    }

    /// Shortcut method for replacingOccurrences
    ///
    /// - Parameters:
    ///   - target: the string to replace
    ///   - withString: the string to add instead of target
    /// - Returns: a result of the replacement
    public func replace(_ target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString,
                                         options: NSString.CompareOptions.literal, range: nil)
    }

    /// Checks if the string is number
    ///
    /// - Returns: true if the string presents number
    func isNumber() -> Bool {
        let formatter = NumberFormatter()
        if let _ = formatter.number(from: self) {
            return true
        }
        return false
    }

    /// Checks if the string is positive number
    ///
    /// - Returns: true if the string presents positive number
    func isPositiveNumber() -> Bool {
        let formatter = NumberFormatter()
        if let number = formatter.number(from: self) {
            if number.doubleValue > 0 {
                return true
            }
        }
        return false
    }

    /// Get URL encoded string
    ///
    /// - Returns: URL encoded string
    public func urlEncodedString() -> String {
        var set = CharacterSet.urlQueryAllowed
        set.remove(charactersIn: ":?&=@+/'")
        return self.addingPercentEncoding(withAllowedCharacters: set) ?? self
    }

    /// Split string with given character
    ///
    /// - Parameter separator: the separator
    /// - Returns: the array of strings
    func split(_ separator: Character) -> [String] {
        return self.split(separator: separator).map({String($0)})
    }
}

/// allow throwing strings
extension String: Error {}

/**
 *  Helper class for regular expressions
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String

    init(_ pattern: String) {
        self.pattern = pattern
        self.internalExpression = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }

    func test(_ input: String) -> Bool {
        let matches = self.internalExpression.matches(in: input, options: [],
                                                      range:NSMakeRange(0, input.count))
        return matches.count > 0
    }
}
precedencegroup RegexPrecedence {
    lowerThan: AdditionPrecedence
}

// Define operator for simplisity of Regex class
infix operator ≈: RegexPrecedence
public func ≈(input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}

/**
 Shows an alert with the title and message.

 - parameter title:      the title
 - parameter message:    the message
 - parameter completion: the completion callback
 */
func showAlert(_ title: String, message: String, completion: (()->())? = nil) {
    UIViewController.getCurrentViewController()?.showAlert(title, message, completion: completion)
}

/**
 Show alert with given error message

 - parameter errorMessage: the error message
 - parameter completion:   the completion callback
 */
func showError(errorMessage: String, completion: (()->())? = nil) {
    showAlert(NSLocalizedString("Error", comment: "Error alert title"), message: errorMessage, completion: completion)
}

// Stub message
let ERROR_STUB = "This feature will be implemented in future"

/// Show alert message about stub functionalify
func showStub() {
    showAlert("Stub", message: ERROR_STUB)
}

/**
 * Shortcut methods for NSMutableAttributedString
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension NSMutableAttributedString {

    /// Adds underline
    func addUnderline() {
        self.addAttribute(.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, self.string.length))
    }
}

/**
 * Shortcut methods for UILabel
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UILabel {

    /// Adds underline
    func addUnderline() {
        let string = NSMutableAttributedString(string: self.text ?? "",
                                               attributes: [.font : self.font, .foregroundColor: self.textColor])
        string.addUnderline()
        self.attributedText = string
    }
}

/// Delays given callback invocation
///
/// - Parameters:
///   - delay: the delay in seconds
///   - callback: the callback to invoke after 'delay' seconds
func delay(_ delay: TimeInterval, callback: @escaping ()->()) {
    let delay = delay * Double(NSEC_PER_SEC)
    let popTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC);
    DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
        callback()
    })
}


/**
 * Extends UIImage with a shortcut method.
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UIImage {

    /// Convert image to data
    ///
    /// - Returns: the data
    func toData() -> Data? {
        if let data = UIImagePNGRepresentation(self) {
            return data
        }
        return nil
    }

    /// Convert data to image
    ///
    /// - Parameter data: the data
    /// - Returns: the image
    class func fromData(_ data: Data?) -> UIImage? {
        if let data = data {
            return UIImage(data: data)
        }
        return nil
    }
}

/**
 * Shortcut methods for Date
 *
 * - author:  TCCODER
 * - version: 1.3
 *
 * changes:
 * 1.1:
 * - new method
 * 1.2:
 * - new method
 * 1.3:
 * - new methods
 */
extension Date {

    /// Returns now many hours, minutes, etc. the date is from now.
    ///
    /// - Parameter useFullText: true - will use full text, e.g. " days", false - "d"
    /// - Returns: e.g. "5h ago" or "5 days ago"
    func timeAgo(useFullText: Bool) -> String {
        let timeInterval = Date().timeIntervalSince(self)

        let weeks = Int(floor(timeInterval / (7 * 3600 * 24)))
        let days = Int(floor(timeInterval / (3600 * 24)))
        let hours = Int(floor((timeInterval.truncatingRemainder(dividingBy: (3600 * 24))) / 3600))
        let minutes = Int(floor((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60))
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))

        if weeks > 0 { return "\(weeks)\(useFullText ? (weeks == 1 ? " week" : " weeks") : "w") ago" }
        if days > 0 { return  "\(days)\(useFullText ? (weeks == 1 ? " day" : " days") : "d") ago" }
        if hours > 0 { return "\(hours)\(useFullText ? (weeks == 1 ? " hour" : " hours") : "h") ago"}
        if minutes > 0 { return "\(minutes)\(useFullText ? (weeks == 1 ? " minute" : " minutes") : "m") ago" }
        if seconds > 0 { return "\(seconds)\(useFullText ? (weeks == 1 ? " second" : " seconds") : "s") ago" }
        return "just now"
    }

    /**
     Get number of years since current date till now

     - returns: the number of years
     */
    func yearsSinceDate() -> Int {
        let calendar = Calendar.current
        let comp = calendar.dateComponents([Calendar.Component.year], from: self, to: Date())
        return comp.year ?? 0
    }

    /// Get weekday
    ///
    /// - Returns: 1 - subday, 2 - monday, etc.
    func getWeekday() -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }

    /// Create any date with given weekday
    ///
    /// - Parameter weekday: the weekday
    /// - Returns: date
    static func create(withWeekday weekday: Int) -> Date {

        let calendar = Calendar.current
        var comp = calendar.dateComponents([.year, .month, .day], from: Date())
        let diff = (comp.weekday ?? 1) - weekday
        return Date().addDays(-diff)
    }

    /// Add days to the date
    ///
    /// - Parameter daysToAdd: the number of days to add
    /// - Returns: changed date
    func addDays(_ daysToAdd: Int) -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.day = daysToAdd

        let date = calendar.date(byAdding: components, to: self)!
        return date
    }

    /// Add months to the date
    ///
    /// - Parameter months: the number of months to add
    /// - Returns: changed date
    func addMonths(_ months: Int) -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.month = months

        let date = calendar.date(byAdding: components, to: self)!
        return date
    }

    /**
     Check if the date corresponds to the same day

     - parameter date: the date to check

     - returns: true - if the date has same year, month and day
     */
    func isSameDay(date: Date) -> Bool {
        let date1 = self
        let calendar = Calendar.current
        let comps1 = calendar.dateComponents([.month, .year, .day], from: date1)
        let comps2 = calendar.dateComponents([.month, .year, .day], from: date)

        return (comps1.day == comps2.day) && (comps1.month == comps2.month) && (comps1.year == comps2.year)
    }

    /// Convert date to month value for charts
    ///
    /// - Returns: the value
    func toChartMonthValue() -> Double {
        let year = Int(DateFormatters.year.string(from: self)) ?? 0
        let month = Int(DateFormatters.month.string(from: self)) ?? 0
        return Double(year * 12 + month)
    }

    /// Convert date to day value for charts
    ///
    /// - Returns: the value
    func toChartDayValue() -> Double {
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: 0)
        let comp = calendar.dateComponents([.day], from: date, to: self)
        return Double(comp.day ?? 0)
    }

    /// Convert chart value into date
    ///
    /// - Parameter value: the value
    /// - Returns: the date
    static func fromChartMonthValue(_ value: Double) -> Date {
        let calendar = Calendar.current
        let year = Int(floor(value/12))
        let month = Int(value.truncatingRemainder(dividingBy: 12))
        let comp = DateComponents(calendar: calendar, timeZone: TimeZone.current, year: year, month: month, day: 15)
        return calendar.date(from: comp) ?? Date()
    }

    /// Convert chart value into date
    ///
    /// - Parameter value: the value
    /// - Returns: the date
    static func fromChartDayValue(_ value: Double) -> Date {
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: 0)
        return calendar.date(byAdding: .day, value: Int(value), to: date) ?? Date()
    }

    /// Check if current date is after the given date
    ///
    /// - Parameter date: the date to check
    /// - Returns: true - if current date is after
    func isAfter(_ date: Date) -> Bool {
        return self.compare(date) == ComparisonResult.orderedDescending
    }

    /// Get date between the given two dates
    ///
    /// - Parameters:
    ///   - date1: the first date
    ///   - date2: the second date
    /// - Returns: the date
    static func getMeanDate(_ date1: Date, _ date2: Date) -> Date {
        var start = date1
        var end = date2
        if start.isAfter(end) {
            start = date2
            end = date1
        }
        let timeInterval = end.timeIntervalSince(start)
        return start.addingTimeInterval(timeInterval / 2)
    }

    /// Get Date that corresponds to the start of current day.
    ///
    /// - Returns: the date
    func beginningOfDay() -> Date {
        let calendar = Calendar.current

        let components = calendar.dateComponents([.month, .year, .day], from: self)

        return calendar.date(from: components)!
    }

    /// Get Date that corresponds to the end of current day
    ///
    /// - Returns: the date
    func endOfDay() -> Date {
        var date = nextDayStart()
        date = date.addingTimeInterval(-1)
        return date
    }

    /// Get the next day start
    ///
    /// - Returns: the date
    func nextDayStart() -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.day = 1

        let date = calendar.date(byAdding: components, to: self.beginningOfDay())!
        return date
    }
}

/**
 * Date and time formatters
 *
 * - author: TCCODER
 * - version: 1.4
 *
 * changes:
 * 1.1:
 * - new formatters
 * 1.2:
 * - new formatter
 * 1.3:
 * - bug fixed
 * 1.4:
 * - new formatters
 */
struct DateFormatters {

    /// short date formatter
    static var shortDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        f.timeZone = TimeZone.current
        return f
    }()

    /// short date formatter for Food form
    static var foodForm: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        f.timeZone = TimeZone.current
        return f
    }()

    /// short date formatter for Profile screen
    static var profileDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM dd yyyy"
        f.timeZone = TimeZone.current
        return f
    }()

    /// time formatter
    static var time: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        f.timeZone = TimeZone.current
        return f
    }()

    /// date formatter used to parse date from response
    static var responseDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(abbreviation: "GMT")
        return f
    }()

    /// date formatter used to print weekday
    static var weekday: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        f.timeZone = TimeZone(abbreviation: "GMT")
        return f
    }()

    /// date parser for FDA response date
    static var pdaDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        f.timeZone = TimeZone(abbreviation: "GMT")
        return f
    }()

    /// year
    static var year: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        f.timeZone = TimeZone.current
        return f
    }()

    /// month
    static var month: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM"
        f.timeZone = TimeZone.current
        return f
    }()

    /// day
    static var day: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd"
        f.timeZone = TimeZone.current
        return f
    }()

}

/**
 * Helpful extension for arrays
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - new method
 */
extension Array {

    /**
     Convert array to hash array

     - parameter transform: the transformation of an object to a key

     - returns: a hashmap
     */
    func hashmapWithKey<K>(_ transform: (Element) -> (K)) -> [K:Element] {
        var hashmap = [K:Element]()

        for item in self {
            let key = transform(item)
            hashmap[key] = item
        }
        return hashmap
    }

    /**
     Convert array to hash array

     - parameter transform: the transformation of an object to a key

     - returns: a hashmap with arrays as values
     */
    func hasharrayWithKey<K>(_ transform: (Element) -> (K)) -> [K:[Element]] {
        var hashmap = [K:[Element]]()

        for item in self {
            let key = transform(item)
            var a = hashmap[key]
            if a == nil {
                a = [Element]()
                hashmap[key] = a
            }
            a!.append(item)
            hashmap[key] = a
        }
        return hashmap
    }
}

/**
 * Extenstion adds helpful methods to Float
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - new method
 * 1.2:
 * - new method
 */
extension Float {

    /**
     Check if the value is integer

     - returns: true - if integer value, false - else
     */
    func isInteger() -> Bool {
        if self > Float(Int.max)
            || self < Float(Int.min) {
            print("ERROR: the value can not be converted to Int because it is greater/smaller than Int.max/min")
            return false
        }
        return  self == Float(Int(self))
    }

    /// Convert to string
    ///
    /// - Returns: string representation of the rounded value
    func toString() -> String {
        let value = self
        if value.isInteger() {
            return NSString.localizedStringWithFormat("%.f", value.rounded()) as String
        }
        else  {
            return NSString.localizedStringWithFormat("%.1f", value) as String
        }
    }

    /// Convert to clear string
    ///
    /// - Returns: string representation of the rounded value
    func toStringClear() -> String {
        return toString().replace(",", withString: "")
    }

    /// Convert to string. E.g. 1 -> "1", 1.2 -> "1.2", 1.2345 -> "1.2345"
    ///
    /// - Returns: string representation of the rounded value
    func toItemValueString() -> String {
        let value = self
        if value.isInteger() {
            return (NSString.localizedStringWithFormat("%.f", value.rounded()) as String).replace(",", withString: "")
        }
        else  {
            return "\(self)"
        }
    }
}

/**
 * Extenstion adds helpful methods to Int
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension Int {

    /// Get "x points" text
    ///
    /// - Returns: the text
    func toPointsText() -> String {
        return "\(self) \(self == 1 ? "point" : "points")"
    }

    /// Get hour as text
    ///
    /// - Returns: the text
    func toHourText() -> String {
        return self < 13 ? "\(self):00 AM" : "\(self - 12):00 PM"
    }
}

/**
 * Extenstion adds helpful methods to NSRange
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension NSRange {

    /// Convert to Range for given string
    ///
    /// - Parameter string: the string
    /// - Returns: range
    func toRange(string: String) -> Range<String.Index> {
        let range = string.index(string.startIndex, offsetBy: self.lowerBound)..<string.index(string.startIndex, offsetBy: self.upperBound)
        return range
    }
}

/// Check if iPhone5 like device
///
/// - Returns: true - if this device has width as on iPhone5, false - else
func isIPhone5() -> Bool {
    return UIScreen.main.nativeBounds.width == 640
}

/**
 * Dictionary Extension
 * Some useful functions added to Dictionary class
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension Dictionary {

    /// Create url string from Dictionary
    ///
    /// - Returns: the url string
    func toURLString() -> String {
        var urlString = ""

        // Iterate all key,value and form the url string
        for (key, value) in self {
            let keyEncoded = (key as! String).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let valueEncoded = (value as! String).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            urlString += ((urlString == "") ? "" : "&") + keyEncoded + "=" + valueEncoded
        }
        return urlString
    }
}
