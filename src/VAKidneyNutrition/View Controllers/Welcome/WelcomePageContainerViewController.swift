//
//  WelcomePageContainerViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Welcome set of screens
 *
 * - author: TCCODER
 * - version: 1.0
 */
class WelcomePageContainerViewController: UIViewController {

    /// outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!

    /// the view controller to show
    var vc: UIViewController!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        shadowView.addShadow(size: 11, shift: 1.5, opacity: 0.2)
        containerView.roundCorners(5.5)
        self.view.backgroundColor = UIColor.clear
        loadViewController(vc, containerView)
    }

}
