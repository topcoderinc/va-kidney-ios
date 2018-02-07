//
//  WelcomePage3ViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Welcome screen #3
 *
 * - author: TCCODER
 * - version: 1.0
 */
class WelcomePage3ViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomMargin.constant = OPTION_FIX_DESIGN_ISSUES ? 15 : 39 // as in design
    }

    /// Fix UITextView issue
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.contentOffset.y = 0
    }
}
