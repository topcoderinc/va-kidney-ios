//
//  ChartAddItemViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Modified by TCCODER on 4/1/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents
import HealthKitUI

/**
 * ChartAddItemViewController delegate protocol
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - date parameter added
 * 1.2:
 * - multi value types support (blood pressure)
 */
protocol ChartAddItemViewControllerDelegate {

    /// Add item
    ///
    /// - Parameters:
    ///   - amounts: the amounts
    ///   - unit: the units
    ///   - date: the date
    func chartItemAdd(amounts: [Double], unit: String, date: Date)
}

/**
 * Add Chart Item form
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - date field added
 *
 * 1.2:
 * - pressure entering support
 */
class ChartAddItemViewController: FoodIntakeAddMealViewController, DatePickerViewControllerDelegate {

    /// outlets
    @IBOutlet weak var dateField: CustomTextField!
    @IBOutlet weak var amountTitleLabel: UILabel!

    /// the related value types
    var quantityTypes = [QuantityType]()

    /// the custom titles
    var customChartTitles = [String]()

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
        if !customChartTitles.isEmpty {
            amountTitleLabel.text = customChartTitles.joined(separator: "/")
        }
        dateField.text = DateFormatters.foodForm.string(from: selectedDate)
    }

    /// Open units picker
    override func openUnitsPicker() {
        self.view.endEditing(true)
        if let quantityType = quantityTypes.first {
            let items = HealthKitUtil.shared.getUnits(forType: quantityType)
            PickerViewController.show(title: NSLocalizedString("Select Units", comment: "Select Units"), data: items.map{PickerValue($0)}, delegate: self)
        }
    }

    /// Save action
    ///
    /// - Parameter sender: the button
    override func saveButtonAction(_ sender: Any) {
        self.view.endEditing(true)

        resetErrors()

        let amounts = getAmounts()
        let units = (unitsField.text ?? "").trim()
        var hasError = false
        if amounts.isEmpty {
            let error = self.customChartTitles.isEmpty ? NSLocalizedString("Should be a positive number", comment: "Should be a positive number") : NSLocalizedString("Should be a positive numbers", comment: "Should be a positive numbers")
            showFieldError(error,
                           field: amountField,
                           bottomMargin: amountBottomMargin,
                           errorLabel: amountErrorLabel, constant: 21.5)
            hasError = true
        }
        if units.isEmpty {
            showFieldError(NSLocalizedString("Select units", comment: "Select units"),
                           field: unitsField,
                           bottomMargin: amountBottomMargin,
                           errorLabel: unitErrorLabel, constant: 21.5)
            hasError = true
        }

        if hasError {
            return
        }

        (delegate as? ChartAddItemViewControllerDelegate)?.chartItemAdd(amounts: amounts, unit: units, date: selectedDate)
        self.closeAction(self)
    }

    /// Get entered values
    ///
    /// - Returns: the values
    private func getAmounts() -> [Double] {
        var values = [Double]()
        let a = (amountField.text ?? "").split("/")
        for item in a {
            for string in item.split(",") {
                if let value = Double(string), value > 0 {
                    values.append(value)
                }
                else {
                    return []
                }
            }
        }
        return values
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

    /// Disable non decimal characters in amount field
    ///
    /// - Parameters:
    ///   - textField: the textField
    ///   - range: the range
    ///   - string: the string
    /// - Returns: true - if need to update the text, false - if updated manually
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountField {
            let strTextField: NSString = NSString(string: textField.text!)
            let newString = strTextField.replacingCharacters(in: range as NSRange, with: string)
            return (newString ≈ "^\\d*\\.?\\d*$")
                || (newString ≈ "^\\d*/$")
            || (newString ≈ "^\\d*\\.?\\d*/$")
            || (newString ≈ "^\\d*\\.?\\d*/\\d*\\.?\\d*$")
        }
        return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
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
