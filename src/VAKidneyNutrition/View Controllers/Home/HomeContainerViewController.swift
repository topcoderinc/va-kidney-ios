//
//  HomeContainerViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Main view controller for Home screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HomeContainerViewController: UIViewController {

    /// outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageController: CustomUIPageControl!

    /// the current index
    private var currentIndex: Int = 0

    /// the last loaded view controller
    private var lastLoadedViewController: UIViewController?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrentView(currentIndex)
        setupNavigation()
    }

    /// Set current view
    ///
    /// - Parameters:
    ///   - index: the index
    ///   - transition: the animation transition
    private func setCurrentView(_ index: Int, transition: Transition? = nil) {
        self.currentIndex = index
        self.pageController.currentPage = index
        self.pageController.setNeedsLayout()
        var vc: UIViewController?
        switch index {
        case 0:
            vc = create(HomeDashboardViewController.self)
        case 1:
            vc = create(HomeSuggestionsViewController.self)
        case 2:
            vc = create(HomeReportsViewController.self)
        default:
            break
        }
        if let vc = vc {
            replaceFromSide(lastLoadedViewController, withViewController: vc, inContainer: self.containerView, side: transition, nil)
            lastLoadedViewController = vc
        }
    }

    // MARK: - Button/Swipe actions

    @IBAction func pageControllerAction(_ sender: Any) {
        let index = pageController.currentPage
        if index != currentIndex {
            setCurrentView(index, transition: index < currentIndex ? .left : .right)
        }
    }

    /// Swipe right action handler
    ///
    /// - parameter sender: the sender
    @IBAction func swipeRightAction(_ sender: Any) {
        if currentIndex > 0 {
            setCurrentView(currentIndex - 1, transition: .left)
        }
    }

    // MARK: - Button actions

    /// Swipe left action handler
    ///
    /// - parameter sender: the sender
    @IBAction func swipeLeftAction(_ sender: Any) {
        if currentIndex + 1 < 3 {
            setCurrentView(currentIndex + 1, transition: .right)
        }
    }
}
