//
//  TermsViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit



/**
 * Terms Of Service And Liability Release
 *
 * - author: TCCODER
 * - version: 1.0
 */
class TermsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var textView: UITextView!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
    }

    /// View will appear
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    /// View did appear
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.contentOffset.y = 0
    }

    /// "Disagree" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func disagreeAction(_ sender: Any) {
        showAlert("You should agree", "You should agree with Terms Of Service And Liability Release to proceed.")
    }

    /// "Agree" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func agreeAction(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: kTermsAccepted)
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
}
