//
//  WelcomeContainerViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/// option: true - will fix minor design issues (colors, margings), false - else
let OPTION_FIX_DESIGN_ISSUES = false

/**
 * Welcome set of screens
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - iPhone 5 changes
 */
class WelcomeContainerViewController: UIViewController {

    /// outlets
    @IBOutlet weak var nextArrowButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageController: CustomUIPageControl!
    @IBOutlet weak var disagreeButton: CustomButton!
    @IBOutlet weak var agreeButton: CustomButton!
    @IBOutlet weak var rightMargin: NSLayoutConstraint!

    /// the view controllers to show
    var pageControllers = [UIViewController]()

    /// the current index
    private var currentIndex: Int = 0

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.masksToBounds = true
        pageController.isUserInteractionEnabled = false
        nextArrowButton.makeRound()
        loadData()
        if isIPhone5() {
            rightMargin.constant = 10
        }
    }

    /// Load data
    private func loadData() {
        var pages = [UIViewController]()
        if let vc = create(WelcomePage1ViewController.self) { pages.append(vc) }
        if let vc = create(WelcomePage2ViewController.self) { pages.append(vc) }
        if let vc = create(WelcomePage3ViewController.self) { pages.append(vc) }
        for page in pages {
            if let vc = create(WelcomePageContainerViewController.self) {
                vc.vc = page
                pageControllers.append(vc)
                loadViewController(vc, containerView)
            }
        }
        updateUI()
    }

    /// Update UI
    private func updateUI(animation: Bool = true) {
        pageController.currentPage = currentIndex
        pageController.setNeedsLayout()
        let n = pageControllers.count
        pageController.numberOfPages = n
        if animation {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
                self.layoutPages()
            }, completion: nil)
        }
        else {
            layoutPages()
        }
        agreeButton.isHidden = currentIndex != n - 1
        disagreeButton.isHidden = currentIndex != n - 1
        nextArrowButton.isHidden = currentIndex == n - 1
    }

    /// Layout pages
    private func layoutPages() {
        var i = 0
        let scale: CGFloat = 668/961 // as in design
        let shift: CGFloat = self.view.bounds.width * 1.05
        for vc in pageControllers {
            vc.view.isHidden = false
            if i == currentIndex - 1 {
                vc.view.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale).translatedBy(x: -shift, y: 0)
            }
            else if i == currentIndex {
                vc.view.transform = CGAffineTransform.identity
                self.containerView.bringSubview(toFront: vc.view)
            }
            else if i == currentIndex + 1 {
                vc.view.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale).translatedBy(x: shift, y: 0)
            }
            else {
                vc.view.isHidden = true
            }
            i += 1
        }
    }

    /// Swipe right action handler
    ///
    /// - parameter sender: the sender
    @IBAction func swipeRightAction(_ sender: Any) {
        if currentIndex > 0 {
            currentIndex -= 1
            updateUI()
        }
    }

    // MARK: - Button actions

    /// "Next" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func nextArrowButtonAction(_ sender: Any) {
        if currentIndex + 1 < pageControllers.count {
            currentIndex += 1
            updateUI()
        }
    }

    /// "I disagree" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func disagreeAction(_ sender: Any) {
        let title = NSLocalizedString("You should agree", comment: "You should agree")
        let message = NSLocalizedString("Click YES to exit or click NO to continue using the app", comment: "Click YES to exit or click NO to continue using the app")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default,
                                         handler: { (_) -> Void in
                                            DispatchQueue.main.async {
                                                self.navigationController?.popViewController(animated: true)
                                            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    /// "I agree" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func agreeAction(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: kTermsAccepted)
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }

}
