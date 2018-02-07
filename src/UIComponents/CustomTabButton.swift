//
//  CustomTabButton.swift
//  UIComponents
//
//  Created by TCCODER on 12/22/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Custom tab button
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes
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
    }

    /// is selected
    override public var isSelected: Bool {
        didSet {
            self.setNeedsLayout()
        }
    }
}
