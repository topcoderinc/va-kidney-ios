//
//  WelcomeBackgroundView.swift
//  UIComponents
//
//  Created by Volkov Alexander on 7/17/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation

@IBDesignable public class WelcomeBackgroundView: UIView {

    /// the colors
    @IBInspectable public var leftColor: UIColor = Colors.darkBlue { didSet{ setNeedsLayout()} }
    @IBInspectable public var rightColor: UIColor = Colors.green { didSet{ setNeedsLayout()} }

    /// Draw extra underline
    ///
    /// - Parameter rect: the rect to draw in
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        leftColor.set()
        let shift: CGFloat = 21
        let leftBounds = CGRect(x: 0, y: 0, width: self.bounds.width / 2, height: self.bounds.height)
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.move(to: leftBounds.origin)
        currentContext?.addLine(to: CGPoint(x: leftBounds.size.width + shift, y: 0))
        currentContext?.addLine(to: CGPoint(x: leftBounds.size.width, y: leftBounds.size.height))
        currentContext?.addLine(to: CGPoint(x: 0, y: leftBounds.size.height))
        currentContext?.fillPath()

        rightColor.set()
        currentContext?.move(to: CGPoint(x: leftBounds.width + shift * 2, y: 0))
        currentContext?.addLine(to: CGPoint(x: self.bounds.width, y: 0))
        currentContext?.addLine(to: CGPoint(x: self.bounds.width, y: leftBounds.size.height))
        currentContext?.addLine(to: CGPoint(x: leftBounds.width + shift, y: leftBounds.size.height))
        currentContext?.fillPath()
    }
    
}
