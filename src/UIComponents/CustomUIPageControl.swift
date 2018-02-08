//
//  CustomUIPageControl.swift
//  UIComponents
//
//  Created by TCCODER on 2/2/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Custom UIPageControl
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable public class CustomUIPageControl: UIPageControl {

    /// Designated initializer
    ///
    /// - Parameter aDecoder: frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    /// Required initializer
    ///
    /// - Parameter aDecoder: decoder
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }

    /// Setups view
    func setupView() {
        updateDots()
    }

    /// Apply UI changes
    public override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }

    /// Update dots look
    func updateDots() {
        for i in 0..<self.subviews.count {
            let view = self.subviews[i]
            if i == self.currentPage {
                view.layer.borderWidth = 0
                view.layer.backgroundColor = Colors.darkBlue.cgColor
            }
            else {

                view.layer.borderWidth = 1.5
                view.layer.backgroundColor = UIColor.clear.cgColor
                view.layer.borderColor = UIColor(red: 137/255, green: 150/255, blue: 160/255, alpha: 1).cgColor

            }
            view.setNeedsDisplay()
        }
    }
}
