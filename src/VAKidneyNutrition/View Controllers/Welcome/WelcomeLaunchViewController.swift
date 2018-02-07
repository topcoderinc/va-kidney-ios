//
//  WelcomeLaunchViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * First Welcome screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class WelcomeLaunchViewController: UIViewController {

    /// outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nextButton: CustomButton!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.darkBlue
        messageLabel.setLineSpacing(lineSpacing: 3.5)
        self.navigationController?.isNavigationBarHidden = true
    }

    /// Light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /// "Next" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func nextAction(_ sender: Any) {
        if let vc = create(WelcomeContainerViewController.self) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
