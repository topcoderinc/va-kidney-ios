//
//  CheckboxPickerViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 5/24/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * CheckboxPickerViewController delegate protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol CheckboxPickerViewControllerDelegate {

    /// Selection updated
    ///
    /// - Parameters:
    ///   - values: the values
    ///   - picker: the picker
    func checkboxValueUpdated(_ values: [PickerValue], picker: CheckboxPickerViewController)
}

/**
 * Model object for a filter group
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FilterGroupPickerValue: PickerValue {

    /// the action to process. First parameter is a callback to invoke after action is applied
    var action: ((@escaping ()->())->())?
}

/**
 * Picker with checkboxes view controller
 *
 * - author: TCCODER
 * - version: 1.0
 */
class CheckboxPickerViewController: UIViewController {

    /// outlets
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!

    // the delegate
    private var delegate: CheckboxPickerViewControllerDelegate?

    /// the data to show
    private var data = [PickerValue]()
    private var selected = [PickerValue]()

    /// the table model
    private var table = InfiniteTableViewModel<PickerValue, CheckboxPickerValueCell>()

    /// Show popup
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - selected: the selected values
    ///   - data: the data
    ///   - delegate: the delegate
    /// - Returns: view controller
    @discardableResult
    class func show(title: String,
                    selected: [PickerValue] = [],
                    data: [PickerValue],
                    delegate: CheckboxPickerViewControllerDelegate) -> CheckboxPickerViewController? {
        if let parent = UIViewController.getCurrentViewController() {
            if let vc = parent.create(CheckboxPickerViewController.self, storyboardName: "Profile") {
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

    /// Show popup
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - data: the data
    ///   - delegate: the delegate
    /// - Returns: view controller
    @discardableResult
    class func showFilter(title: String,
                    data: [FilterGroupPickerValue],
                    delegate: CheckboxPickerViewControllerDelegate) -> CheckboxPickerViewController? {
        if let parent = UIViewController.getCurrentViewController() {
            if let vc = parent.create(CheckboxPickerViewController.self, storyboardName: "Food") {
                vc.title = title
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

        self.view.backgroundColor = UIColor.clear
        self.titleLabel.text = title

        table.configureCell = { indexPath, item, _, cell in
            cell.configure(item, isSelected: self.selected.map{$0.hashValue}.contains(item.hashValue))
        }
        table.onSelect = { indexPath, item in
            if let item = item as? FilterGroupPickerValue {
                item.action?({
                    self.tableView.reloadData()
                })
                self.tableView.deselectRow(at: indexPath, animated: false)
            }
            else {
                self.toggleItem(item)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        table.loadItems = { callback, failure in
            callback(self.data)
        }
        table.bindData(to: tableView)
    }

    /// Toggle selection
    ///
    /// - Parameter item: the item
    private func toggleItem(_ item: PickerValue) {
        if let index = selected.map({$0.hashValue}).index(of: item.hashValue) {
            selected.remove(at: index)
        }
        else {
            selected.append(item)
        }
    }

    // MARK: - Button actions

    /// "Done" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func doneButtonAction(_ sender: Any) {
        if data.first is FilterGroupPickerValue {
            self.delegate?.checkboxValueUpdated(data, picker: self)
        }
        else {
            self.delegate?.checkboxValueUpdated(selected, picker: self)
        }
        self.closePicker()
    }

    /// "Close" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func closeButtonAction(_ sender: Any) {
        self.closePicker()
    }

    /**
     Close the picker
     */
    func closePicker(animated: Bool = true, _ callback: (()->())? = nil) {
        if animated {
            self.dismissViewControllerToSide(self, side: .bottom, callback)
        }
        else {
            self.removeFromParent()
        }
    }

}

/**
 * Cell for the table in this screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class CheckboxPickerValueCell: UITableViewCell {

    /// outlets
    @IBOutlet weak var checkbox: UIButton?
    @IBOutlet weak var titleLabel: UILabel!

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item
    ///   - isSelected: selection flag
    func configure(_ item: PickerValue, isSelected: Bool) {
        titleLabel.text = item.description
        checkbox?.isSelected = isSelected
    }
}
