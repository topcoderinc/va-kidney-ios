//
//  ProfileViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/// Possible Disease Categories
enum DiseaseCategory: String {
    case stage1 = "Stage 1", stage2 = "Stage 2", stage3a = "Stage 3a", stage3b = "Stage 3b", stage4 = "Stage 4", stage5 = "Stage 5"

    /// Get all options
    ///
    /// - Returns: the list with all categories
    static func getAll() -> [DiseaseCategory] {
        return [.stage1, .stage2, .stage3a, .stage3b, .stage4, .stage5]
    }
}

/// option: true - will add "Done" button and will save only after that, false - will save immidiately
let OPTION_PROFILE_ADD_DONE_BUTTON = false
let OPTION_LIMIT_WEIGHT_VALUES = false
let OPTION_MOVE_TO_GOALS_AFTER_RESET = false

/**
 * Possible types of profile data
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - icons for types
 */
enum ProfileDataType {
    case name, date, height, currentWeight, dialysis, diseaseCategory, setupGoals, avatar, devices, comorbidities

    /// Get icon
    ///
    /// - Returns: the image icon
    func getIcon() -> UIImage {
        switch self {
        case .date: return #imageLiteral(resourceName: "iconBirth")
        case .height: return #imageLiteral(resourceName: "iconHeight")
        case .currentWeight: return #imageLiteral(resourceName: "iconWeight")
        case .dialysis, .diseaseCategory, .comorbidities: return #imageLiteral(resourceName: "iconQuestion")
        case .setupGoals: return #imageLiteral(resourceName: "iconSetupGoals")
        case .avatar: return #imageLiteral(resourceName: "iconAvatar")
        case .devices: return #imageLiteral(resourceName: "iconDevices")
        default:
            return UIImage()
        }
    }
}

/// Possible types of profile items
enum ProfilePickerType {
    case text, picker, avatar
}

/// boolean labels
let YES = NSLocalizedString("Yes", comment: "Yes")
let NO = NSLocalizedString("No", comment: "No")

class HeightPickerValue: PickerValue {

    let height: Double
    init(_ height: Double) {
        self.height = height
        super.init("")
    }

    override var description: String {
        var str = ""
        let feets = height / 12
        if feets > 0 {
            str = "\(Int(feets))ft "
        }
        let inches = height.truncatingRemainder(dividingBy: 12)
        if inches > 0 {
            str += "\(Int(inches))in"
        }
        return str.trim()
    }

    override var hashValue: Int {
        return height.hashValue
    }
}

/**
 Equatable protocol implementation

 - parameter lhs: the left object
 - parameter rhs: the right object

 - returns: true - if objects are equal, false - else
 */
func ==<T: HeightPickerValue>(lhs: T, rhs: T) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

/**
 * Model for Comorbid Condition picker value
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ComorbidConditionPickerValue: PickerValue {

    /// the value
    let comorbidCondition: ComorbidCondition

    /// Initializer
    init(_ comorbidCondition: ComorbidCondition) {
        self.comorbidCondition = comorbidCondition
        super.init(comorbidCondition.getTitle())
    }

    /// the description for UI
    override var description: String {
        return comorbidCondition.getTitle()
    }

    /// the hash value
    override var hashValue: Int {
        return comorbidCondition.rawValue.hashValue
    }
}

/**
 Equatable protocol implementation

 - parameter lhs: the left object
 - parameter rhs: the right object

 - returns: true - if objects are equal, false - else
 */
func ==<T: ComorbidConditionPickerValue>(lhs: T, rhs: T) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

/**
 * The profile item
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - birthday selection support
 */
class ProfileDataItem {

    /// the title
    let title: String

    /// the type
    let type: ProfilePickerType

    /// the type of the data
    let dataType: ProfileDataType

    // the data value
    var value: Any?

    /// Initializer
    init(title: String, type: ProfilePickerType, dataType: ProfileDataType, value: Any? = nil) {
        self.title = title
        self.type = type
        self.dataType = dataType
        self.value = value
    }

    /// Get value
    ///
    /// - Returns: the value
    func getValue() -> String {
        if let value = value as? Bool {
            return value ? YES : NO
        }
        else if let date = value as? Date {
            let years = date.yearsSinceDate()
            return "\(years) \(years == 1 ? NSLocalizedString("year", comment: "year") : NSLocalizedString("years", comment: "years"))"
        }
        else if let value = value {
            return "\(value)"
        }
        return "-"
    }
}

/// Age data item
class AgeProfileDataItem: ProfileDataItem {

    /// Get value
    ///
    /// - Returns: the value
    override func getValue() -> String {
        if let value = value as? Int {
            return "\(value) " + (value == 1 ? NSLocalizedString("year", comment: "year") : NSLocalizedString("years", comment: "years"))
        }
        return super.getValue()
    }
}

/// Height data item
class HeightProfileDataItem: ProfileDataItem {

    /// Get value
    ///
    /// - Returns: the value
    override func getValue() -> String {
        if let value = value as? Double {
            return HeightPickerValue(value).description
        }
        return super.getValue()
    }
}

/// Comorbid Condition data item
class ComorbidConditionDataItem: ProfileDataItem {

    /// Get value
    ///
    /// - Returns: the value
    override func getValue() -> String {
        if let value = value as? [ComorbidCondition] {
            let str = value.map({$0.getTitle()}).joined(separator: ", ")
            if str.isEmpty {
                return NSLocalizedString("No", comment: "No")
            }
            return str
        }
        return super.getValue()
    }
}

/// Weight data item
class WeightProfileDataItem: ProfileDataItem {

    /// Get value
    ///
    /// - Returns: the value
    override func getValue() -> String {
        if let value = value as? Double {
            return "\(Int(value))"
        }
        return super.getValue()
    }
}

/**
 * Profile screen
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
 * - date birth limited
 * - new limits for weight and height
 *
 * 1.4:
 * - label changes
 * - new Profile options
 */
class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PickerViewControllerDelegate, AddAssetButtonViewDelegate, DatePickerViewControllerDelegate, CheckboxPickerViewControllerDelegate, UITextFieldDelegate {

    /// the minimum age
    let MIN_AGE = 16
    /// the weight limits
    let WEIGHT_LIMIT: (Double, Double) = (45, 800)

    /// outlets
    @IBOutlet weak var profileImageView: AddAssetButtonView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!

    /// the items to show
    private var items = [ProfileDataItem]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// last picker type
    private var lastSelectedPickerType: ProfileDataType?

    /// the profile to show
    var profile: Profile?

    /// true - will skip changed in text fields, false - else
    private var skipChanges = false

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentOffset.y = -tableView.contentInset.top

        profileImageView.makeRound()
        profileImageView.addBorder(color: UIColor.white, borderWidth: 1)
        profileImageView.delegate = self
        if profile == nil {
            navigationItem.leftBarButtonItem = nil
        }
        else {
            setupNavigation()
            if OPTION_PROFILE_ADD_DONE_BUTTON {
                let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
                self.navigationItem.rightBarButtonItem = item
            }
            else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        loadData()

    }

    /// Setup navigation bar
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    /// Setup navigation bar
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBar()
    }

    /// Setup navigation bar
    private func setupNavigationBar() {
        self.view.layer.masksToBounds = false
        self.view.superview?.layer.masksToBounds = false
        self.view.superview?.superview?.layer.masksToBounds = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.layer.masksToBounds = false
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    /// Load data
    private func loadData() {
        self.userNameLabel.text = ""
        self.birthDateLabel.text = ""
        self.profileImageView.setSelectedImage(#imageLiteral(resourceName: "noProfileIcon"), resetPreviousImage: true)
        if let profile = profile {
            self.userNameLabel.text = profile.name.uppercased()
            if let date = profile.birthday {
                self.birthDateLabel.text = DateFormatters.shortDate.string(from: date)
            }
            if let image = profile.image {
                self.profileImageView.setSelectedImage(image, resetPreviousImage: true)
            }
            items = [
                AgeProfileDataItem(title: "Age", type: .picker, dataType: .date, value: profile.birthday),
                HeightProfileDataItem(title: "Height", type: .picker, dataType: .height, value: profile.height),
                WeightProfileDataItem(title: "Current Weight", type: .picker, dataType: .currentWeight, value: profile.currentWeight),
                ProfileDataItem(title: "Are you Receiving Dialysis?", type: .picker, dataType: .dialysis, value: profile.dialysis),
                ProfileDataItem(title: "Renal Disease Stage", type: .picker, dataType: .diseaseCategory, value: profile.diseaseCategory),
                ProfileDataItem(title: "Goal Setup", type: .picker, dataType: .setupGoals, value: profile.setupGoals),
                ComorbidConditionDataItem(title: "Comorbidities", type: .picker, dataType: .comorbidities, value: profile.comorbidities),
            ]
        }
        else {
            items = [
                ProfileDataItem(title: "Name", type: .text, dataType: .name),
                AgeProfileDataItem(title: "Date of Birth", type: .picker, dataType: .date),
                HeightProfileDataItem(title: "Height", type: .picker, dataType: .height),
                WeightProfileDataItem(title: "Current Weight", type: .picker, dataType: .currentWeight),
                ProfileDataItem(title: "Are you Receiving Dialysis?", type: .picker, dataType: .dialysis, value: false),
                ProfileDataItem(title: "Renal Disease Stage", type: .picker, dataType: .diseaseCategory),
                ProfileDataItem(title: "Goal Setup", type: .picker, dataType: .setupGoals, value: false),
                ProfileDataItem(title: "Avatar", type: .avatar, dataType: .avatar),
                ComorbidConditionDataItem(title: "Comorbidities", type: .picker, dataType: .comorbidities),
            ]
        }
        tableView.reloadData()
    }

    /// "Done" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func doneAction(_ sender: Any) {
        saveProfile()
    }

    /// Save profile
    private func saveProfile() {
        guard let userInfo = AuthenticationUtil.sharedInstance.userInfo else { return }

        let profile = self.profile ?? Profile(id: "")
        profile.birthday = items.filter({$0.dataType == .date}).first?.value as? Date
        profile.height = items.filter({$0.dataType == .height}).first?.value as? Double ?? -1
        profile.currentWeight = items.filter({$0.dataType == .currentWeight}).first?.value as? Double ?? -1
        profile.dialysis = items.filter({$0.dataType == .dialysis}).first?.value as? Bool ?? false
        profile.diseaseCategory = items.filter({$0.dataType == .diseaseCategory}).first?.value as? String ?? ""
        profile.setupGoals = items.filter({$0.dataType == .setupGoals}).first?.value as? Bool ?? false
        profile.image = profileImageView.image
        profile.addDevice = items.filter({$0.dataType == .devices}).first?.value as? Bool ?? false
        profile.comorbidities = items.filter({$0.dataType == .comorbidities}).first?.value as? [ComorbidCondition] ?? []

        if profile.name.isEmpty
            || profile.birthday == nil
            || profile.height < 0
            || profile.currentWeight < 0
            || profile.diseaseCategory.isEmpty {
            DispatchQueue.main.async {
                self.showAlert(NSLocalizedString("Fill the form", comment: "Fill the form"),
                               NSLocalizedString("Please fill all required fields", comment: "Please fill all required fields"))
            }
            return
        }

        let loadingView = OPTION_PROFILE_ADD_DONE_BUTTON ? showLoadingView() : nil
        if self.profile == nil {
            self.api.register(userInfo: userInfo, profile: profile, callback: { (_) in
                loadingView?.terminate()
                if OPTION_PROFILE_ADD_DONE_BUTTON {
                    self.dismiss(animated: true, completion: {
                        self.openHomeScreen()
                    })
                }
            }, failure: createGeneralFailureCallback(loadingView))
        }
        else {
            api.updateProfile(profile, callback: {
                loadingView?.terminate()
                if OPTION_PROFILE_ADD_DONE_BUTTON {
                    MainViewControllerReference?.openHomeTab()
                }
            }, failure: createGeneralFailureCallback(loadingView))
        }
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    /**
     The number of rows

     - parameter tableView: the tableView
     - parameter section:   the section index

     - returns: the number of items
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    /**
     Get cell for given indexPath

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath

     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        if item.dataType == .setupGoals {
            let cell = tableView.getCell(indexPath, ofClass: ProfileItemGoalsCell.self)
            cell.configureItem(item)
            return cell
        }
        else {
            let cell = tableView.getCell(indexPath, ofClass: ProfileItemCell.self)
            cell.configureItem(item)
            return cell
        }
    }

    /**
     Cell selection handler

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        let item = items[indexPath.row]
        var selected: String? = item.value as? String
        switch item.type {
        case .picker:
            var data = [String]()
            lastSelectedPickerType = item.dataType
            switch item.dataType {
            case .date:
                let maxDate = Calendar.current.date(byAdding: .year, value: -MIN_AGE, to: Date())
                DatePickerViewController.show(title: NSLocalizedString("Select Date of Birth", comment: "Select Date of Birth"),
                                              selectedDate: self.profile?.birthday,
                                              datePickerMode: .date,
                                              delegate: self, maxDate: maxDate)
                return
            case .height:
                PickerViewController.show(title: item.title, selected: HeightPickerValue(item.value as? Double ?? 162), data: Array(36...100).map{HeightPickerValue(Double($0))}, delegate: self)
                return
            case .currentWeight:
                if let cell = tableView.cellForRow(at: indexPath) as? ProfileItemCell {
                    cell.textField.text = Float(item.value as? Double ?? 75).toItemValueString()
                    cell.textField.delegate = self
                    cell.showTextInput(true)
                    cell.textField.becomeFirstResponder()
                }
                return
            case .dialysis, .devices:
                data = [YES, NO]
                selected = (item.value as? Bool ?? false) ? YES : NO
            case .diseaseCategory:
                data = DiseaseCategory.getAll().map({$0.rawValue})
            case .comorbidities:
                let items = ComorbidCondition.all.map{ComorbidConditionPickerValue($0)}
                let selected = (item.value as? [ComorbidCondition] ?? []).map{ComorbidConditionPickerValue($0)}
                CheckboxPickerViewController.show(title: item.title, selected: selected, data: items, delegate: self)
                return
            case .setupGoals:
                return
            default:
                showStub()
                return
            }
            PickerViewController.show(title: item.title, selected: PickerValue(selected), data: data.map{PickerValue($0)}, delegate: self)
            break
        case .avatar:
            break
        case .text:
            break
        }
    }

    // MARK: - PickerViewControllerDelegate

    /// Picker value updated
    ///
    /// - Parameters:
    ///   - value: the value
    ///   - picker: the picker
    func pickerValueUpdated(_ value: PickerValue, picker: PickerViewController) {
        if let item = items.filter({$0.dataType == lastSelectedPickerType}).first {
            if let value = value as? HeightPickerValue {
                item.value = value.height
            }
            else {
                if value.description == YES {
                    item.value = true
                }
                else if value.description == NO {
                    item.value = false
                }
                else if let int = Double(value.description) {
                    item.value = int
                }
                else {
                    item.value = value.string
                }
            }
            updateAfterChange()
        }
    }

    /// Update UI and save profile if needed after something changed
    private func updateAfterChange() {
        tableView.reloadData()
        if !OPTION_PROFILE_ADD_DONE_BUTTON {
            saveProfile()
        }
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
            if let item = items.filter({$0.dataType == .avatar}).first {
                item.value = image
            }
            updateAfterChange()
        }
    }

    /// method required by AddAssetButtonViewDelegate
    func addAssetButtonTapped(_ view: AddAssetButtonView) {
        profileImageView.addAssetButtonTapped(profileImageView)
    }

    // MARK: - DatePickerViewControllerDelegate

    /// Update birthday
    ///
    /// - Parameters:
    ///   - date: the date
    ///   - picker: the picker
    func datePickerDateSelected(_ date: Date, picker: DatePickerViewController) {
        items.filter({$0.dataType == .date}).first?.value = date
        birthDateLabel.text = DateFormatters.shortDate.string(from: date)
        updateAfterChange()
    }

    // MARK: - CheckboxPickerViewControllerDelegate

    /// Selection updated
    ///
    /// - Parameters:
    ///   - values: the values
    ///   - picker: the picker
    func checkboxValueUpdated(_ values: [PickerValue], picker: CheckboxPickerViewController) {
        items.filter({$0.dataType == .comorbidities}).first?.value = (values as? [ComorbidConditionPickerValue])?.map({$0.comorbidCondition})
        updateAfterChange()
    }

    // MARK: - UITextFieldDelegate

    /// Dismiss keyboard
    ///
    /// - Parameter sender: the button
    override func menuAction(_ sender: UIButton) {
        skipChanges = true
        self.view.endEditing(true)
        super.menuAction(sender)
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

    /// Update entered weight
    ///
    /// - Parameter textField: the textField
    func textFieldDidEndEditing(_ textField: UITextField) {
        let cell = textField.superview?.superview?.superview as? ProfileItemCell
        cell?.showTextInput(false)
        if let item = items.filter({$0.dataType == lastSelectedPickerType}).first {
            if let value = Double(textField.text ?? "") {
                if OPTION_LIMIT_WEIGHT_VALUES && (value < WEIGHT_LIMIT.0 || value > WEIGHT_LIMIT.1)  {

                    // Skip changes if incorrect value is entered
                    if skipChanges {
                        skipChanges = false
                        return
                    }
                    showAlert("Enter correct weight", "Please enter weight between \(Int(WEIGHT_LIMIT.0)) and \(Int(WEIGHT_LIMIT.1)) pounds.") {
                        DispatchQueue.main.async {
                            cell?.showTextInput(true)
                            textField.becomeFirstResponder()
                        }
                    }
                    return
                }
                else if value > 0 {
                    item.value = value
                }
            }
            updateAfterChange()
        }
    }
}

/**
 * Goals field cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileItemGoalsCell: ZeroMarginsCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var resetAllGoals: UIButton!

    /// the confirmation dialog
    private var confirmDialog: ConfirmDialog?

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.roundCorners(3)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        shadowView.addShadow(size: 3, shift: 2)
        if isIPhone5() {
            generateButton.setTitle(NSLocalizedString("Generate", comment: "Generate"), for: .normal)
            resetAllGoals.setTitle(NSLocalizedString("Reset All", comment: "Reset All"), for: .normal)
        }
    }

    /// Update UI
    ///
    /// - Parameter item: the item
    func configureItem(_ item: ProfileDataItem) {
        iconView.image = item.dataType.getIcon()
        titleLabel.text = item.title
        api.getGoals(profile: nil, callback: { list in
            self.resetAllGoals.alpha = list.isEmpty ? 0.5 : 1
            self.resetAllGoals.isUserInteractionEnabled = !list.isEmpty
        }, failure: { (error) in showError(errorMessage: error) })
    }

    /// "Generate Goals" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func generateGoalsAction(_ sender: Any) {
        self.api.generateGoals(profile: nil, callback: { (_) in

            // Open goals screen
            UIViewController.getCurrentViewController()?.openGoals()
            CurrentMenuItem = -1
        }, failure: { (error) in showError(errorMessage: error) })
    }

    /// "Reset All Goals" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func resetAllGoalAction(_ sender: Any) {
        confirmDialog = ConfirmDialog(title: NSLocalizedString("Reset All Goals?", comment: "Reset All Goals?"), text: NSLocalizedString("Are you sure you want to remove all goals?", comment: "Are you sure you want to remove all goals?"), action: {
            self.api.resetAllGoals(callback: {
                self.resetAllGoals.alpha = 0.5
                self.resetAllGoals.isUserInteractionEnabled = false
                if OPTION_MOVE_TO_GOALS_AFTER_RESET {
                    // Open goals screen
                    UIViewController.getCurrentViewController()?.openGoals()
                    CurrentMenuItem = -1
                }
            }, failure: { (error) in showError(errorMessage: error) })
        })
    }
}

/**
 * Name field cell
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - UI changes
 *
 * 1.2:
 * - text input added
 */
class ProfileItemCell: ZeroMarginsCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueEndingLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var textField: UITextField!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.roundCorners(3)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        shadowView.addShadow(size: 3, shift: 2)
        showTextInput(false)
    }

    /// Hide text field
    override func prepareForReuse() {
        super.prepareForReuse()
        showTextInput(false)
    }

    /// Update UI
    ///
    /// - Parameter item: the item
    func configureItem(_ item: ProfileDataItem) {
        iconView.image = item.dataType.getIcon()
        titleLabel.text = item.title

        switch item.dataType {
        case .height:
            valueEndingLabel.text = ""
        case .currentWeight:
            if item.getValue() == "1" {
                valueEndingLabel.text = NSLocalizedString("pound", comment: "pound")
            }
            else {
                valueEndingLabel.text = NSLocalizedString("pounds", comment: "pounds")
            }
        default:
            valueEndingLabel.text = ""
        }
        switch item.type {
        case .picker:
            self.valueLabel.text = item.getValue()
        case .avatar:
            self.valueLabel.text = (item.value as? UIImage != nil) ? "Yes" : "No"
        default:
            if let text = item.value as? String {
                self.valueLabel.text = text
            }
            else if let date = item.value as? Date {
                self.valueLabel.text = DateFormatters.shortDate.string(from: date)
            }
            else {
                self.valueLabel.text = ""
            }
        }

    }

    /// Show/hide text field
    ///
    /// - Parameter show: true - show, false - else
    func showTextInput(_ show: Bool) {
        textField.isHidden = !show
        valueLabel.isHidden = show
        valueEndingLabel.isHidden = show
    }
}
