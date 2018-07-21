//
//  RootViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2017 Topcoder. All rights reserved.
//

import UIKit

/// the key used to store a flag that "Terms" are accepted
let kTermsAccepted = "kTermsAccepted"

/**
 * Root view controller
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - changes in navigation
 */
class RootViewController: UIViewController {

    /// the loaded view controller
    private var signInViewController: SignInViewController?
    
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
                else {
                    self.signInViewController?.tryLoginWithTouchID()
                }
            }
            else {
                if let vc = self.create(WelcomeLaunchViewController.self) {
                    self.present(vc.wrapInNavigationController(), animated: false, completion: nil)
                }
            }
        }
    }

    /// Light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /// Sign In
    ///
    /// - Parameter animated: the animated
    func showSignIn(animated: Bool) {
        if let vc = create(SignInViewController.self) {
            self.signInViewController = vc
            loadViewController(vc, self.view)
        }
    }
}
