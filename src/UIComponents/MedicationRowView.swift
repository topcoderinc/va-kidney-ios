//
//  MedicationRowView.swift
//  UIComponents
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * View for medication row in the schedule table
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable public class MedicationRowView: CustomView {

    /// the fields with data to show
    @IBInspectable public var title: String = "Medication Name" { didSet { self.setNeedsLayout() } }
    @IBInspectable public var units: Int = 2 { didSet { self.setNeedsLayout() } }
    @IBInspectable public var isSelected: Bool = false { didSet { self.setNeedsLayout() } }

    // added subviews
    private var titleLabel: UILabel!
    private var unitsLabel: UILabel!
    private var checkboxButton: UIButton!

    /// the subviews
    public override func layoutSubviews() {
        super.layoutSubviews()
        if titleLabel == nil {
            titleLabel = UILabel(frame: self.bounds)
            titleLabel.numberOfLines = 2
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            addSubview(titleLabel)
        }
        if unitsLabel == nil {
            unitsLabel = UILabel(frame: self.bounds)
            unitsLabel.font = UIFont.systemFont(ofSize: 12)
            addSubview(unitsLabel)
        }
        if checkboxButton == nil {
            checkboxButton = UIButton(frame: self.bounds)
            checkboxButton.setImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
            checkboxButton.setImage(#imageLiteral(resourceName: "checkboxSelected"), for: .selected)
            checkboxButton.addTarget(self, action: #selector(checkboxAction), for: .touchUpInside)
            addOnRightWithConstraints(view: checkboxButton)
        }

        let padding: CGFloat = 10
        let x = 2 * self.bounds.width / 3
        titleLabel.frame = CGRect(x: padding, y: 0, width: x - padding, height: self.bounds.height)
        unitsLabel.frame = CGRect(x: x + padding, y: 0, width: self.bounds.width / 3, height: self.bounds.height)
        checkboxButton.frame = CGRect(x: self.bounds.width - self.bounds.height, y: 0, width: self.bounds.height, height: self.bounds.height)

        titleLabel.text = title
        unitsLabel.text = "\(units) \(units == 1 ? "unit" : "units")"
        checkboxButton.isSelected = isSelected
    }

    /// Checkbox action
    ///
    /// - Parameter sender: the sender
    @objc func checkboxAction(_ sender: UIButton) {
        isSelected = !isSelected
        sender.isSelected = isSelected
    }
}


/**
 * Shortcut methods for UIView
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UIView {

    /// Add view on the right
    ///
    /// - Parameter view: the view to add
    func addOnRightWithConstraints(view: UIView) {
        let containerView = self
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        containerView.addConstraint(NSLayoutConstraint(item: view,
                                                       attribute: .top,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .top,
                                                       multiplier: 1.0,
                                                       constant: view.frame.origin.y))
        containerView.addConstraint(NSLayoutConstraint(item: view,
                                                       attribute: .bottom,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .bottom,
                                                       multiplier: 1.0,
                                                       constant: -1 * (containerView.bounds.height - view.frame.origin.y - view.frame.height)))
        view.addConstraint(NSLayoutConstraint(item: view,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: view,
                                                       attribute: .trailing,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .trailing,
                                                       multiplier: 1.0,
                                                       constant: -1 * (containerView.bounds.width - view.frame.origin.x - view.frame.width)))

    }
}


