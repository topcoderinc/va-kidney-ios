//
//  UIExtensions.swift
//  UIComponents
//
//  Created by TCCODER on 2/1/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 A set of helpful extensions for classes from UIKit
 */

/**
 * Shortcut methods for UIView
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UIView {

    /// Make round corners for the view
    ///
    /// - Parameter radius: the radius of the corners
    public func roundCorners(_ radius: CGFloat = 4) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    /// Make the view round
    public func makeRound() {
        self.layoutIfNeeded()
        self.roundCorners(self.bounds.height / 2)
    }

    /// Add shadow to the view
    ///
    /// - Parameters:
    ///   - size: the size of the shadow
    ///   - shift: the shift
    ///   - opacity: the opacity
    public func addShadow(size: CGFloat = 4, shift: CGFloat? = 1, opacity: Float = 0.33) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: shift ?? size)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = size
    }

    /// Add border for the view
    ///
    /// - Parameters:
    ///   - color: the border color
    ///   - borderWidth: the size of the border
    public func addBorder(color: UIColor = Colors.blue, borderWidth: CGFloat = 0.5) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
    }
}

/**
 * Extends UIColor with helpful methods
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - new initializer
 */
extension UIColor {

    /// Creates new color with RGBA values from 0-255 for RGB and a from 0-1
    ///
    /// - Parameters:
    ///   - r: the red color
    ///   - g: the green color
    ///   - b: the blue color
    ///   - a: the alpha color
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }

    /**
     Get same color with given transparancy

     - parameter alpha: the alpha channel

     - returns: the color with alpha channel
     */
    public func alpha(alpha: CGFloat) -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b :CGFloat = 0
        if (self.getRed(&r, green:&g, blue:&b, alpha:nil)) {
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        }
        return self
    }

    /// Create new color with hex values
    ///
    /// - Parameter hex: the color in hex
    public convenience init(hex: Int) {
        let components = (
            r: CGFloat((hex >> 16) & 0xff) / 255,
            g: CGFloat((hex >> 08) & 0xff) / 255,
            b: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.r, green: components.g, blue: components.b, alpha: 1)
    }

    /**
     Get UIColor from hex string, e.g. "FF0000" -> red color

     - parameter hexString: the hex string
     - returns: the UIColor instance or nil
     */
    public class func fromString(_ hexString: String) -> UIColor? {
        if hexString.count == 6 {


            let redStr = hexString[..<hexString.index(hexString.startIndex, offsetBy: 2)]
            let greenStr = hexString[hexString.index(hexString.startIndex, offsetBy: 2)..<hexString.index(hexString.startIndex, offsetBy: 4)]
            let blueStr = hexString[hexString.index(hexString.startIndex, offsetBy: 4)..<hexString.index(hexString.startIndex, offsetBy: 6)]
            return UIColor(
                r: CGFloat(Int(redStr, radix: 16)!),
                g: CGFloat(Int(greenStr, radix: 16)!),
                b: CGFloat(Int(blueStr, radix: 16)!))
        }
        return nil
    }

    /// Convert to string, e.g. "#FF0000"
    ///
    /// - Returns: the string
    public func toString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let redStr = Int(red * alpha * 255 + 255 * (1 - alpha)).toHexString()
        let greenStr = Int(green * alpha * 255 + 255 * (1 - alpha)).toHexString()
        let blueStr = Int(blue * alpha * 255 + 255 * (1 - alpha)).toHexString()
        return "\(redStr)\(greenStr)\(blueStr)"
    }
}

// the main font prefix
public let FONT_PREFIX = "MyriadPro"

/**
 * Common fonts used in the app
 *
 * - author: TCCODER
 * - version: 1.0
 */
public struct Fonts {

    public static var Regular = "\(FONT_PREFIX)-Regular"
    public static var Bold = "\(FONT_PREFIX)-Bold"
    public static var Semibold = "\(FONT_PREFIX)-Semibold"

}

/**
 * Extenstion adds helpful methods to Int
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension Int {

    /// Convert to hex string
    ///
    /// - Returns: hex string
    func toHexString() -> String {
        return String(format: "%02hhx", self)
    }
}
