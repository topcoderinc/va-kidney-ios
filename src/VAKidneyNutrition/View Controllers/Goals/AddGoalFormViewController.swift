//
//  AddGoalFormViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Add Goal form
 *
 * - author: TCCODER
 * - version: 1.0
 */
class AddGoalFormViewController: UIViewController, PickerViewControllerDelegate, UITextFieldDelegate {

    /// the number of points a goal can give
    let POINTS = 50 // is not a part of configuration because the logic will be much more complex and each goal can have different number of points

    @IBOutlet weak var unitsField: UITextField!
    @IBOutlet weak var frequencyField: UITextField!

    @IBOutlet var switchButtons: [UIButton]!
    @IBOutlet weak var switchButtonsView: UIView!
    @IBOutlet weak var switchSelectorView: UIView!
    @IBOutlet weak var switchSelectorLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var switchSelectorWidth: NSLayoutConstraint!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var tipsContainer: UIView!
    @IBOutlet weak var rewardView: UIView!
    @IBOutlet weak var rewardInfoLabel: UILabel!
    @IBOutlet weak var rewardPointsLabel: UILabel!
    @IBOutlet weak var rewardHeight: NSLayoutConstraint!
    @IBOutlet weak var tipsTextLabel: UILabel!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var saveButtonLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: CustomButton!
    @IBOutlet weak var mainView: UIView!

    /// the goal to edit
    var goal: Goal?

    // the index of the button
    private var selectedCategory: GoalCategory?

    /// the selected task
    var selectedTask: String?

    /// the selected units
    var selectedUnits: Float?

    /// the selected frequency
    var selectedFrequency: GoalFrequency?

    /// the values from last picker
    var allCategories = [GoalCategory]()
    var allTasks = [String]()

    /// the previously selected units
    var selectedUnitsForCategory = [String: Float]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        switchButtonsView.makeRound()
        switchSelectorView.makeRound()
        initBackButtonFromChild()
        switchSelectorView.backgroundColor = Colors.darkBlue
        tipsContainer.roundCorners()

        if let _ = goal {
            self.view.layoutIfNeeded()
            let spacing: CGFloat = 12
            saveButtonLeftMargin.constant = (mainView.bounds.width - spacing) / 2 + spacing
            deleteButton.isHidden = false
        }
        else {
            saveButtonLeftMargin.constant = 0
            deleteButton.isHidden = true
        }
        self.view.layoutIfNeeded()
        loadData()
    }

    /// Load data
    private func loadData() {
        api.getCategories(callback: { (list) in
            self.allCategories = list

            for button in self.switchButtons {
                if button.tag < list.count {
                    button.setTitle(list[button.tag].title, for: .normal)
                    button.setTitle(list[button.tag].title, for: .selected)
                }
                else {
                    button.setTitle("", for: .normal)
                }
                if isIPhone5() {
                    let title = button.title(for: .normal) ?? ""
                    let fontSize: CGFloat = 12
                    var string = NSMutableAttributedString(string: title, attributes: [
                        .font: UIFont(name: Fonts.Regular, size: fontSize)!,
                        .foregroundColor: (UIColor.fromString("666666") ?? Colors.black)
                        ])
                    button.setAttributedTitle(string, for: .normal)
                    string = NSMutableAttributedString(string: title, attributes: [
                        .font: UIFont(name: Fonts.Regular, size: fontSize)!,
                        .foregroundColor: UIColor.white])
                    button.setAttributedTitle(string, for: .selected)
                }
            }
            self.view.layoutIfNeeded()
            DispatchQueue.main.async {
                self.selectedCategory = self.goal?.category
                self.selectedUnits = self.goal?.targetValue
                if let units = self.selectedUnits, let cat = self.selectedCategory {
                    self.selectedUnitsForCategory[cat.id] = units
                }
                if let value = self.goal?.isReminderOn {
                    self.reminderSwitch.isOn = value
                }
                self.updateUI()
            }
        }, failure: createGeneralFailureCallback())

        tipsTextLabel.text = NSLocalizedString("Loading...", comment: "Loading...")
        api.getGoalTip(callback: { (json) in
            self.tipsTextLabel.text = json["text"].stringValue
            self.tipsTextLabel.setLineSpacing(lineSpacing: 4.5)
        }, failure: createGeneralFailureCallback())
    }

    /// Update UI
    private func updateUI() {
        if let _ = goal {
            title = NSLocalizedString("Edit Goal", comment: "Edit Goal").uppercased()
        }
        if let category = selectedCategory ?? goal?.category {
            selectedTask = category.title
            var i = 0
            for cat in allCategories {
                if cat.id == category.id {
                    updateSwitchButtons(i)
                    break
                }
                i += 1
            }
        }
        else {
            selectedCategory = allCategories.first
            selectedTask = selectedCategory?.title
            self.selectedUnits = nil
            updateSwitchButtons(0)
        }
        updateUnitsLabel(selectedUnits)
        if (selectedFrequency ?? goal?.frequency) == nil {
            selectedFrequency = GoalFrequency(rawValue: GoalFrequency.getAll().map({$0.rawValue.capitalized}).first?.lowercased() ?? "")
        }
        if let frequency = selectedFrequency ?? goal?.frequency {
            freqLabel.text = frequency.rawValue.capitalized
            rewardPointsLabel.text = "\(POINTS)"
            rewardInfoLabel.text = "Get \(POINTS) points for every 1 \(frequency.toSingular()) achieved"
            UIView.animateWithDefaultSettings {
                self.rewardHeight.constant = 142.5 // as in design
            }
            rewardView.isHidden = false
        }
        else {
            rewardView.isHidden = true
            rewardHeight.constant = 24
        }
    }

    /// Update units label
    ///
    /// - Parameter unitsValue: the value
    private func updateUnitsLabel(_ unitsValue: Float?) {
        if let value = unitsValue {
            if let task = selectedTask ?? goal?.title {
                api.getUnits(task: task, callback: { (limits, suffix, _) in

                    let units = "\(value.toString()) \((value == 1 ? suffix.0 : suffix.1))"
                    self.unitLabel.text = units

                }, failure: createGeneralFailureCallback())
            }
            else {
                unitLabel.text = ""
            }
        }
        else {
            unitLabel.text = ""
        }
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
        goal.isReminderOn = reminderSwitch.isOn
        let isEditing = !goal.id.isEmpty
        api.getUnits(task: goal.title, callback: { (limits, suffix, extra) in
            goal.valueText1 = suffix.0
            goal.valueTextMultiple = suffix.1
            goal.valueText = suffix.2
            goal.iconName = extra.0
            goal.color = extra.1
            self.api.saveGoal(goal: goal, callback: { (goal) in
                self.goal = goal
                self.navigationController?.popViewController(animated: true)
                if !isEditing {
                    delay(0.3) {
                        self.showAlert("Goal saved", "")
                    }
                }
            }, failure: self.createGeneralFailureCallback())
        }, failure: createGeneralFailureCallback())
    }

    /// "Delete" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func deleteAction(_ sender: Any) {
        if let goal = goal {
            api.deleteGoal(goal: goal, callback: {
                self.navigationController?.popViewController(animated: true)
            }, failure: createGeneralFailureCallback())
        }
    }

    /// Switch button action handler
    ///
    /// - parameter sender: the button
    @IBAction func switchAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let index = sender.tag
        if index < allCategories.count {
            selectedCategory = allCategories[index]
            selectedTask = selectedCategory?.title
            self.selectedUnits = nil
            if let cat = selectedCategory, let lastUnits = selectedUnitsForCategory[cat.id] {
                self.selectedUnits = lastUnits
            }
        }
        updateSwitchButtons(index)
        updateUI()
    }

    /// Update switch buttons
    ///
    /// - Parameter index: the index
    private func updateSwitchButtons(_ index: Int) {
        if index < allCategories.count {
            selectedCategory = allCategories[index]
            selectedTask = selectedCategory?.title
            for button in switchButtons {
                button.isSelected = index == button.tag
                if button.isSelected {
                    updateswitchTimeIndicator(button)
                }
            }
        }
    }

    /// Update switch time
    ///
    /// - Parameter button: the button
    private func updateswitchTimeIndicator(_ button: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.switchSelectorWidth.constant = button.bounds.width + 10
            self.switchSelectorLeftMargin.constant = button.frame.origin.x - 5
            self.view.layoutIfNeeded()
        }, completion: nil)
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

    /// Open picker
    ///
    /// - Parameter textField: the textField
    /// - Returns: false
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case unitsField:
            if let task = selectedTask ?? goal?.title {
                api.getUnits(task: task, callback: { (limits, suffix, _) in
                    var values = [String]()
                    for i in stride(from: limits.0.lowerBound, to: limits.0.upperBound + 1, by: limits.1) {
                        values.append("\(i) \((i == 1 ? suffix.0 : suffix.1))")
                    }
                    PickerViewController.show(title: "units", selected: PickerValue(self.unitLabel.text), data: values.map{PickerValue($0)}, delegate: self)
                }, failure: createGeneralFailureCallback())
            }
            else {
                showAlert(NSLocalizedString("Select task", comment: "Select task"), NSLocalizedString("Please select a category and a task first", comment: "Please select a category and a task first"))
            }
        case frequencyField:
            PickerViewController.show(title: "frequency", selected: PickerValue(freqLabel.text), data: GoalFrequency.getAll().map({PickerValue($0.rawValue.capitalized)}), delegate: self)
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
    func pickerValueUpdated(_ value: PickerValue, picker: PickerViewController) {
        switch picker.title ?? "" {
        case "units":
            self.selectedUnits = Float(value.description.split(separator: " ").first ?? "") ?? 0
            if let cat = selectedCategory, let units = self.selectedUnits {
                self.selectedUnitsForCategory[cat.id] = units
            }
        case "frequency":
            self.selectedFrequency = GoalFrequency(rawValue: value.description.lowercased())
        default:
            return
        }
        self.updateUI()
    }

}
