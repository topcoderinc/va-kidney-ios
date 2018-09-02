//
//  FoodIntakeViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/// option: true - will filter food by current date by default and will disable date reset, false - will show all food and will enable date reset
let OPTION_FOOD_FILTER_CURRENT_DATE_BY_DEFAULT = false

/**
 * Model for FoodIntakeTime picker value
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodIntakeTimePickerValue: PickerValue {

    /// the value
    let type: FoodIntakeTime

    /// Initializer
    init(_ type: FoodIntakeTime) {
        self.type = type
        super.init(type.rawValue.capitalized)
    }

    /// the description for UI
    override var description: String {
        return type.rawValue.capitalized
    }

    /// the hash value
    override var hashValue: Int {
        return type.hashValue
    }
}

/**
 Equatable protocol implementation

 - parameter lhs: the left object
 - parameter rhs: the right object

 - returns: true - if objects are equal, false - else
 */
func ==<T: FoodIntakeTimePickerValue>(lhs: T, rhs: T) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

/**
 * The date filter option
 *
 * - author: TCCODER
 * - version: 1.0
 */
class DateFilterOption: FilterGroupPickerValue {

    /// the description for UI
    override var description: String {
        if let value = value as? Date {
            return NSLocalizedString("Filter by date: ", comment: "Filter by ") + DateFormatters.profileDate.string(from: value)
        }
        else {
            return string
        }
    }
}

/**
 * The food time filter option
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodIntakeTimeOption: FilterGroupPickerValue {

    /// the description for UI
    override var description: String {
        if let list = value as? [FoodIntakeTimePickerValue], !list.isEmpty {
            return NSLocalizedString("Filter by type: ", comment: "Filter by type: ") + list.map({$0.type.getTitle()}).joined(separator: ", ")
        }
        else {
            return string
        }
    }
}

/**
 * Food Intake screen
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - UI changes
 *
 * 1.2:
 * - integration changes
 *
 * 1.3:
 * - filter feature added
 */
class FoodIntakeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CheckboxPickerViewControllerDelegate, DatePickerViewControllerDelegate {

    /// the cell size
    let CELL_SIZE: CGSize = CGSize(width: 170, height: 162.5)

    /// outlets
    @IBOutlet weak var collectionView: UICollectionView!

    /// all items
    private var allItems = [Food]()
    /// the items to show
    private var items = [Food]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// the last opened filter group
    private var lastOpenedFilterGroup: FilterGroupPickerValue?

    /// current filters
    private var selectedDate: Date?
    private var selectedTypes = [FoodIntakeTime]()

    /// the callback to invoke after filter option is changed
    private var lastFilterChangeCallback: (()->())?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        let item1 = UIBarButtonItem(customView: createBarButton(#imageLiteral(resourceName: "goalsIcon"), selector: #selector(openGoals)))
        let item2 = UIBarButtonItem(customView: createBarButton(#imageLiteral(resourceName: "iconFilter"), selector: #selector(openFilter)))
        self.navigationItem.rightBarButtonItems = [item2, item1]
        if OPTION_FOOD_FILTER_CURRENT_DATE_BY_DEFAULT {
            self.selectedDate = Date()
        }
    }

    /// Load data
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    /// Load data
    private func loadData() {
        let loadingView = showLoadingView()
        api.getFood(date: self.selectedDate, callback: { (items) in
            loadingView?.terminate()
            self.allItems = items
            self.applyFilter()
            self.collectionView.reloadData()
        }, failure: createGeneralFailureCallback(loadingView))
    }

    /// Apply filter
    private func applyFilter() {
        self.items = self.allItems.filter({ item in
            if let date = self.selectedDate, !item.date.isSameDay(date: date) {
                return false
            }
            if !self.selectedTypes.isEmpty, !self.selectedTypes.contains(item.time) {
                return false
            }
            return true
        })
        self.collectionView.reloadData()
    }

    // MARK: - Filter

    /// Open filter
    @objc func openFilter() {
        let item1 = DateFilterOption(NSLocalizedString("Select Date", comment: "Date"))
        item1.value = selectedDate
        item1.action = { callback in
            self.lastFilterChangeCallback = callback
            self.lastOpenedFilterGroup = item1
            let cancelButtonTitle = !OPTION_FOOD_FILTER_CURRENT_DATE_BY_DEFAULT ? NSLocalizedString("Reset", comment: "Reset") : NSLocalizedString("Cancel", comment: "Cancel")
            DatePickerViewController.show(title: item1.string, selectedDate: item1.value as? Date, datePickerMode: .date, delegate: self, maxDate: Date(), cancelButtonTitle: cancelButtonTitle)
        }
        let item2 = FoodIntakeTimeOption(NSLocalizedString("Select Type", comment: "Select Type"))
        let foodTimeItems = FoodIntakeTime.all.map({FoodIntakeTimePickerValue($0)})
        item2.value = foodTimeItems.filter({self.selectedTypes.contains($0.type)})
        item2.action = { callback in
            self.lastFilterChangeCallback = callback
            self.lastOpenedFilterGroup = item2
            let selected = item2.value as? [FoodIntakeTimePickerValue] ?? []
            CheckboxPickerViewController.show(title: item2.string, selected: selected, data: foodTimeItems, delegate: self)
        }
        CheckboxPickerViewController.showFilter(title: NSLocalizedString("Filter", comment: "Filter"), data: [item1, item2], delegate: self)
    }

    // MARK: - CheckboxPickerViewControllerDelegate

    /// Update value in filter group
    ///
    /// - Parameters:
    ///   - values: the values
    ///   - picker: the picker
    func checkboxValueUpdated(_ values: [PickerValue], picker: CheckboxPickerViewController) {
        if let group = self.lastOpenedFilterGroup {
            self.lastOpenedFilterGroup = nil
            group.value = values
            lastFilterChangeCallback?()
            lastFilterChangeCallback = nil
        }
        else {
            // reset by default
            self.selectedDate = nil
            self.selectedTypes = []

            for item in values {
                if let date = item.value as? Date {
                    self.selectedDate = date
                }
                else if let typeValues = item.value as? [FoodIntakeTimePickerValue] {
                    self.selectedTypes = typeValues.map({$0.type})
                }
            }
            loadData()
        }
    }

    // MARK: - DatePickerViewControllerDelegate

    /// Update date filter
    ///
    /// - Parameters:
    ///   - date: the date
    ///   - picker: the picker
    func datePickerDateSelected(_ date: Date, picker: DatePickerViewController) {
        self.lastOpenedFilterGroup?.value = date
        self.lastOpenedFilterGroup = nil
        self.lastFilterChangeCallback?()
        lastFilterChangeCallback = nil
    }

    /// Reset date filter
    ///
    /// - Parameter picker: the picker
    func datePickerCancelled(_ picker: DatePickerViewController) {
        if !OPTION_FOOD_FILTER_CURRENT_DATE_BY_DEFAULT {
            self.lastOpenedFilterGroup?.value = nil
        }
        self.lastOpenedFilterGroup = nil
        self.lastFilterChangeCallback?()
        lastFilterChangeCallback = nil
    }

    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate

    /// Get the number of cells
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - section: the section
    /// - Returns: the number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + 1
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
            let cell = collectionView.getCell(indexPath, ofClass: FoodIntakeCollectionViewCell.self)
            cell.configure(items[indexPath.row - 1])
            return cell
        }
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = create(FoodIntakeFormViewController.self) {
            if indexPath.row != 0 {
                vc.food = items[indexPath.row - 1]
            }
            navigationController?.pushViewController(vc, animated: true)
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
        return CGSize(width: width, height: CELL_SIZE.height)
    }
}

/**
 * Cell for adding reports in FoodIntakeViewController
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - iPhone 5 changes
 */
class FoodAddIntakeCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var buttonTitle: UILabel!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.masksToBounds = false
        self.layer.masksToBounds = false
        mainView.roundCorners()
        shadowView.addShadow()
        if isIPhone5() {
//            buttonTitle.text = NSLocalizedString("Add Meal/Drug", comment: "Add Meal/Drug")
        }
    }
}

/**
 * Cell for reports in FoodIntakeViewController
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes
 */
class FoodIntakeCollectionViewCell: FoodAddIntakeCollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet weak var imagesContainer: UIView!

    /// the related item
    private var item: Food!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.roundCorners()
        for view in imageViews {
            view.roundCorners()
        }
    }

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    func configure(_ item: Food) {
        self.item = item
        imagesContainer.isHidden = item.images.count == 1
        iconView.isHidden = item.images.count != 1
        if let first = item.images.first, item.images.count == 1 {
            loadImage(first, toView: iconView, item: item)
        }
        else {
            for view in imageViews {
                view.image = nil
            }
            for i in 0..<min(4, item.images.count) {
                if let view = imageViews.filter({$0.tag == i}).first {
                    loadImage(item.images[i], toView: view, item: item)
                }
            }
        }
        titleLabel.text = item.time.rawValue.capitalized
        valueLabel.text = item.items.map({$0.title}).joined(separator: ", ")
    }

    /// Load image
    ///
    /// - Parameters:
    ///   - image: the image or image URL
    ///   - imageView: the image view
    ///   - item: the related food item
    private func loadImage(_ image: Any, toView imageView: UIImageView, item: Food) {
        if let image = image as? UIImage {
            imageView.image = image
        }
        else if let url = image as? String {
            UIImage.loadAsync(url, callback: { (image) in
                if self.item.id == item.id {
                    imageView.image = image
                }
            })
        }
    }
}
