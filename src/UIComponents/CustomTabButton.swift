//
//  CustomTabButton.swift
//  UIComponents
//
//  Created by TCCODER on 12/22/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Custom tab button
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable public class CustomTabButton: UIButton {

    /// the border color
    @IBInspectable public var borderColor: UIColor = Colors.border {
        didSet {
            self.setNeedsLayout()
        }
    }

    /// the border width
    @IBInspectable public var borderWidth: CGFloat = 1

    /// Apply UI changes
    public override func layoutSubviews() {
        super.layoutSubviews()

        setTitleColor(Colors.black, for: .normal)
        self.backgroundColor = isSelected ? UIColor.white : Colors.lightGray

        self.layer.masksToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = isSelected ? borderWidth : 0
    }

    /// is selected
    override public var isSelected: Bool {
        didSet {
            self.setNeedsLayout()
        }
    }
}
