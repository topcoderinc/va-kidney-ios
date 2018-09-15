//
//  AddGoalFormViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/4/18.
//  Modified by TCCODER on 4/1/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/// option: true - will substitute existing goal value if user tries to add new goal of the same type
let OPTION_ADD_GOAL_USE_DEFAULT_VALUE_FROM_PREVIOUS_GOAL = true
/// option: true - will replace existing goals if user will try to save a goal with the same type, false - will add new goal
let OPTION_REPLACE_EXISTING_GOALS = true

/**
 * Add Goal form
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - goal patterns added instead of categories to support limited set of goals that depend on profile data
 * 1.2:
 * - font size increased
 */
class AddGoalFormViewController: UIViewController, PickerViewControllerDelegate, UITextFieldDelegate {

    /// the number of points a goal can give
    let POINTS = 50 // is not a part of configuration because the logic will be much more complex and each goal can have different number of points

    @IBOutlet weak var unitsField: UITextField!
    @IBOutlet weak var frequencyField: UITextField!

    @IBOutlet weak var switchButtonsView: UIView!
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
    @IBOutlet weak var collectionView: UICollectionView!

    /// the goal to edit
    var goal: Goal?

    // the selected goal pattern
    private var selectedPattern: Goal?

    /// the selected units
    var selectedUnits: Float?

    /// the selected frequency
    var selectedFrequency: GoalFrequency?

    /// the patterns
    var allPatterns = [Goal]()

    /// the previously selected units
    var selectedUnitsForGoal = [String: Float]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// collection view data source
    private var dataSource: CollectionDataSource<GoalPatternCell>!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        switchButtonsView.makeRound()
        initBackButtonFromChild()
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
        self.dataSource = CollectionDataSource(collectionView, cellClass: GoalPatternCell.self) { (item, cell, indexPath) in
            let goal = item as! Goal
            cell.configure(goal, isSelected: self.selectedPattern?.title == goal.title, isFirst: indexPath.row == 0 ? true : (indexPath.row == self.dataSource.items.count - 1 ? false : nil))
        }
        dataSource.selected = { item in
            self.selectedPattern = item as? Goal
            self.view.endEditing(true)
            self.updateUI()
            self.collectionView.reloadData()
        }
        dataSource.calculateCellSize = { item, _ -> CGSize in
            let goal = item as! Goal
            let size = (goal.title as NSString).size(withAttributes: [.font: UIFont(name: Fonts.Regular, size: 16)!])
            return CGSize(width: size.width + 35, height: self.collectionView.bounds.height) // 30 is summary padding for text in IB
        }
        loadData()
    }

    /// Load data
    private func loadData() {
        api.getProfile(callback: { (profile) in
            self.api.getGoalPatterns(profile: profile, callback: { (patterns) in
                self.allPatterns = patterns
                self.selectedPattern = self.goal ?? patterns.first
                self.selectedUnits = self.goal?.targetValue
                if let units = self.selectedUnits, let goal = self.selectedPattern {
                    self.selectedUnitsForGoal[goal.title] = units
                }
                if let value = self.goal?.isReminderOn {
                    self.reminderSwitch.isOn = value
                }
                self.dataSource.setItems(patterns)
                if let goal = self.goal {
                    // Scroll to current goal
                    DispatchQueue.main.async {
                        var indexPath: IndexPath?
                        for i in 0..<self.allPatterns.count {
                            if goal.title == self.allPatterns[i].title {
                                indexPath = IndexPath(row: i, section: 0); break
                            }
                        }
                        if let indexPath = indexPath {
                            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                        }
                    }
                }
                self.updateUI()

            }, failure: self.createGeneralFailureCallback())
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
        self.selectedUnits = nil
        if let selectedPattern = selectedPattern, selectedUnitsForGoal[selectedPattern.title] == nil, OPTION_ADD_GOAL_USE_DEFAULT_VALUE_FROM_PREVIOUS_GOAL {
            getExistingGoal(forPattern: selectedPattern, callback: { (currentGoal) in
                if let currentGoal = currentGoal {
                    self.selectedUnits = currentGoal.targetValue
                }
                self.updateUnitsLabel(self.selectedUnits)
            })
        }
        else {
            if let goal = selectedPattern, let lastUnits = selectedUnitsForGoal[goal.title] {
                self.selectedUnits = lastUnits
            }
            updateUnitsLabel(selectedUnits)
        }
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

    /// Get existing goal for pattern
    ///
    /// - Parameters:
    ///   - pattern: the pattern
    ///   - callback: the callback to return the result
    private func getExistingGoal(forPattern pattern: Goal, callback: @escaping (Goal?)->()) {
        api.getProfile(callback: { (profile) in
            self.api.getGoals(profile: profile, callback: { (goals) in
                if let currentGoal = goals.filter({$0.title == pattern.title}).first {
                    callback(currentGoal)
                }
                else {
                    callback(nil)
                }
            }, failure: self.createGeneralFailureCallback())
        }, failure: createGeneralFailureCallback())
    }

    /// Update units label
    ///
    /// - Parameter unitsValue: the value
    private func updateUnitsLabel(_ unitsValue: Float?) {
        if let value = unitsValue {
            if let selectedPattern = selectedPattern {
                api.getUnits(goal: selectedPattern, callback: { (limits, suffix, _) in

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
        guard let selectedPattern = selectedPattern, (self.goal == nil || !(self.goal == nil && (selectedUnits == nil || selectedFrequency == nil))) else {
            showError(errorMessage: NSLocalizedString("Please fill all fields", comment: "Please fill all fields"))
            return
        }
        let callback: (Goal?)->() = { existingGoal in
            let goal = existingGoal ?? selectedPattern
            if let units = self.selectedUnits {
                goal.targetValue = units
            }
            if let frequency = self.selectedFrequency {
                goal.frequency = frequency
            }
            goal.isReminderOn = self.reminderSwitch.isOn
            let isEditing = self.goal != nil
            self.api.getUnits(goal: goal, callback: { (limits, suffix, extra) in
                goal.valueText1 = suffix.0
                goal.valueTextMultiple = suffix.1
                goal.valueText = suffix.2
                goal.iconName = extra.0
                goal.color = extra.1
                self.api.saveGoal(goal: goal, callback: { (goal) in
                    
                    
                    let loadingView = LoadingView(parentView: UIApplication.shared.keyWindow, dimming: true).show()
                    // check food recommendations
                    FoodUtils.shared.process(food: nil, callback: {
                        loadingView.terminate()
                        self.navigationController?.popViewController(animated: true)
                        if !isEditing || self.goal?.title != existingGoal?.title {
                            delay(0.3) {
                                self.showAlert("Goal saved", existingGoal == nil ? "" : "Existing goal updated")
                            }
                        }
                    })
                }, failure: self.createGeneralFailureCallback())
            }, failure: self.createGeneralFailureCallback())
        }
        if OPTION_REPLACE_EXISTING_GOALS {
            getExistingGoal(forPattern: selectedPattern, callback: callback)
        }
        else {
            callback(nil)
        }
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
            if let goal = selectedPattern {
                api.getUnits(goal: goal, callback: { (limits, suffix, _) in
                    var values = [String]()
                    for i in stride(from: limits.0.lowerBound, to: limits.0.upperBound + 1, by: limits.1) {
                        values.append("\(i.toString()) \((i == 1 ? suffix.0 : suffix.1))")
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
            if let goal = selectedPattern, let units = self.selectedUnits {
                self.selectedUnitsForGoal[goal.title] = units
            }
        case "frequency":
            self.selectedFrequency = GoalFrequency(rawValue: value.description.lowercased())
        default:
            return
        }
        self.updateUI()
    }

}

/**
 * Cell for goal patterns
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - font size increased
 */
class GoalPatternCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bgLeftPadding: NSLayoutConstraint!
    @IBOutlet weak var bgRightPadding: NSLayoutConstraint!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.makeRound()
        if isIPhone5() {
            titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 14)
        }
    }

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    ///   - isSelected: true - if selected
    ///   - isFirst: true - if first cell, false - if last, nil - if intermidiate
    func configure(_ item: Goal, isSelected: Bool, isFirst: Bool?) {
        titleLabel.text = item.title
        if let isFirst = isFirst {
            bgLeftPadding.constant = isFirst ? 30 : 0
            bgRightPadding.constant = isFirst ? 0 : 30
        }
        else {
            bgLeftPadding.constant = 0
            bgRightPadding.constant = 0
        }
        bgView.backgroundColor = isSelected ? Colors.darkBlue : UIColor.white
        titleLabel.textColor = isSelected ? UIColor.white : UIColor(hex: 0x666666)
    }

}
