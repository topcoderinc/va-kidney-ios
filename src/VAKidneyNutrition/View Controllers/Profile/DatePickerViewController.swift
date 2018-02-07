//
//  DatePickerViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/3/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/// the reference to last date picker
var LastDatePickerViewController: DatePickerViewController?

/**
 * DatePickerViewController delegate protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
@objc protocol DatePickerViewControllerDelegate {

    /**
     Date updated

     - parameter date:   the date
     - parameter picker: the picker
     */
    @objc optional func datePickerDateUpdated(_ date: Date, picker: DatePickerViewController)

    /**
     Date selected

     - parameter date:   the date
     - parameter picker: the picker
     */
    func datePickerDateSelected(_ date: Date, picker: DatePickerViewController)

    /**
     Picker cancelled

     - parameter picker: the picker
     */
    @objc optional func datePickerCancelled(_ picker: DatePickerViewController)
}

/**
 * View controller that contains header and datepicker.
 *
 * - author: TCCODER
 * - version: 1.0
 */
class DatePickerViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var outsideButton: UIButton!

    /// selected item in the picker (value)
    var selectedObject: Date?

    // the mode
    var datePickerMode: UIDatePickerMode!

    // the delegate
    var delegate: DatePickerViewControllerDelegate?

    /// Show the picker
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - selectedDate: the selected date
    ///   - datePickerMode: the date picker mode
    ///   - delegate: the delegate
    ///   - disableOutsideButton: true - will disable outside button, false - else
    /// - Returns: picker's view controller
    @discardableResult
    class func show(title: String,
                    selectedDate: Date? = nil,
                    datePickerMode: UIDatePickerMode,
                    delegate: DatePickerViewControllerDelegate,
                    disableOutsideButton: Bool = false) -> DatePickerViewController? {
        LastDatePickerViewController?.closePicker()
        if let parent = UIViewController.getCurrentViewController() {
            if let vc = parent.create(DatePickerViewController.self, storyboardName: "Profile") {
                LastDatePickerViewController = vc
                vc.title = title
                vc.selectedObject = selectedDate ?? Date()
                vc.datePickerMode = datePickerMode
                vc.delegate = delegate

                let height: CGFloat = 217
                let bounds = disableOutsideButton ? CGRect(x: 0, y: 0, width: parent.view.bounds.width, height: height) : parent.view.bounds
                parent.showViewControllerFromSide(vc,
                                                  inContainer: parent.view,
                                                  bounds: bounds,
                                                  side: .bottom, nil)
                return vc
            }
        }
        return nil
    }

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = self.title
        if !hasControls() {
            height.constant = 0
        }
        picker.datePickerMode = datePickerMode
        if datePickerMode == .dateAndTime {
            picker.minimumDate = Date()
        }
        picker.addTarget(self, action: #selector(valueChanged), for: .valueChanged)

        if let preselectDate = selectedObject {
            picker.date = preselectDate
        }
    }

    /// Check if need to show controls
    ///
    /// - Returns: true - if title is not empty, false - else
    func hasControls() -> Bool {
        return !(self.title ?? "").isEmpty
    }

    /// Callback when selected value changed
    @objc func valueChanged() {
        delegate?.datePickerDateUpdated?(picker.date, picker: self)
    }

    /// "Done" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func doneButtonAction(_ sender: Any) {
        let date = picker.date
        self.delegate?.datePickerDateSelected(date, picker: self)
        self.closePicker()
    }

    /// "Close" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func closeButtonAction(_ sender: Any) {
        self.delegate?.datePickerCancelled?(self)
        self.closePicker()
    }

    /// Close the picker
    ///
    /// - Parameters:
    ///   - animated: the animation flag
    ///   - callback: the completion callback
    func closePicker(animated: Bool = true, _ callback: (()->())? = nil) {
        LastDatePickerViewController = nil
        if animated {
            self.dismissViewControllerToSide(self, side: .bottom, callback)
        }
        else {
            self.removeFromParent()
        }
    }
}
