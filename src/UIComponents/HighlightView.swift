//
//  HighlightView.swift
//  UIComponents
//
//  Created by Volkov Alexander on 7/17/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation

@IBDesignable public class HighlightView: UIView {

    /// the color
    @IBInspectable public var color: UIColor = Colors.green { didSet{ setNeedsLayout()} }

    /// Draw extra underline
    ///
    /// - Parameter rect: the rect to draw in
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        color.set()
        let shift: CGFloat = self.bounds.height / 2
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.move(to: CGPoint(x: shift, y: 0))
        currentContext?.addLine(to: CGPoint(x: self.bounds.width, y: 0))
        currentContext?.addLine(to: CGPoint(x: self.bounds.width - shift, y: self.bounds.height))
        currentContext?.addLine(to: CGPoint(x: 0, y: self.bounds.height))
        currentContext?.fillPath()
    }

}
