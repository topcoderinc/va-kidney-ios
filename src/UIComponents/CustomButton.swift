//
//  CustomButton.swift
//  UIComponents
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Button with some changes according to design
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable public class CustomButton: UIButton {

    /// the radius of the corners
    @IBInspectable public var cornerRaduis: CGFloat = 4

    /// the border color
    @IBInspectable public var borderColor: UIColor = Colors.border {
        didSet {
            self.setNeedsLayout()
        }
    }

    /// the background color for selected state
    @IBInspectable public var selectedBgColor: UIColor = Colors.lightGray {
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
        self.backgroundColor = isSelected ? selectedBgColor : UIColor.white

        self.layer.cornerRadius = cornerRaduis
        self.layer.masksToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }


    /// is selected
    override public var isSelected: Bool {
        didSet {
            self.setNeedsLayout()
        }
    }
}

