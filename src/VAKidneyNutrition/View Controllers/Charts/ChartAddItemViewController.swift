//
//  ChartAddItemViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import HealthKitUI

/**
 * ChartAddItemViewController delegate protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol ChartAddItemViewControllerDelegate {

    /// Add item
    ///
    /// - Parameters:
    ///   - amount: the amount
    ///   - unit: the units
    func chartItemAdd(amount: Double, unit: String)
}

/**
 * Add Chart Item form
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ChartAddItemViewController: FoodIntakeAddMealViewController {

    /// the related lab value
    var labValue: LabValue!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /// Open units picker
    override func openUnitsPicker() {
        self.view.endEditing(true)
        let items = HealthKitUtil.shared.getUnits(forLabValue: self.labValue)
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

        (delegate as? ChartAddItemViewControllerDelegate)?.chartItemAdd(amount: amount, unit: units)
        self.closeAction(self)
    }
}
