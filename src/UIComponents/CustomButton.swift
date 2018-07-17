//
//  CustomButton.swift
//  UIComponents
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Button with some changes according to design
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes
 */
@IBDesignable public class CustomButton: UIButton {

    /// the radius of the corners
    @IBInspectable public var cornerRaduis: CGFloat = 3

    /// the border color
    @IBInspectable public var borderColor: UIColor = Colors.darkBlue { didSet { self.setNeedsLayout() } }

    /// the title color
    @IBInspectable public var titleColor: UIColor? = nil { didSet { self.setNeedsLayout() } }

    /// the background color for selected state
    @IBInspectable public var selectedBgColor: UIColor = Colors.darkBlue {
        didSet {
            self.setNeedsLayout()
        }
    }

    /// the border width
    @IBInspectable public var borderWidth: CGFloat = 1

    /// the inner views
    private var shadowView: UIView!
    private var cornersView: UIView!

    /// Apply UI changes
    public override func layoutSubviews() {
        super.layoutSubviews()

        addRoundCorners()
        setTitleColor(UIColor.white, for: .selected)
        setTitleColor(titleColor ?? Colors.darkBlue, for: .normal)
        let disabledColor = titleColor(for: isSelected ? .selected : .normal) ?? titleColor ?? UIColor.black
        setTitleColor(disabledColor.alpha(alpha: 0.5), for: .disabled)
        self.backgroundColor = UIColor.clear
        if !isSelected {
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = borderWidth
        }
        else {
            self.layer.borderWidth = 0
        }
    }

    /// Add shadow view
    ///
    /// - Parameters:
    ///   - size: the size of the shadow
    ///   - shift: the shift
    ///   - opacity: the opacity
    private func addShadowView(size: CGFloat = 3, shift: CGFloat? = 1, opacity: Float = 1) {
        if shadowView == nil && opacity > 0 {
            shadowView = UIView()
            shadowView.isUserInteractionEnabled = false
            self.addSubview(shadowView)
            self.sendSubview(toBack: shadowView)
            shadowView.backgroundColor = selectedBgColor
        }
        if let shadowView = shadowView {
            let frame = self.bounds.insetBy(dx: cornerRaduis / 2, dy: cornerRaduis / 2)
            shadowView.frame = frame
            shadowView.addShadow(size: size, shift: shift, opacity: opacity)
        }
    }

    /// Add view with corners
    private func addRoundCorners() {
        if isSelected {
            if cornersView == nil  {
                cornersView = UIView()
                cornersView.isUserInteractionEnabled = false
                self.addSubview(cornersView)
                self.sendSubview(toBack: cornersView)
                cornersView.backgroundColor = selectedBgColor
            }
            cornersView.frame = bounds
            cornersView.roundCorners(cornerRaduis)
            cornersView?.isHidden = false
            self.layer.masksToBounds = false
        }
        else {
            cornersView?.isHidden = true
            self.roundCorners(cornerRaduis)
        }
    }

    /// is selected
    override public var isSelected: Bool {
        didSet {
            self.setNeedsLayout()
        }
    }
}

