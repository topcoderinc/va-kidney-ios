//
//  PickerViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/// the reference to last picker
var LastPickerViewController: PickerViewController?

/**
 * PickerViewController delegate protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
@objc protocol PickerViewControllerDelegate {

    /**
     Date updated

     - parameter value:   the value
     - parameter picker: the picker
     */
    @objc func pickerValueUpdated(_ value: PickerValue, picker: PickerViewController)

    /**
     Picker cancelled

     - parameter picker: the picker
     */
    @objc optional func pickerCancelled(_ picker: PickerViewController)
}

class PickerValue: NSObject {

    let string: String
    init(_ string: String?) {
        self.string = string ?? ""
    }

    override var description: String {
        return string
    }

    override var hashValue: Int {
        return string.hashValue
    }
}

/**
 Equatable protocol implementation

 - parameter lhs: the left object
 - parameter rhs: the right object

 - returns: true - if objects are equal, false - else
 */
func ==<T: PickerValue>(lhs: T, rhs: T) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

/**
 * Picker view controller
 *
 * - author: TCCODER
 * - version: 1.0
 */
class PickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    /// outlets
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    // the delegate
    private var delegate: PickerViewControllerDelegate?

    /// the data to show
    private var data = [PickerValue]()
    private var selected: PickerValue? = nil

    /**
     Show the picker

     - parameter title:          the title
     - parameter selectedDate:   the selected date
     - parameter datePickerMode: the date picker mode
     - parameter delegate:       the delegate
     */
    @discardableResult
    class func show(title: String,
                    selected: PickerValue? = nil,
                    data: [PickerValue],
                    delegate: PickerViewControllerDelegate) -> PickerViewController? {
        LastPickerViewController?.closePicker()
        if let parent = UIViewController.getCurrentViewController() {
            if let vc = parent.create(PickerViewController.self, storyboardName: "Profile") {
                LastPickerViewController = vc
                vc.title = title
                vc.selected = selected
                vc.data = data
                vc.delegate = delegate

                let bounds = CGRect(x: 0, y: 0, width: parent.view.bounds.width, height: parent.view.bounds.height)
                parent.showViewControllerFromSide(vc,
                                                  inContainer: parent.view,
                                                  bounds: bounds,
                                                  side: .bottom, nil)
                return vc
            }
        }
        return nil
    }

    /**
     Setup UI
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        self.view.backgroundColor = UIColor.clear
        if let selected = selected?.description, let index = data.map({$0.description}).index(of: selected) {
            picker.selectRow(index, inComponent: 0, animated: false)
        }
    }

    /**
     Close the picker
     */
    func closePicker(animated: Bool = true, _ callback: (()->())? = nil) {
        LastPickerViewController = nil
        if animated {
            self.dismissViewControllerToSide(self, side: .bottom, callback)
        }
        else {
            self.removeFromParent()
        }
    }

    // MARK: - UIPickerViewDataSource

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row].description
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected = data[row]
    }

    /// "Done" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func doneButtonAction(_ sender: Any) {
        let index = picker.selectedRow(inComponent: 0)
        if index < data.count {
            let value = data[index]
            self.delegate?.pickerValueUpdated(value, picker: self)
        }
        self.closePicker()
    }

    /// "Close" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func closeButtonAction(_ sender: Any) {
        self.delegate?.pickerCancelled?(self)
        self.closePicker()
    }
}
