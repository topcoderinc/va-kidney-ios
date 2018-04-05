//
//  FoodIntakeFormViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIComponents
import SwiftyJSON

/// possible time for the meal
enum FoodIntakeTime: String {
    case breakfast = "breakfast", lunch = "lunch", dinner = "dinner", snacks = "snacks", casual = "casual"
}

/// option: true - add "drug" into title of the "Add New Meal" form
let OPTION_SHOW_ADD_NEW_MEAL_DRUG_TITLE = true

/**
 * Food Intake form
 *
 * - author: TCCODER
 * - version: 1.3
 *
 * changes:
 * 1.1:
 * - UI changes
 *
 * 1.2:
 * - integration changes
 *
 * 1.2:
 * - bug fixes
 */
class FoodIntakeFormViewController: UIViewController, UITextFieldDelegate, DatePickerViewControllerDelegate, AddAssetButtonViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FoodIntakeAddMealViewControllerDelegate {

    /// the cell size
    let CELL_SIZE: CGFloat = 129.5

    /// outlets
    @IBOutlet weak var dateView: CustomView!
    @IBOutlet weak var timeView: CustomView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!

    @IBOutlet var mealTimeButtons: [UIButton]!
    @IBOutlet weak var mealTimeButtonsView: UIView!
    @IBOutlet weak var mealActiveSelectorView: UIView!
    @IBOutlet weak var mealSelectorLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var mealSelectorWidth: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var addButton: CustomButton!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!

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

    /// the meal items
    private var meals = [FoodItem]()

    /// the table model
    private var table = InfiniteTableViewModel<FoodItem, FoodItemTableViewCell>()

    /// flag: true - has changes in the form, false - else
    private var hasChanges = false
    
    /// the reference to last opened ConfirmDialog
    private var confirmDialog: ConfirmDialog?

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

        date = food?.date ?? Date()
        images = food?.images ?? []
        meals = (food?.items ?? []).map{$0.clone()}
        if food != nil {
            addButton.setTitle(NSLocalizedString("Save Meal/Drug", comment: "Save Meal/Drug").uppercased(), for: .normal)
            if OPTION_SHOW_ADD_NEW_MEAL_DRUG_TITLE {
                self.title = NSLocalizedString("Edit Meal/Drug", comment: "Edit Meal/Drug").uppercased()
            }
            else {
                self.title = NSLocalizedString("Edit Meal", comment: "Edit Meal").uppercased()
            }
        }
        else {
            let title = NSLocalizedString("Add New Meal/Drug", comment: "Add New Meal/Drug").uppercased()
            addButton.setTitle(title, for: .normal)
            if OPTION_SHOW_ADD_NEW_MEAL_DRUG_TITLE {
                self.title = title
            }
        }

        table.tableHeight = tableHeight
        table.extraHeight = 7
        table.configureCell = { indexPath, item, _, cell in
            cell.titleLabel?.text = item.title
            cell.amountLabel?.text = "\(item.amount)"
            cell.unitsLabel?.text = item.units
        }
        table.onSelect = { _, item in
            self.openForm(item)
        }
        table.loadItems = { callback, failure in
            callback(self.meals)
        }
        table.bindData(to: tableView)

        updateUI()
        updateCollection()
        self.view.layoutIfNeeded()
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

    /// Open form
    private func openForm(_ item: FoodItem? = nil, type: FoodItemType = .food) {
        if let vc = create(FoodIntakeAddMealViewController.self), let parent = UIViewController.getCurrentViewController() {
            vc.item = item
            vc.type = item?.type ?? type
            vc.delegate = self
            parent.showViewControllerFromSide(vc, inContainer: parent.view, bounds: parent.view.bounds, side: .bottom, nil)
        }
    }

    /// "Add Meal" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func addMealAction(_ sender: Any) {
        openForm()
    }

    /// "Add Drug" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func addDrugAction(_ sender: Any) {
        openForm(type: .drug)
    }

    /// Back button action
    override func backButtonAction() {
        if self.food != nil && hasChanges {
            confirmDialog = ConfirmDialog(title: "Cancel changes", text: "Are you sure you want to cancel the changes?", action: {
                super.backButtonAction()
            })
        }
        else {
            super.backButtonAction()
        }
    }

    /// Save action
    ///
    /// - Parameter sender: the button
    @IBAction func saveButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.isEnabled = false

        var hasError = false
        if meals.isEmpty {
            showError(errorMessage: "Please add at least one meal/drug")
            hasError = true
        }
        if selectedMealTime == nil {
            showError(errorMessage: NSLocalizedString("Please fill all fields", comment: "Please fill all fields"))
            hasError = true
        }
        if hasError {
            sender.isEnabled = true
            return
        }

        let food = self.food ?? Food(id: "")

        // Check the difference in updated food items
        if self.food != nil {
            var diff = [FoodItem: Double]()
            for item in self.meals {
                if let previousMeal = self.food?.items.filter({$0.id == item.id}).first {
                    let added = item.amount - previousMeal.amount
                    diff[item] = Double(added)
                }
                else {
                    diff[item] = Double(item.amount)
                }
            }
            food.extraAddedItems = diff
        }

        food.items = meals
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

            // Update related data
            FoodUtils.shared.process(food: food)

            sender.isEnabled = true
        }, failure: { error in
            self.createGeneralFailureCallback()(error)
            sender.isEnabled = true
        })
    }

    /// "Change Date" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func changeDateAction(_ sender: Any) {
        self.view.endEditing(true)
        DatePickerViewController.show(title: NSLocalizedString("Select Date", comment: "Select Date"),
                                      selectedDate: date,
                                      datePickerMode: .date, delegate: self, maxDate: Date())
    }

    /// "Change Time" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func changeTimeAction(_ sender: Any) {
        self.view.endEditing(true)
        DatePickerViewController.show(title: NSLocalizedString("Select Time", comment: "Select Time"),
                                      selectedDate: date,
                                      datePickerMode: .time, delegate: self, maxDate: Date())
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

    // MARK: - FoodIntakeAddMealViewControllerDelegate

    /// Add food item
    ///
    /// - Parameter item: the item
    func foodItemAdd(_ item: FoodItem) {
        self.meals.append(item)
        self.table.loadData()
        hasChanges = true
    }

    /// Update food item
    ///
    /// - Parameter item: the item
    func foodItemUpdate(_ item: FoodItem) {
        self.table.loadData()
        hasChanges = true
    }

    /// Delete food item
    ///
    /// - Parameter item: the item
    func foodItemDelete(_ item: FoodItem) {
        if let item = self.meals.index(of: item) {
            self.meals.remove(at: item)
        }
        table.loadData()
        hasChanges = true
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

/**
 * Cell for food items
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodItemTableViewCell: ZeroMarginsCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
}
