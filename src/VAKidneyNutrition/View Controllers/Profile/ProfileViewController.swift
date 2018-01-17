//
//  ProfileViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/// Possible types of profile data
enum ProfileDataType {
    case name, age, height, currentWeight, dialysis, diseaseCategory, setupGoals, avatar, devices
}

/// Possible types of profile items
enum ProfilePickerType {
    case text, picker, avatar, devices
}

/// boolean labels
let YES = NSLocalizedString("Yes", comment: "Yes")
let NO = NSLocalizedString("No", comment: "No")

/// The profile item
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
        if let value = value as? Int {
            return "\(value) " + NSLocalizedString("cm", comment: "cm")
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
        if let value = value as? Int {
            return "\(value) " + NSLocalizedString("kg", comment: "kg")
        }
        return super.getValue()
    }
}

/**
 * Profile screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PickerViewControllerDelegate, AddAssetButtonViewDelegate {

    /// outlets
    @IBOutlet weak var tableView: UITableView!

    /// the items to show
    private var items = [ProfileDataItem]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// last picker type
    private var lastSelectedPickerType: ProfileDataType?

    /// the utility used to take image
    private var imageUtil = AddAssetButtonView()

    /// the profile to show
    var profile: Profile?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentOffset.y = -tableView.contentInset.top
        if profile == nil {
            navigationItem.leftBarButtonItem = nil
        }
        else {
            setupNavigation()
            let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
            self.navigationItem.rightBarButtonItem = item
        }
        loadData()
    }

    /// Load data
    private func loadData() {
        if let profile = profile {
            items = [
                ProfileDataItem(title: "Name", type: .text, dataType: .name, value: profile.name),
                AgeProfileDataItem(title: "Age", type: .picker, dataType: .age, value: profile.age),
                HeightProfileDataItem(title: "Height", type: .picker, dataType: .height, value: profile.height),
                WeightProfileDataItem(title: "Current Weight", type: .picker, dataType: .currentWeight, value: profile.currentWeight),
                ProfileDataItem(title: "Are you on Dialysis?", type: .picker, dataType: .dialysis, value: profile.dialysis),
                ProfileDataItem(title: "Disease Category", type: .picker, dataType: .diseaseCategory, value: profile.diseaseCategory),
                ProfileDataItem(title: "Want to setup goals", type: .picker, dataType: .setupGoals, value: profile.setupGoals),
                ProfileDataItem(title: "Avatar", type: .avatar, dataType: .avatar, value: profile.image),
                ProfileDataItem(title: "Add Biometric Devices", type: .devices, dataType: .devices),
            ]
        }
        else {
            items = [
                ProfileDataItem(title: "Name", type: .text, dataType: .name),
                AgeProfileDataItem(title: "Age", type: .picker, dataType: .age),
                HeightProfileDataItem(title: "Height", type: .picker, dataType: .height),
                WeightProfileDataItem(title: "Current Weight", type: .picker, dataType: .currentWeight),
                ProfileDataItem(title: "Are you on Dialysis?", type: .picker, dataType: .dialysis, value: false),
                ProfileDataItem(title: "Disease Category", type: .picker, dataType: .diseaseCategory),
                ProfileDataItem(title: "Want to setup goals", type: .picker, dataType: .setupGoals, value: false),
                ProfileDataItem(title: "Avatar", type: .avatar, dataType: .avatar),
                ProfileDataItem(title: "Add Biometric Devices", type: .devices, dataType: .devices),
            ]
        }
        tableView.reloadData()
    }

    /// "Done" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func doneAction(_ sender: Any) {
        guard let userInfo = AuthenticationUtil.sharedInstance.userInfo else { return }

        let profile = self.profile ?? Profile(id: "")
        profile.name = (tableView?.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileNameCell)?.nameField.text ?? ""
        profile.age = items.filter({$0.dataType == .age}).first?.value as? Int ?? -1
        profile.height = items.filter({$0.dataType == .height}).first?.value as? Int ?? -1
        profile.currentWeight = items.filter({$0.dataType == .currentWeight}).first?.value as? Int ?? -1
        profile.dialysis = items.filter({$0.dataType == .dialysis}).first?.value as? Bool ?? false
        profile.diseaseCategory = items.filter({$0.dataType == .diseaseCategory}).first?.value as? String ?? ""
        profile.setupGoals = items.filter({$0.dataType == .setupGoals}).first?.value as? Bool ?? false
        profile.image = items.filter({$0.dataType == .avatar}).first?.value as? UIImage

        if profile.name.isEmpty
            || profile.age < 0
            || profile.height < 0
            || profile.currentWeight < 0
            || profile.diseaseCategory.isEmpty {
            DispatchQueue.main.async {
                self.showAlert(NSLocalizedString("Fill the form", comment: "Fill the form"),
                               NSLocalizedString("Please fill all required fields", comment: "Please fill all required fields"))
            }
            return
        }

        let loadingView = showLoadingView()
        if self.profile == nil {
            self.api.register(userInfo: userInfo, profile: profile, callback: { (_) in
                loadingView?.terminate()
                self.dismiss(animated: true, completion: {
                    self.openHomeScreen()
                })
            }, failure: createGeneralFailureCallback(loadingView))
        }
        else {
            api.updateProfile(profile, callback: {
                loadingView?.terminate()
                MainViewControllerReference?.openHomeTab()
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
        switch item.type {
        case .picker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subtitle", for: indexPath)
            cell.configure(item)
            return cell
        case .avatar:
            let cell = tableView.getCell(indexPath, ofClass: AvatarTableViewCell.self)
            cell.configureWithImage(item)
            return cell
        case .devices:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
            cell.configure(item)
            return cell
        case .text:
            let cell = tableView.getCell(indexPath, ofClass: ProfileNameCell.self)
            cell.configureText(item)
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
        let item = items[indexPath.row]
        var selected: String? = item.value as? String
        switch item.type {
        case .picker:
            var data = [String]()
            lastSelectedPickerType = item.dataType
            switch item.dataType {
            case .age:
                data = Array(0...100).map{"\($0)"}
                selected = "\(item.value ?? 52)"
            case .height:
                data = Array(30...220).map{"\($0)"}
                selected = "\(item.value ?? 162)"
            case .currentWeight:
                data = Array(20...200).map{"\($0)"}
                selected = "\(item.value ?? 75)"
            case .dialysis, .setupGoals:
                data = [YES, NO]
                selected = (item.value as? Bool ?? false) ? YES : NO
            case .diseaseCategory:
                // TODO lookup
                data = ["ESRD", "ABCD"]
            default:
                showStub()
                return
            }
            PickerViewController.show(title: item.title, selected: selected, data: data, delegate: self)
            break
        case .avatar:
            imageUtil.delegate = self
            imageUtil.addAssetButtonTapped(imageUtil)
        case .devices:
            showStub()
        case .text:
            break
        }
    }

    // MARK: - PickerViewControllerDelegate

    func pickerValueUpdated(_ value: String, picker: PickerViewController) {
        if let item = items.filter({$0.dataType == lastSelectedPickerType}).first {
            if value == YES {
                item.value = true
            }
            else if value == NO {
                item.value = false
            }
            else if let int = Int(value) {
                item.value = int
            }
            else {
                item.value = value
            }
            tableView.reloadData()
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
            tableView.reloadData()
        }
    }

    /// method required by AddAssetButtonViewDelegate
    func addAssetButtonTapped(_ view: AddAssetButtonView) {
        // nothing to do
    }
}

/**
 * Table cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UITableViewCell {

    /// Update UI
    ///
    /// - Parameter item: the item
    func configure(_ item: ProfileDataItem) {
        textLabel?.text = item.title
        switch item.type {
        case .picker:
            detailTextLabel?.text = item.getValue()
        default:
            break
        }
    }
}

/**
 * Avatar cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class AvatarTableViewCell: UITableViewCell {

    /// the image
    private var customImage: UIImageView!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        let width: CGFloat = 44
        let x = UIScreen.main.bounds.width / 4 * 3
        customImage = UIImageView(frame: CGRect(x: x, y: 0, width: width, height: width))
        self.addSubview(customImage)
    }

    /// Update UI
    ///
    /// - Parameter item: the item
    func configureWithImage(_ item: ProfileDataItem) {
        configure(item)
        if let image = item.value as? UIImage {
            self.customImage.image = image
        }
    }
}

/**
 * Name field cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileNameCell: UITableViewCell {

    /// the image
    @IBOutlet weak var nameField: UITextField!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// Update UI
    ///
    /// - Parameter item: the item
    func configureText(_ item: ProfileDataItem) {
        if let text = item.value as? String {
            self.nameField.text = text
        }
    }
}
