//
//  ChartsTableViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/3/18.
//  Modified by TCCODER on 4/1/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/// the keys
let kHiddenMetrics = "kHiddenMetrics"

/**
 * Table with all lab values used to show Charts
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - bold font if data is presented
 *
 * 1.2:
 * - "Edit" feature support
 */
class ChartsTableViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var bottomPanel: UIView!
    @IBOutlet weak var bottomPanelHeight: NSLayoutConstraint!

    /// the related report to open
    var report: Report?

    /// the table model
    private var table = SectionInfiniteTableViewModel<QuantityType, LabValueTableViewCell>()

    /// the storage
    private var storage: QuantitySampleService = QuantitySampleStorage.shared

    /// the cached metadata
    private var hasData = [String: Bool]()

    /// flag: true - data availability check in progress, false - else
    private var dataAvailabilityCheckInProgress = false
    /// the reference to API
    private let serviceApi: ServiceApi = CachingServiceApi.shared

    /// flag: true - editing mode, false - view mode
    private var isEditingMode = false

    /// the unselected values
    private var unselectedValues = [String]()

    /// the last loaded values
    private var lastLoadedValues = [[QuantityType]]()

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
//        setupRightBarButtonsNavigation()
        self.navigationItem.rightBarButtonItem = nil
        bottomPanel.isHidden = true
        bottomPanelHeight.constant = 0

        noDataLabel.isHidden = true
        tableView.estimatedRowHeight = 60
        table.noDataLabel = noDataLabel
        table.configureCell = { indexPath, item, _, cell in
            let isSelected: Bool? = self.isEditingMode ? !self.unselectedValues.contains(item.id): nil
            cell.configure(item: item, hasData: self.hasData[item.id] ?? false, isSelected: isSelected)
        }
        table.onSelect = { indexPath, item in
            if self.isEditingMode {
                self.toggleItemSelection(item)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            else {
                self.openChart(item)
            }
        }
        table.loadSectionItems = { callback, failure in
            self.updateUnselectedValues()
            self.serviceApi.getLabValues(callback: { (values) in
                self.lastLoadedValues = values
                let values = self.filterValues(values)
                let count = values.map({$0.count}).reduce(0, +)
                if count > 0 {
                    if values.first?.count ?? 0 == 0 {
                        callback([values.last ?? []], [NSLocalizedString("Other", comment: "Other")])
                    }
                    else if values.last?.count ?? 0 == 0 {
                        callback([values.first ?? []], [NSLocalizedString("Major", comment: "Major")])
                    }
                    else {
                        callback(values, [NSLocalizedString("Major", comment: "Major"), NSLocalizedString("Other", comment: "Other")])
                    }
                }
                else {
                    callback([], [])
                }
            }, failure: failure)
        }
        table.bindData(to: tableView)
    }

    /// Update table to show if there are data or not
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkDataAvailability()
    }

    /// Check data availability
    private func checkDataAvailability() {
        guard !dataAvailabilityCheckInProgress else { return }
        dataAvailabilityCheckInProgress = true
        var items = [QuantityType]()
        for section in lastLoadedValues {
            items.append(contentsOf: section)
        }
        checkDataAvailability(index: 0, list: items) {
            self.dataAvailabilityCheckInProgress = false
            self.tableView.reloadData()
        }
    }

    /// Check data availability for item at index
    ///
    /// - Parameters:
    ///   - index: the index
    ///   - list: the list
    ///   - callback: the callback to invoke after all items are checked
    private func checkDataAvailability(index: Int, list: [QuantityType], callback: @escaping ()->()) {
        if index < list.count {
            let item = list[index]
            self.storage.hasData(item, callback: { (result) in
                self.hasData[item.id] = result
                self.checkDataAvailability(index: index + 1, list: list, callback: callback)
            }, customTypeCallback: {
                self.checkDataAvailability(index: index + 1, list: list, callback: callback)
            })
        }
        else {
            callback()
        }
    }

    /// Open chart for given lab value
    ///
    /// - Parameter item: the item
    private func openChart(_ item: QuantityType) {
        if let vc = create(ChartViewController.self) {
            vc.quantityTypes = [item]
            if item.id == QuantityTypeCustom.bloodCholesterol.rawValue {
                vc.type = .discreteValues
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Editing mode

    /// Setup right bar buttons
    /// Not used after #125
    func setupRightBarButtonsNavigation() {
        if !isEditingMode {
            let item1 = UIBarButtonItem(customView: createBarButton(#imageLiteral(resourceName: "goalsIcon"), selector: #selector(openGoals), xOffset: 0, yOffset: 0))
            let item2 = UIBarButtonItem(title: NSLocalizedString("Edit", comment: "Edit"), style: .plain, target: self, action: #selector(editAction))
            self.navigationItem.rightBarButtonItems = [item2, item1]
        }
        else {
            let item2 = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .plain, target: self, action: #selector(doneAction))
            self.navigationItem.rightBarButtonItem = item2
        }
    }

    /// Edit button action
    @objc func editAction() {
        isEditingMode = true
        updateAfterModeChange()
    }

    /// Done button action
    @objc func doneAction() {
        isEditingMode = false
        // Save unselected values (hidden metrics)
        UserDefaults.standard.set(unselectedValues, forKey: kHiddenMetrics)
        UserDefaults.standard.synchronize()
        updateAfterModeChange()
    }

    /// Update after mode changed
    private func updateAfterModeChange() {
        bottomPanel.isHidden = !isEditingMode
        bottomPanelHeight.constant = isEditingMode ? 44 : 0
        table.loadData()
        setupRightBarButtonsNavigation()
    }

    /// The values
    ///
    /// - Parameter values: the values
    /// - Returns: the values
    private func filterValues(_ values: [[QuantityType]]) -> [[QuantityType]] {
        if isEditingMode {
            return values
        }
        else {
            let hiddenValueIds = UserDefaults.standard.value(forKey: kHiddenMetrics) as? [String] ?? []
            var list = [[QuantityType]]()
            for set in values {
                list.append(set.filter({!hiddenValueIds.contains($0.id)}))
            }
            return list
        }
    }

    /// Update `unselectedValues` from UserDefaults
    private func updateUnselectedValues() {
        unselectedValues = UserDefaults.standard.value(forKey: kHiddenMetrics) as? [String] ?? []
        selectAllButton.isSelected = lastLoadedValues.map({$0.count}).reduce(0, +) > 0 && unselectedValues.isEmpty
    }

    /// Toggle selection
    ///
    /// - Parameter item: the item
    private func toggleItemSelection(_ item: QuantityType) {
        if let index = unselectedValues.index(of: item.id) {
            unselectedValues.remove(at: index)
        }
        else {
            unselectedValues.append(item.id)
        }
        selectAllButton.isSelected = lastLoadedValues.map({$0.count}).reduce(0, +) > 0 && unselectedValues.isEmpty
    }

    /// "Select/Deselect All" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func selectAllButtonAction(_ sender: Any) {
        unselectedValues.removeAll()
        if selectAllButton.isSelected {
            for set in lastLoadedValues {
                unselectedValues.append(contentsOf: set.map({$0.id}))
            }
        }
        selectAllButton.isSelected = !selectAllButton.isSelected
        self.tableView.reloadData()
    }
}

/**
 * Cell for food items
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - font change support
 *
 * 1.2:
 * - editable list changes
 */
class LabValueTableViewCell: ZeroMarginsCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var checkbox: UIButton!

    /// the show item
    fileprivate var item: QuantityType!

    /// Update UI
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - hasData: true - if has data, false - else
    ///   - isSelected: nil - view mode, not nil - editing mode (value means selection state)
    func configure(item: QuantityType, hasData: Bool, isSelected: Bool?) {
        self.item = item
        let font = UIFont(name: hasData ? Fonts.Bold : Fonts.Light, size: titleLabel.font.pointSize)!
        let string = NSMutableAttributedString(string: item.title, attributes: [.font : font, .foregroundColor: hasData ? Colors.green : Colors.black])
        titleLabel.attributedText = string

        applySelection(isSelected: isSelected)
    }

    /// Apply selection
    ///
    /// - Parameter isSelected: nil - view mode, not nil - editing mode (value means selection state)
    fileprivate func applySelection(isSelected: Bool?) {
        checkbox.isHidden = isSelected == nil
        leftMargin.constant = isSelected == nil ? 20 : 44
        if let selected = isSelected {
            checkbox.isSelected = selected
        }
        checkbox.alpha = isSelected == nil ? 0 : 1
    }
}
