//
//  CustomView.swift
//  UIComponents
//
//  Created by TCCODER on 12/22/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Custom view with borders
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable open class CustomView: UIView {

    /// flag: true - will show bottom line, false - else
    @IBInspectable public var showBottomLine: Bool = false { didSet { self.setNeedsDisplay() } }

    /// flag: true - will show top line, false - else
    @IBInspectable public var showTopLine: Bool = false { didSet { self.setNeedsDisplay() } }

    /// flag: true - will show left line, false - else
    @IBInspectable public var showLeftLine: Bool = false { didSet { self.setNeedsDisplay() } }

    /// flag: true - will show right line, false - else
    @IBInspectable public var showRightLine: Bool = false { didSet { self.setNeedsDisplay() } }

    /// the border color
    @IBInspectable public var borderColor: UIColor = Colors.border { didSet { self.setNeedsDisplay() } }

    /// the height of the line
    @IBInspectable public var lineHeight: CGFloat = 0.5 { didSet { self.setNeedsDisplay() } }

    /// Draw extra underline
    ///
    /// - Parameter rect: the rect to draw in
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        borderColor.set()
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.setLineWidth(lineHeight)
        if showBottomLine {
            currentContext?.move(to: CGPoint(x: 0, y: self.bounds.height - lineHeight/2))
            currentContext?.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - lineHeight/2))
            currentContext?.strokePath()
        }
        if showTopLine {
            currentContext?.move(to: CGPoint(x: 0, y: lineHeight/2))
            currentContext?.addLine(to: CGPoint(x: self.bounds.width, y: lineHeight/2))
            currentContext?.strokePath()
        }
        if showLeftLine {
            currentContext?.move(to: CGPoint(x: lineHeight/2, y: 0))
            currentContext?.addLine(to: CGPoint(x: lineHeight/2, y: self.bounds.height))
            currentContext?.strokePath()
        }
        if showRightLine {
            currentContext?.move(to: CGPoint(x: self.bounds.width - lineHeight/2, y: 0))
            currentContext?.addLine(to: CGPoint(x: self.bounds.width - lineHeight/2, y: self.bounds.height))
            currentContext?.strokePath()
        }
    }
}
