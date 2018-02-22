//
//  FoodIntakeFormViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIComponents
import SwiftyJSON

/// possible time for the meal
enum FoodIntakeTime: String {
    case breakfast = "breakfast", lunch = "lunch", dinner = "dinner", snacks = "snacks", casual = "casual"
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
class FoodIntakeFormViewController: UIViewController, UITextFieldDelegate,
    PickerViewControllerDelegate, DatePickerViewControllerDelegate, AddAssetButtonViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the cell size
    let CELL_SIZE: CGFloat = 129.5

    @IBOutlet weak var dateView: CustomView!
    @IBOutlet weak var timeView: CustomView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!

    @IBOutlet weak var itemsField: CustomTextField!
    @IBOutlet weak var amountField: CustomTextField!
    @IBOutlet weak var unitsField: CustomTextField!

    @IBOutlet var mealTimeButtons: [UIButton]!
    @IBOutlet weak var mealTimeButtonsView: UIView!
    @IBOutlet weak var mealActiveSelectorView: UIView!
    @IBOutlet weak var mealSelectorLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var mealSelectorWidth: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var mealErrorLabel: UILabel!
    @IBOutlet weak var mealBottomMargin: NSLayoutConstraint! // 33.5 (+15)
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var unitErrorLabel: UILabel!
    @IBOutlet weak var amountBottomMargin: NSLayoutConstraint! // 17.5 (+15)

    /// the food to edit
    var food: Food?

    /// the reference date
    var date = Date()

    // the index of the button
    private var selectedMealTime: Int?

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// the images
    private var images = [Any]()

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        dateView.roundCorners()
        timeView.roundCorners()
        mealTimeButtonsView.makeRound()
        mealActiveSelectorView.makeRound()
        initBackButtonFromChild()
        mealActiveSelectorView.backgroundColor = Colors.darkBlue

        self.view.layoutIfNeeded()
        self.mealTimeAction(self.mealTimeButtons.filter({$0.tag == 0}).first!)

        images = food?.images ?? []
        resetErrors()
        updateUI()
        updateCollection()
    }

    /// Update UI
    private func updateUI() {
        dateLabel.text = DateFormatters.foodForm.string(from: date)
        dayLabel.text = NSLocalizedString("Date", comment: "Date")
        if Date().isSameDay(date: date) {
            dayLabel.text = NSLocalizedString("Today", comment: "Today")
        }
        else if Date().addDays(-1).isSameDay(date: date) {
            dayLabel.text = NSLocalizedString("Yesterday", comment: "Yesterday")
        }
        timeLabel.text = DateFormatters.time.string(from: date).replace(" ", withString: "")
    }

    /// Update collection
    ///
    /// - Parameter reload: true - if need to reload
    private func updateCollection(reload: Bool = true) {
        let height = collectionView.getCollectionHeight(items: images.count + 1, cellHeight: CELL_SIZE)
        UIView.animateWithDefaultSettings {
            self.collectionHeight.constant = height
            self.view.layoutIfNeeded()
        }
        if reload {
            collectionView.reloadData()
        }
    }

    /// Hide error fields
    private func resetErrors() {
        showFieldError(nil, field: amountField,
                       bottomMargin: amountBottomMargin,
                       errorLabel: amountErrorLabel, constant: 17.5)
        showFieldError(nil, field: itemsField,
                       bottomMargin: mealBottomMargin,
                       errorLabel: mealErrorLabel, constant: 33.5)
        showFieldError(nil, field: unitsField,
                       bottomMargin: amountBottomMargin,
                       errorLabel: unitErrorLabel, constant: 17.5)
    }

    /// Save action
    ///
    /// - Parameter sender: the button
    @IBAction func saveButtonAction(_ sender: Any) {
        self.view.endEditing(true)

        resetErrors()

        let meal = (itemsField.text ?? "").trim()
        let amount = Float(amountField.text ?? "")
        let units = (unitsField.text ?? "").trim()
        var hasError = false
        if amount == nil || (amount ?? 0) <= 0 {
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
        if selectedMealTime == nil {
            showError(errorMessage: NSLocalizedString("Please fill all fields", comment: "Please fill all fields"))
            return
        }
        if hasError {
            return
        }

        let food = Food(id: "")
        food.items = meal
        switch selectedMealTime ?? 0 {
        case 0:
            food.time = .breakfast
        case 1:
            food.time = .lunch
        case 2:
            food.time = .dinner
        case 3:
            food.time = .snacks
        case 4:
            food.time = .casual
        default:
            break
        }
        food.date = date
        food.images = images

        api.saveFood(food: food, callback: { (_) in
            self.navigationController?.popViewController(animated: true)
        }, failure: createGeneralFailureCallback())
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

    /// "Change Date" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func changeDateAction(_ sender: Any) {
        self.view.endEditing(true)
        DatePickerViewController.show(title: NSLocalizedString("Select Date", comment: "Select Date"),
                                      selectedDate: date,
                                      datePickerMode: .date, delegate: self)
    }

    /// "Change Time" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func changeTimeAction(_ sender: Any) {
        self.view.endEditing(true)
        DatePickerViewController.show(title: NSLocalizedString("Select Time", comment: "Select Time"),
                                      selectedDate: date,
                                      datePickerMode: .time, delegate: self)
    }

    /// Meal time button action handler
    ///
    /// - parameter sender: the button
    @IBAction func mealTimeAction(_ sender: UIButton) {
        self.view.endEditing(true)
        selectedMealTime = sender.tag
        for button in mealTimeButtons {
            button.isSelected = sender.tag == button.tag
            if button.isSelected {
                updateMealTimeIndicator(button)
            }
        }
    }

    /// Update meal time
    ///
    /// - Parameter button: the button
    private func updateMealTimeIndicator(_ button: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.mealSelectorWidth.constant = button.bounds.width + 10
            self.mealSelectorLeftMargin.constant = button.frame.origin.x - 5
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    /// Delete given image
    ///
    /// - Parameter indexPath: the indexPath
    fileprivate func deleteImage(_ indexPath: IndexPath) {
        let index = indexPath.row
        if index <= images.count && index > 0 {
            images.remove(at: index - 1)
            self.updateCollection()
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

    // MARK: - DatePickerViewControllerDelegate

    /// Update selected date
    ///
    /// - Parameters:
    ///   - date: the date
    ///   - picker: the picker
    func datePickerDateSelected(_ date: Date, picker: DatePickerViewController) {
        self.date = date
        updateUI()
    }

    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate

    /// Get the number of cells
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - section: the section
    /// - Returns: the number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }

    /// Get cell
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    /// - Returns: the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.getCell(indexPath, ofClass: FoodAddIntakeCollectionViewCell.self)
            return cell
        }
        else {
            let cell = collectionView.getCell(indexPath, ofClass: FoodImageCollectionViewCell.self)
            cell.parent = self
            cell.indexPath = indexPath
            cell.configure(images[indexPath.row - 1])
            return cell
        }
    }
    /// the utility used to take image
    private var imageUtil = AddAssetButtonView()
    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            imageUtil.delegate = self
            imageUtil.addAssetButtonTapped(imageUtil)
        }
    }

    /// Get cell size
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - collectionViewLayout: the layout
    ///   - indexPath: the indexPath
    /// - Returns: cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.view.layoutIfNeeded()
        let layout = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        let margins = layout.sectionInset
        let spacing = CGSize(width: layout.minimumInteritemSpacing, height: layout.minimumLineSpacing)

        let n: CGFloat = 2
        let width = (collectionView.bounds.width - margins.left - margins.right - (n - 1) * spacing.width) / n
        return CGSize(width: width, height: CELL_SIZE)
    }

    // MARK: - AddAssetButtonViewDelegate

    /// Update avatar
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - filename: teh filename
    ///   - modalDismissed: true - if the last update
    func addAssetImageChanged(_ image: UIImage, filename: String, modalDismissed: Bool) {
        if modalDismissed {
            self.images.append(image)
            updateCollection()
        }
    }

    /// method required by AddAssetButtonViewDelegate
    func addAssetButtonTapped(_ view: AddAssetButtonView) {
        // nothing to do
    }
}

/**
 * Cell for adding reports in FoodIntakeFormViewController
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes
 */
class FoodImageCollectionViewCell: FoodAddIntakeCollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!

    /// the loaded URL
    private var url: String?

    /// the shown item
    private var item: Any!

    /// the indexPath and parent references
    var indexPath: IndexPath!
    var parent: FoodIntakeFormViewController!

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    func configure(_ item: Any) {
        self.item = item
        loadImage(item, toView: iconView)
    }

    /// "Delete" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func deleteAction(_ sender: Any) {
        parent?.deleteImage(indexPath)
    }

    /// Load image
    ///
    /// - Parameters:
    ///   - image: the image or image URL
    ///   - imageView: the image view
    private func loadImage(_ image: Any, toView imageView: UIImageView) {
        self.url = nil
        if let image = image as? UIImage {
            imageView.image = image
        }
        else if let url = image as? String {
            self.url = url
            UIImage.loadAsync(url, callback: { (image) in
                if self.url == url {
                    imageView.image = image
                }
            })
        }
    }
}
