//
//  FoodIntakeAddMealViewController.swift
//  VAKidneyNutrition
//
//  Created by Volkov Alexander on 2/23/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents
import SwiftyJSON

/**
 * FoodIntakeAddMealViewController delegate protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol FoodIntakeAddMealViewControllerDelegate {

    /// Add food item
    ///
    /// - Parameter item: the item
    func foodItemAdd(_ item: FoodItem)

    /// Update food item
    ///
    /// - Parameter item: the item
    func foodItemUpdate(_ item: FoodItem)

    /// Delete food item
    ///
    /// - Parameter item: the item
    func foodItemDelete(_ item: FoodItem)
}

/**
 * Food Intake form
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes
 */
class FoodIntakeAddMealViewController: UIViewController, UITextFieldDelegate, PickerViewControllerDelegate {

    /// outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var itemsField: CustomTextField!
    @IBOutlet weak var amountField: CustomTextField!
    @IBOutlet weak var unitsField: CustomTextField!

    @IBOutlet weak var mealErrorLabel: UILabel!
    @IBOutlet weak var mealBottomMargin: NSLayoutConstraint! // 33.5 (+15)
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var unitErrorLabel: UILabel!
    @IBOutlet weak var amountBottomMargin: NSLayoutConstraint! // 17.5 (+15)
    @IBOutlet weak var buttonLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var saveButton: CustomButton!
    @IBOutlet weak var deleteButton: CustomButton!

    // the item to edit
    var item: FoodItem?

    /// the delegate
    var delegate: FoodIntakeAddMealViewControllerDelegate?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        resetErrors()
        mainView.roundCorners()
        mainView.addShadow()
        updateUI()
    }

    /// Focus on the first field
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        itemsField.becomeFirstResponder()
    }

    /// Update UI
    private func updateUI() {
        if let item = item {
            self.itemsField.text = item.title
            self.amountField.text = "\(item.amount)"
            self.unitsField.text = item.units
            saveButton.setTitle("Edit Meal".uppercased(), for: .normal)
        }
        self.view.layoutIfNeeded()
        deleteButton.isHidden = item == nil
        let space: CGFloat = 13
        buttonLeftMargin.constant = item == nil ? 0 : (deleteButton.superview!.bounds.width - space)/2 + space
    }

    /// Hide error fields
    private func resetErrors() {
        showFieldError(nil, field: amountField,
                       bottomMargin: amountBottomMargin,
                       errorLabel: amountErrorLabel, constant: 33.5)
        showFieldError(nil, field: itemsField,
                       bottomMargin: mealBottomMargin,
                       errorLabel: mealErrorLabel, constant: 33.5)
        showFieldError(nil, field: unitsField,
                       bottomMargin: amountBottomMargin,
                       errorLabel: unitErrorLabel, constant: 17.5)
    }

    /// "Close" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func closeAction(_ sender: Any) {
        self.view.endEditing(true)
        self.dismissViewControllerToSide(self, side: .bottom, nil)
    }

    /// "Delete" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func deleteAction(_ sender: Any) {
        if let item = item {
            delegate?.foodItemDelete(item)
        }
        closeAction(self)
    }

    /// Save action
    ///
    /// - Parameter sender: the button
    @IBAction func saveButtonAction(_ sender: Any) {
        self.view.endEditing(true)

        resetErrors()

        let meal = (itemsField.text ?? "").trim()
        let amount = Float(amountField.text ?? "") ?? 0
        let units = (unitsField.text ?? "").trim()
        var hasError = false
        if amount <= 0 {
            showFieldError(NSLocalizedString("Should be a positive number", comment: "Should be a positive number"),
                           field: amountField,
                           bottomMargin: amountBottomMargin,
                           errorLabel: amountErrorLabel, constant: 17.5)
            hasError = true
        }

        if meal.isEmpty {
            showFieldError(NSLocalizedString("Should be non-empty string", comment: "Should be non-empty string"),
                           field: itemsField,
                           bottomMargin: mealBottomMargin,
                           errorLabel: mealErrorLabel, constant: 33.5)
            hasError = true
        }
        if units.isEmpty {
            showFieldError(NSLocalizedString("Select units", comment: "Select units"),
                           field: unitsField,
                           bottomMargin: amountBottomMargin,
                           errorLabel: unitErrorLabel, constant: 17.5)
            hasError = true
        }

        if hasError {
            return
        }

        let item = self.item ?? FoodItem(id: "")
        item.title = meal
        item.amount = amount
        item.units = units

        if self.item == nil {
            delegate?.foodItemAdd(item)
        }
        else {
            delegate?.foodItemUpdate(item)
        }
        self.closeAction(self)
    }

    /// Show field error
    ///
    /// - Parameter error: the error
    private func showFieldError(_ error: String?, field: CustomTextField, bottomMargin: NSLayoutConstraint, errorLabel: UILabel, constant: CGFloat) {
        field.borderWidth = error == nil ? 0 : 1
        errorLabel.isHidden = error == nil
        bottomMargin.constant = error == nil ? constant : (constant + 15)
        if let error = error {
            errorLabel.text = "*\(error)"
        }
    }

    /// Dismiss keyboard
    ///
    /// - Parameters:
    ///   - touches: the touches
    ///   - event: the event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    // MARK: - UITextFieldDelegate

    /// Switch to next field
    ///
    /// - Parameter textField: the text field
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == itemsField {
            amountField.becomeFirstResponder()
        }
        else if textField == amountField {
            amountField.resignFirstResponder()
            openUnitsPicker()
        }
        return true
    }

    /// Open picker from units field
    ///
    /// - Parameter textField: the textField
    /// - Returns: false - if units field, true - else
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == unitsField {
            openUnitsPicker()
            return false
        }
        return true
    }

    /// Open units picker
    private func openUnitsPicker() {
        self.view.endEditing(true)
        if let json = JSON.resource(named: "units") {
            let items = json.arrayValue.map{$0.stringValue}
            PickerViewController.show(title: NSLocalizedString("Select Units", comment: "Select Units"), data: items.map{PickerValue($0)}, delegate: self)
        }
    }

    // MARK: - PickerViewControllerDelegate

    /// Update units field
    ///
    /// - Parameters:
    ///   - value: the value
    ///   - picker: the picker
    func pickerValueUpdated(_ value: PickerValue, picker: PickerViewController) {
        unitsField.text = value.description
    }
}
