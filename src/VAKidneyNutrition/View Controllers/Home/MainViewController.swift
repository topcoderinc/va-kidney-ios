//
//  MainViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

var MainViewControllerReference: MainViewController?

/**
 * Main view controller containing tab buttons
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - UI changes
 *
 * 1.2:
 * - new charts UI
 */
class MainViewController: UIViewController {

    /// outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var tabButtons: [CustomTabButton]!
    @IBOutlet var tabTitles: [UILabel]!
    @IBOutlet weak var tabButtonsView: UIView!
    @IBOutlet weak var activeTabMarkerLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var activeTabMarkerView: UIView!

    /// the last selected tab index
    private var lastSelectedTabIndex: Int = -1

    /// the last loaded view controller
    private var lastLoadedViewController: UIViewController?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        MainViewControllerReference = self
        self.view.backgroundColor = Colors.darkBlue
        tabButtonAction(tabButtons.filter({$0.tag == 0}).first!) // set to 0
        tabButtonsView.addShadow(size: 3, shift: 0, opacity: 0.4)
        tabButtonsView.backgroundColor = Colors.darkBlue
    }

    /// Light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Tab button action handler
    ///
    /// - parameter sender: the button
    @IBAction func tabButtonAction(_ sender: UIButton) {
        // UNCOMMENT when navigation will be completed (there will be back buttons instead of menu)
        // guard lastSelectedTabIndex != sender.tag else { return }
        setSelectedTab(index: sender.tag)

        lastLoadedViewController?.removeFromParent()

        switch sender.tag {
        case 0: // home
            openHomeTab()
        case 1:
            openCharts()
        case 2:
            if let vc = create(MedicationsTableViewController.self, storyboardName: "Medications")?.wrapInNavigationController() {
                lastLoadedViewController = vc
                self.loadViewController(vc, self.containerView)
            }
        case 3:
            if let vc = create(FoodIntakeViewController.self, storyboardName: "Food")?.wrapInNavigationController() {
                lastLoadedViewController = vc
                self.loadViewController(vc, self.containerView)
            }
        case 4:
            if let vc = create(DailyWorkoutViewController.self, storyboardName: "Workout")?.wrapInNavigationController() {
                lastLoadedViewController = vc
                self.loadViewController(vc, self.containerView)
            }
        default:
            break
        }
    }

    /// Set selected tab
    ///
    /// - Parameter index: the index
    func setSelectedTab(index: Int) {
        lastSelectedTabIndex = index
        activeTabMarkerView.isHidden = true
        for button in tabButtons {
            button.isSelected = index == button.tag
            button.tintColor = (index == button.tag) ? UIColor.white : Colors.blue
            if button.isSelected {
                CurrentMenuItem = -1
                activeTabMarkerView.isHidden = false
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.beginFromCurrentState, .curveEaseOut], animations: {
                    self.activeTabMarkerLeftMargin.constant = button.frame.origin.x + button.bounds.width / 2 - self.activeTabMarkerView.bounds.width / 2
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
        for label in tabTitles {
            label.textColor = (index == label.tag) ? UIColor.white : Colors.blue
        }
    }

    /// Open Home tab
    func openHomeTab() {
        if let vc = create(HomeContainerViewController.self, storyboardName: "Home")?.wrapInNavigationController() {
            lastLoadedViewController = vc
            self.loadViewController(vc, self.containerView)
        }
    }

    /// Open Charts screen with given report
    ///
    /// - Parameter report: the report to show when opened
    func openCharts(report: Report? = nil) {
        if let _ = report {
            setSelectedTab(index: 1)
            lastLoadedViewController?.removeFromParent()
        }
        if let vc = createInitialViewController(fromStoryboard: "Charts") as? ChartsTableViewController {
            vc.report = report
            let nav = vc.wrapInNavigationController()
            lastLoadedViewController = nav
            self.loadViewController(nav, self.containerView)
        }
    }

    /// Show view controller
    ///
    /// - Parameter viewController: the view controller
    func showViewController(_ viewController: UIViewController) {
        setSelectedTab(index: -1)
        lastLoadedViewController?.removeFromParent()
        lastLoadedViewController = viewController
        self.loadViewController(viewController, self.containerView)
    }

    /// "Home" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func homeAction(_ sender: UIButton) {
        tabButtonAction(sender)
    }

    /// "Charts" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func chartsAction(_ sender: UIButton) {
        tabButtonAction(sender)
    }

    /// "Medications" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func medicationsAction(_ sender: UIButton) {
        tabButtonAction(sender)
    }

    /// "Food" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func foodIntakeAction(_ sender: UIButton) {
        tabButtonAction(sender)
    }

    /// "Workout" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func workoutAction(_ sender: UIButton) {
        tabButtonAction(sender)
    }
}
