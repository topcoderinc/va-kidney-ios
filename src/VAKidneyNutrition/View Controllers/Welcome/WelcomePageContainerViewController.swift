//
//  WelcomePageContainerViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

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
class WelcomePageContainerViewController: UIViewController {

    /// outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!

    /// the view controller to show
    var vc: UIViewController!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        shadowView.addShadow(size: 11, shift: 1.5, opacity: 0.2)
        containerView.roundCorners(5.5)
        self.view.backgroundColor = UIColor.clear
        loadViewController(vc, containerView)
        if isIPhone5() {
            topMargin.constant = 40
            bottomMargin.constant = 70
        }
    }

}
