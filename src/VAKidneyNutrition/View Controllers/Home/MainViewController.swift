//
//  MainViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

var MainViewControllerReference: MainViewController?

/**
 * Main view controller containing tab buttons
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MainViewController: UIViewController {

    /// outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var tabButtons: [CustomTabButton]!

    /// the last selected tab index
    private var lastSelectedTabIndex: Int = -1

    /// the last loaded view controller
    private var lastLoadedViewController: UIViewController?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        MainViewControllerReference = self
        tabButtonAction(tabButtons.filter({$0.tag == 0}).first!)
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
            if let vc = create(MedicationsMainViewController.self, storyboardName: "Medications")?.wrapInNavigationController() {
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
        for button in tabButtons {
            button.isSelected = index == button.tag
        }
    }

    /// Open Home tab
    func openHomeTab() {
        if let vc = create(HomeViewController.self, storyboardName: "Home")?.wrapInNavigationController() {
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
        if let vc = createInitialViewController(fromStoryboard: "Charts") as? ChartsViewController {
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
