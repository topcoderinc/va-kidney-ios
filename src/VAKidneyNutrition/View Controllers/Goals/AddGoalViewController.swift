//
//  AddGoalViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/24/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIComponents

/**
 * "Add/Edit A Goal" screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class AddGoalViewController: UIViewController, UITextFieldDelegate, PickerViewControllerDelegate {

    /// the number of points a goal can give
    let POINTS = 50 // is not a part of configuration because the logic will be much more complex and each goal can have different number of points

    /// outlets
    @IBOutlet weak var categoryStateLabel: UILabel!
    @IBOutlet weak var taskStateLabel: UILabel!
    @IBOutlet weak var unitsStateLabel: UILabel!
    @IBOutlet weak var frequencyStateLabel: UILabel!
    @IBOutlet weak var rewardInfoLabel: UILabel!
    @IBOutlet weak var progressView: CustomProgressView!

    @IBOutlet weak var categoryField: CustomTextField!
    @IBOutlet weak var taskField: CustomTextField!
    @IBOutlet weak var unitsField: CustomTextField!
    @IBOutlet weak var frequencyField: CustomTextField!

    @IBOutlet weak var messageLabel: UILabel!

    /// the goal to edit
    var goal: Goal?

    /// the selected category
    var selectedCategory: GoalCategory?

    /// the selected task
    var selectedTask: String?

    /// the selected units
    var selectedUnits: Float?

    /// the selected frequency
    var selectedFrequency: GoalFrequency?

    /// the values from last picker
    var allCategories = [GoalCategory]()
    var allTasks = [String]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        updateUI()
    }

    /// Update UI
    private func updateUI() {
        if let _ = goal {
            title = NSLocalizedString("Edit A Goal", comment: "Edit A Goal")
        }
        var persent: Float = 0
        if let category = selectedCategory ?? goal?.category {
            categoryField.text = category.title
            categoryStateLabel.text = category.title
            persent += 0.25
        }
        else {
            categoryField.text = ""
            categoryStateLabel.text = categoryField.placeholder
        }
        if let task = selectedTask ?? goal?.title {
            taskField.text = task
            taskStateLabel.text = task
            persent += 0.25
        }
        else {
            taskField.text = ""
            taskStateLabel.text = taskField.placeholder
        }
        if let value = selectedUnits ?? goal?.targetValue {

            if let task = selectedTask ?? goal?.title {
                api.getUnits(task: task, callback: { (limits, suffix) in

                    let units = "\(value.toString()) \((value == 1 ? suffix.0 : suffix.1))"
                    self.unitsField.text = units
                    self.unitsStateLabel.text = units

                }, failure: createGeneralFailureCallback())
            }
            else {
                unitsField.text = ""
                unitsStateLabel.text = unitsField.placeholder
            }
            persent += 0.25
        }
        else {
            unitsField.text = ""
            unitsStateLabel.text = unitsField.placeholder
        }
        if let frequency = selectedFrequency ?? goal?.frequency {
            frequencyField.text = frequency.rawValue.capitalized
            frequencyStateLabel.text = frequency.rawValue
            rewardInfoLabel.text = "Reward: \(POINTS) points \(frequency.rawValue.capitalized)"
            persent += 0.25
        }
        else {
            frequencyField.text = ""
            frequencyStateLabel.text = frequencyField.placeholder
            rewardInfoLabel.text = ""
        }
        progressView.progress = persent
    }

    /// "Save this goal" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func saveGoalAction(_ sender: Any) {
        if self.goal == nil && (selectedCategory == nil || selectedTask == nil || selectedUnits == nil || selectedFrequency == nil) {
            showError(errorMessage: NSLocalizedString("Please fill all fields", comment: "Please fill all fields"))
            return
        }
        let goal = self.goal ?? Goal(id: "")
        if let category = selectedCategory {
            goal.category = category
            goal.categoryId = category.id
        }
        if let task = selectedTask {
            goal.title = task
        }
        if let units = selectedUnits {
            goal.targetValue = units
        }
        if let frequency = selectedFrequency {
            goal.frequency = frequency
        }
        api.getUnits(task: goal.title, callback: { (limits, suffix) in
            goal.valueText1 = suffix.0
            goal.valueTextMultiple = suffix.1
            self.api.saveGoal(goal: goal, callback: { (goal) in
                self.goal = goal
                self.showAlert("Goal saved", "")
            }, failure: self.createGeneralFailureCallback())
        }, failure: createGeneralFailureCallback())
    }

    // MARK: - UITextFieldDelegate

    /// Open picker
    ///
    /// - Parameter textField: the textField
    /// - Returns: false
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case categoryField:
            api.getGoals(callback: { (_, categories) in
                self.allCategories = categories
                PickerViewController.show(title: "category", selected: textField.text, data: categories.map({$0.title}), delegate: self)
            }, failure: createGeneralFailureCallback())
        case taskField:
            if let category = selectedCategory ?? goal?.category {
                api.getTasks(category: category, callback: { (tasks) in
                    self.allTasks = tasks
                    PickerViewController.show(title: "task", selected: textField.text, data: tasks, delegate: self)
                }, failure: createGeneralFailureCallback())
            }
            else {
                showAlert(NSLocalizedString("Select category", comment: "Select category"), NSLocalizedString("Please select a category first", comment: "Please select a category first"))
            }
        case unitsField:
            if let task = selectedTask ?? goal?.title {
                api.getUnits(task: task, callback: { (limits, suffix) in
                    var values = [String]()
                    for i in limits {
                        values.append("\(i) \((i == 1 ? suffix.0 : suffix.1))")
                    }
                    PickerViewController.show(title: "units", selected: textField.text, data: values, delegate: self)
                }, failure: createGeneralFailureCallback())
            }
            else {
                showAlert(NSLocalizedString("Select task", comment: "Select task"), NSLocalizedString("Please select a category and a task first", comment: "Please select a category and a task first"))
            }
        case frequencyField:
            PickerViewController.show(title: "frequency", selected: textField.text, data: GoalFrequency.getAll().map({$0.rawValue.capitalized}), delegate: self)
        default:
            break
        }
        return false
    }

    // MARK: - PickerViewControllerDelegate

    /// Update value
    ///
    /// - Parameters:
    ///   - value: the value
    ///   - picker: the picker
    func pickerValueUpdated(_ value: String, picker: PickerViewController) {
        switch picker.title ?? "" {
        case "category":
            let category = allCategories.filter({$0.title == value}).first
            if (selectedCategory ?? goal?.category)?.hashValue != category?.hashValue {
                self.selectedTask = nil
                self.selectedUnits = nil
            }
            self.selectedCategory = category
        case "task":
            self.selectedTask = value
            self.selectedUnits = nil
        case "units":
            self.selectedUnits = Float(value.split(separator: " ").first ?? "") ?? 0
        case "frequency":
            self.selectedFrequency = GoalFrequency(rawValue: value.lowercased())
        default:
            return
        }
        self.updateUI()
    }

}
