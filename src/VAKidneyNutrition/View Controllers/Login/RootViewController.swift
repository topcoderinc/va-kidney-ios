//
//  RootViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/// the key used to store a flag that "Terms" are accepted
let kTermsAccepted = "kTermsAccepted"

/**
 * Root view controller
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RootViewController: UIViewController {

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        showSignIn(animated: false)
        DispatchQueue.main.async {
            if UserDefaults.standard.value(forKey: kTermsAccepted) as? Bool == true {
                if let userInfo = AuthenticationUtil.sharedInstance.userInfo {
                    if userInfo.isSetupCompleted {
                        self.openHomeScreen()
                    }
                    else { // Not completed sign up
                        self.openProfileScreen(animated: false, completion: nil)
                    }
                }
            }
            else {
                if let vc = self.create(TermsViewController.self) {
                    self.present(vc.wrapInNavigationController(), animated: true, completion: nil)
                }
            }
        }
    }

    /// Sign In
    ///
    /// - Parameter animated: the animated
    func showSignIn(animated: Bool) {
        if let vc = create(SignInViewController.self)?.wrapInNavigationController() {
            loadViewController(vc, self.view)
        }
    }
}
