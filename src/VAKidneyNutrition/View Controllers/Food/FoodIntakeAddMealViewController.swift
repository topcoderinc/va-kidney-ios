//
//  FoodIntakeAddMealViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/23/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents
import SwiftyJSON
import HealthKit

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
 * Unit picker value
 *
 * - author: TCCODER
 * - version: 1.0
 */
class UnitPickerValue: PickerValue {

    /// Get human readable string
    override var description: String {
        return string.humanReadableUnit()
    }
}

/**
 * Food Intake form
 *
 * - author: TCCODER
 * - version: 1.4
 *
 * changes:
 * 1.1:
 * - UI changes
 *
 * 1.2:
 * - integration changes
 *
 * 1.3:
 * - bug fixes
 *
 * 1.4:
 * - search inplace feature
 */
class FoodIntakeAddMealViewController: UIViewController, UITextFieldDelegate, PickerViewControllerDelegate {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var itemsField: CustomTextField?
    @IBOutlet weak var amountField: CustomTextField!
    @IBOutlet weak var unitsField: CustomTextField!

    @IBOutlet weak var mealErrorLabel: UILabel?
    @IBOutlet weak var mealBottomMargin: NSLayoutConstraint? // 33.5 (+15)
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var unitErrorLabel: UILabel!
    @IBOutlet weak var amountBottomMargin: NSLayoutConstraint! // 17.5 (+15)
    @IBOutlet weak var buttonLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var saveButton: CustomButton!
    @IBOutlet weak var deleteButton: CustomButton!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var searchRresultsView: UIView?
    @IBOutlet weak var searchResultsHeight: NSLayoutConstraint?

    /// the extra margin to add
    internal var extraAmountBottomMargin: CGFloat {
        return 15
    }

    // the item to edit
    var item: FoodItem?
    /// the type of the item
    var type: FoodItemType = .food
    /// the selected units
    var selectedUnits: String?

    /// the delegate
    var delegate: NSObject?

    /// the table model
    private var table = InfiniteTableViewModel<FoodItem, FoodIntakeSearchResultsCell>()
    /// the references to API
    private let foodDetailsApi: FoodDetailsServiceApi = CachingNDBServiceApi.sharedWrapper
    /// the results of the search
    private var searchResults = [FoodItem]()
    /// the last search results
    private var lastSearchString: String?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        resetErrors()
        mainView.roundCorners()
        mainView.addShadow()
        updateUI()
        if let tableView = tableView {
            table.tableHeight = searchResultsHeight
            table.configureCell = { indexPath, item, _, cell in
                cell.configure(item)
            }
            table.onSelect = { indexPath, item in
                self.itemsField?.text = item.title
                self.showSearchResults(false)
            }
            table.loadItems = { callback, failure in
                callback(self.searchResults)
            }
            table.bindData(to: tableView)
        }
        searchRresultsView?.addShadow()
        searchRresultsView?.roundCorners()
    }

    /// Show/hide search results
    ///
    /// - Parameters:
    ///   - show: true - show, false - hide
    ///   - items: the results to show
    private func showSearchResults(_ show: Bool, items: [FoodItem]? = nil) {
        if let items = items, show, !items.isEmpty {
            self.searchResults = items
            self.table.loadData()
            searchRresultsView?.isHidden = false
        }
        else {
            searchRresultsView?.isHidden = true
        }
        if !show {
            lastSearchString = nil
        }
    }

    /// Focus on the first field
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        itemsField?.becomeFirstResponder()
    }

    /// Update UI
    private func updateUI() {
        if let item = item {
            self.itemsField?.text = item.title
            self.amountField.text = item.amount.toItemValueString()
            selectedUnits = item.units
            self.unitsField.text = HKUnit(from: item.units).humanReadable()
            saveButton.setTitle((type == .food ? "Edit Meal" : "Edit Drug").uppercased(), for: .normal)
            deleteButton.setTitle((type == .food ? "Delete Meal" : "Delete Drug").uppercased(), for: .normal)
        }
        else if type == .drug {
            saveButton.setTitle("Add Drug".uppercased(), for: .normal)
        }
        titleLabel?.text = (type == .food ? "Meal or Liquid Item" : "Drug Name")
        self.view.layoutIfNeeded()
        deleteButton.isHidden = item == nil
        let space: CGFloat = 13
        buttonLeftMargin.constant = item == nil ? 0 : (deleteButton.superview!.bounds.width - space)/2 + space
    }

    /// Hide error fields
    internal func resetErrors() {
        showFieldError(nil, field: amountField,
                       bottomMargin: amountBottomMargin,
                       errorLabel: amountErrorLabel, constant: 33.5)
        if let mealBottomMargin = mealBottomMargin {
            showFieldError(nil, field: itemsField!,
                           bottomMargin: mealBottomMargin,
                           errorLabel: mealErrorLabel!, constant: 33.5)
        }
        showFieldError(nil, field: unitsField,
                       bottomMargin: amountBottomMargin,
                       errorLabel: unitErrorLabel!, constant: 17.5)
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
            (delegate as? FoodIntakeAddMealViewControllerDelegate)?.foodItemDelete(item)
        }
        closeAction(self)
    }

    /// Save action
    ///
    /// - Parameter sender: the button
    @IBAction func saveButtonAction(_ sender: Any) {
        self.view.endEditing(true)

        resetErrors()

        let meal = (itemsField?.text ?? "").trim()
        let amount = Float(amountField.text ?? "") ?? 0
        let units = (selectedUnits ?? "").trim()
        var hasError = false
        if amount <= 0 {
            showFieldError(NSLocalizedString("Should be a positive number", comment: "Should be a positive number"),
                           field: amountField,
                           bottomMargin: amountBottomMargin,
                           errorLabel: amountErrorLabel, constant: 17.5)
            hasError = true
        }

        if let mealBottomMargin = mealBottomMargin, meal.isEmpty {
            showFieldError(NSLocalizedString("Should be non-empty string", comment: "Should be non-empty string"),
                           field: itemsField!,
                           bottomMargin: mealBottomMargin,
                           errorLabel: mealErrorLabel!, constant: 33.5)
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

        let item = self.item ?? FoodItem(id: UUID().uuidString)
        item.title = meal
        item.amount = amount
        item.units = units
        item.type = type

        if self.item == nil {
            (delegate as? FoodIntakeAddMealViewControllerDelegate)?.foodItemAdd(item)
        }
        else {
            (delegate as? FoodIntakeAddMealViewControllerDelegate)?.foodItemUpdate(item)
        }
        self.closeAction(self)
    }

    /// Show field error
    ///
    /// - Parameter error: the error
    internal func showFieldError(_ error: String?, field: CustomTextField, bottomMargin: NSLayoutConstraint, errorLabel: UILabel, constant: CGFloat) {
        field.borderWidth = error == nil ? 0 : 1
        errorLabel.isHidden = error == nil
        let extraMargin = bottomMargin == amountBottomMargin ? extraAmountBottomMargin : 0
        bottomMargin.constant = (error == nil ? constant : (constant + 15)) + extraMargin
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
        self.showSearchResults(false)
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

    /// Disable non decimal characters in amount field
    ///
    /// - Parameters:
    ///   - textField: the textField
    ///   - range: the range
    ///   - string: the string
    /// - Returns: true - if need to update the text, false - if updated manually
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strTextField: NSString = NSString(string: textField.text!)

        let newString = strTextField.replacingCharacters(in: range as NSRange, with: string)
        if textField == itemsField {
            trySearchFood(newString)
        }
        else if textField == amountField {
            return (newString ≈ "^\\d*\\.?\\d*$") || (newString ≈ "^\\d*/$")
        }
        return true
    }

    /// Try to search food
    ///
    /// - Parameter string: the string
    private func trySearchFood(_ string: String) {
        lastSearchString = string
        delay(0.5) {
            if string == self.lastSearchString, !string.isEmpty {
                print("Searching \"\(string)\")...")
                self.foodDetailsApi.searchFoodItems(string: string, callback: { (list) in
                    print("...found \(list.count) items")
                    self.showSearchResults(true, items: list)
                }, failure: self.createGeneralFailureCallback())
            }
        }
    }

    /// Hide search results
    ///
    /// - Parameter textField: the textField
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.showSearchResults(false)
    }

    /// Open units picker
    internal func openUnitsPicker() {
        self.view.endEditing(true)
        if type == .food {
            let items = HealthKitUtil.shared.getFoodUnits().map({$0.unitString}).map{UnitPickerValue($0)}
            let selected = items.filter({$0.string == self.selectedUnits}).first
            PickerViewController.show(title: NSLocalizedString("Select Units", comment: "Select Units"), selected: selected, data: items, delegate: self)
        }
        else {
            let items = HealthKitUtil.shared.getUnits(forType: QuantityType.fromId("")).map{UnitPickerValue($0)} // default units
            let selected = items.filter({$0.string == self.selectedUnits}).first
            PickerViewController.show(title: NSLocalizedString("Select Units", comment: "Select Units"), selected: selected, data: items, delegate: self)
        }
    }

    // MARK: - PickerViewControllerDelegate

    /// Update units field
    ///
    /// - Parameters:
    ///   - value: the value
    ///   - picker: the picker
    func pickerValueUpdated(_ value: PickerValue, picker: PickerViewController) {
        selectedUnits = value.string
        unitsField.text = value.description
    }
}

/**
 * Cell for search results
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodIntakeSearchResultsCell: UITableViewCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!

    /// Update UI
    ///
    /// - Parameter item: the item
    func configure(_ item: FoodItem) {
        titleLabel.text = item.title
    }
}
