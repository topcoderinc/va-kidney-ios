//
//  ChartAddItemViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents
import HealthKitUI

/**
 * ChartAddItemViewController delegate protocol
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - date parameter added
 */
protocol ChartAddItemViewControllerDelegate {

    /// Add item
    ///
    /// - Parameters:
    ///   - amount: the amount
    ///   - unit: the units
    ///   - date: the date
    func chartItemAdd(amount: Double, unit: String, date: Date)
}

/**
 * Add Chart Item form
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - date field added
 */
class ChartAddItemViewController: FoodIntakeAddMealViewController, DatePickerViewControllerDelegate {

    /// outlets
    @IBOutlet weak var dateField: CustomTextField!

    /// the related value type
    var quantityType: QuantityType!

    /// the selected date
    var selectedDate = Date()

    /// the extra margin to add
    override internal var extraAmountBottomMargin: CGFloat {
        return CGFloat(17)
    }

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    /// Update UI
    func updateUI() {
        dateField.text = DateFormatters.foodForm.string(from: selectedDate)
    }

    /// Open units picker
    override func openUnitsPicker() {
        self.view.endEditing(true)
        let items = HealthKitUtil.shared.getUnits(forType: self.quantityType)
        PickerViewController.show(title: NSLocalizedString("Select Units", comment: "Select Units"), data: items.map{PickerValue($0)}, delegate: self)
    }

    /// Save action
    ///
    /// - Parameter sender: the button
    override func saveButtonAction(_ sender: Any) {
        self.view.endEditing(true)

        resetErrors()

        let amount = Double(amountField.text ?? "") ?? 0
        let units = (unitsField.text ?? "").trim()
        var hasError = false
        if amount <= 0 {
            showFieldError(NSLocalizedString("Should be a positive number", comment: "Should be a positive number"),
                           field: amountField,
                           bottomMargin: amountBottomMargin,
                           errorLabel: amountErrorLabel, constant: 17.5)
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

        (delegate as? ChartAddItemViewControllerDelegate)?.chartItemAdd(amount: amount, unit: units, date: selectedDate)
        self.closeAction(self)
    }

    /// Open picker from date field
    ///
    /// - Parameter textField: the textField
    /// - Returns: false - if units field, true - else
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dateField {
            openDatePicker()
            return false
        }
        return super.textFieldShouldBeginEditing(textField)
    }

    /// Open date picker
    internal func openDatePicker() {
        DatePickerViewController.show(title: NSLocalizedString("Select Date", comment: "Select Date"),
                                      selectedDate: selectedDate,
                                      datePickerMode: .date, delegate: self, maxDate: Date())
    }

    // MARK: - DatePickerViewControllerDelegate

    /// Update selected date
    ///
    /// - Parameters:
    ///   - date: the date
    ///   - picker: the picker
    func datePickerDateSelected(_ date: Date, picker: DatePickerViewController) {
        self.selectedDate = date
        updateUI()
    }
}
