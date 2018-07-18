//
//  CircleProgress.swift
//  UIComponents
//
//  Created by TCCODER on 2/2/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import QuartzCore
import UIKit

/**
 * Circle diagram with color sectors
 *
 * - author TCCODER
 * - version 1.0
 */
@IBDesignable public class CircleProgress: UIView {

    /// the main color
    @IBInspectable public var mainColor: UIColor = UIColor(red: 76/255, green: 188/255, blue: 119/255, alpha: 1.0) { didSet{ setNeedsLayout()} }

    /// the background color
    @IBInspectable public var bgColor: UIColor = UIColor.white { didSet{ setNeedsLayout()} }

    /// the progress value
    @IBInspectable public var processValue: Float = 0.75 {
        didSet {
            values = [1, processValue]
        }
    }

    /// values to be shown as sectors
    public var values: [Float] = [100,75] {
        didSet {
            clearSectors()
            self.setNeedsLayout()
        }
    }

    /// total sum of all values in 'values'
    var totalValue: Float {
        get {
            var totalValue: Float = 0
            for value in values {
                totalValue += value
            }
            return totalValue
        }
    }

    /// maximum of all values in 'values'
    private var maxValue: Float {
        get {
            var maxValue: Float = 0
            for value in values {
                maxValue = max(maxValue, value)
            }
            return maxValue
        }
    }

    /// the missing and start angle
    private let missingAngle: CGFloat = 118
    private var startAngle: CGFloat = 0

    /*
     The percent of the circle that all sectors are fit in.
     Used for initial animation of the circle.
     */
    @IBInspectable public var percentOfShow: CGFloat = 1 {
        didSet {
            if percentOfShow > 1 {
                percentOfShow = 1
            }
            updateLayerProperties()
        }
    }

    /// Line width
    @IBInspectable var lineWidth: CGFloat = 4 {
        didSet {
            updateLayerProperties()
        }
    }

    /// the sectors
    private var sectors: [CAShapeLayer]!


    /// Layout subviews
    public override func layoutSubviews() {
        let colors = [bgColor, Colors.green]

        // calculate start angle
        startAngle = -(360 - missingAngle)/2 * (CGFloat.pi / 180) - CGFloat.pi / 2

        // Sectors
        if sectors == nil {
            sectors = [CAShapeLayer]()
            var i = 0
            let bounds = getCirlceBounds()
            var rect = bounds.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0)
            rect = CGRect(origin: CGPoint(x: -rect.width / 2, y: -rect.height / 2), size: rect.size)

            // Correct inputs for transformation
            let alpha = -CGFloat.pi / 4 // the way to move the circle to the center of the view
            let beta = startAngle
            let a = alpha + beta
            let distance = sqrt(bounds.width * bounds.width + bounds.height * bounds.height) / 2
            let dx = cos(a) * distance
            let dy = -sin(a) * distance
            for _ in self.values {
                let sector = CAShapeLayer()
                layer.addSublayer(sector)
                sectors.append(sector)

                let path = UIBezierPath(ovalIn: rect)
                sector.path = path.cgPath
                sector.fillColor = nil
                sector.lineWidth = lineWidth
                sector.strokeColor = colors[i % colors.count].cgColor
                sector.lineCap = kCALineCapRound

                sector.transform = CATransform3DRotate(sector.transform, beta, 0, 0, 1)
                sector.transform = CATransform3DTranslate(sector.transform, dx, dy, 0)
                i += 1
            }
        }
        var i = 0
        for sector in sectors {
            sector.frame = CGRect(origin: CGPoint(x: -layer.bounds.width/2, y: -layer.bounds.height/2), size: layer.bounds.size)
            sector.strokeColor = colors[i % colors.count].cgColor
            i += 1
        }
        updateLayerProperties()
        super.layoutSubviews()
    }

    /// Get circle bounds
    ///
    /// - Returns: the bounds
    private func getCirlceBounds() -> CGRect {
        if bounds.width < bounds.height {
            return CGRect(x: 0, y: (bounds.height - bounds.width) / 2, width: bounds.width, height: bounds.width)
        }
        else {
            return CGRect(x: (bounds.width - bounds.height) / 2, y: 0, width: bounds.height, height: bounds.height)
        }
    }

    /// Remove existing sectors
    private func clearSectors() {
        if sectors != nil {
            for sector in sectors {
                sector.removeFromSuperlayer()
            }
            sectors = nil
        }
    }

    /// Update layer properties
    func updateLayerProperties() {
        if sectors != nil {
            var i = 0
            let maxValue = self.maxValue
            let globalPercent: CGFloat = 1 - missingAngle/360
            for sector in sectors {
                let value = values[i]
                sector.strokeStart = 0
                sector.strokeEnd = CGFloat(value / maxValue) * percentOfShow * globalPercent
                i += 1
            }
        }
    }
}

