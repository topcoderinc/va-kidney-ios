//
//  MenuViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/3/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/// current opened menu item
var CurrentMenuItem: Int = -1

/**
 * Menu screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// outlets
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    /// the items to show
    private var items = [ContextItem]()

    /// Show menu
    ///
    /// - Parameter completion: the completion callback
    class func show(completion: ((Bool)->())? = nil) {
        if let parent = UIViewController.getCurrentViewController(),
            let vc = parent.create(MenuViewController.self, storyboardName: "Home") {
            parent.loadViewController(vc, parent.view)
            vc.view.frame.origin.x = -UIScreen.main.bounds.width
            UIView.animate(withDuration: 0.3, animations: {
                vc.view.frame.origin.x = 0
            }, completion: completion)
        }
    }

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentOffset.y = -tableView.contentInset.top
        loadData()
    }

    /// Load data
    private func loadData() {
        items = [ContextItem(title: NSLocalizedString("My Health Profile", comment: "My Health Profile")) {
            if let vc = self.create(ProfileViewController.self, storyboardName: "Profile") {
                CachingServiceApi.shared.getProfile(callback: { (profile) in
                    vc.profile = profile
                    MainViewControllerReference?.showViewController(vc.wrapInNavigationController())
                }, failure: self.createGeneralFailureCallback())
            }
        },
        ContextItem(title: NSLocalizedString("Resources Library", comment: "Resources Library"), action: {
            if let vc = self.create(ResourcesTableViewController.self, storyboardName: "Resources") {
                MainViewControllerReference?.showViewController(vc.wrapInNavigationController())
            }
        }),
        ContextItem(title: NSLocalizedString("My Biometric Device", comment: "My Biometric Device"), action: nil),
        ContextItem(title: NSLocalizedString("Avatar", comment: "Avatar"), action: nil)]
        tableView.reloadData()

        if let userInfo = AuthenticationUtil.sharedInstance.userInfo {
            self.userNameLabel.text = userInfo.fullName
        }
        else {
            self.userNameLabel.text = ""
        }
    }

    // MARK: - Button actions

    /// Overlay button action handler
    ///
    /// - parameter sender: the button
    @IBAction func overlayButtonAction(_ sender: Any) {
        closeMenu()
    }

    /// Swipe left action handler
    ///
    /// - parameter sender: the sender
    @IBAction func swipeLeft(_ sender: Any) {
        closeMenu()
    }

    /// Close menu
    private func closeMenu() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame.origin.x = -UIScreen.main.bounds.width
            }, completion: { _ in
                self.removeFromParent()
            })
        }
    }
    /// "Settings" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func settingsAction(_ sender: Any) {
        showStub()
    }

    /// "Reminders" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func remindersAction(_ sender: Any) {
        showStub()
    }

    /// "Logout" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func logoutAction(_ sender: Any) {
        AuthenticationUtil.sharedInstance.cleanUp()
        UIViewController.getCurrentViewController()?.dismiss(animated: true, completion: nil)
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
        let cell = tableView.getCell(indexPath, ofClass: MenuItemCell.self)
        let item = items[indexPath.row]
        cell.configure(item, isSelected: CurrentMenuItem == indexPath.row, icon: UIImage(named: "menu\(indexPath.row + 1)") ?? UIImage())
        return cell
    }

    /**
     Cell selection handler

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        if let action = item.action {
            action()
            closeMenu()
            CurrentMenuItem = indexPath.row
        }
        else {
            showStub()
        }
    }
}

/**
 * Cell for menu
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MenuItemCell: ZeroMarginsCell {

    /// outlets
    @IBOutlet weak var imageActive: UIImageView!
    @IBOutlet weak var imageInactive: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var line: UIView!

    /// Update UI with given data
    ///
    /// - Parameters:
    ///   - item: the data to show in the cell
    ///   - isSelected: true - if selected, false - else
    ///   - icon: the icon to show
    func configure(_ item: ContextItem, isSelected: Bool, icon: UIImage) {
        button.setTitle(item.title, for: .selected)
        imageActive.isHidden = !isSelected
        imageInactive.isHidden = isSelected
        imageActive.image = icon
        imageInactive.image = icon
        line.backgroundColor = isSelected ? Colors.blue : UIColor(r: 221, g: 221, b: 221)
        button.isSelected = isSelected
        button.setTitle(item.title, for: .normal)
        button.setTitle(item.title, for: .selected)
    }
}
