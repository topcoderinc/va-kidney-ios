//
//  SignUpViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Sign Up screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SignUpViewController: UIViewController, UITextFieldDelegate {

    /// outlets
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
    }

    /// View did appear
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cleanNavigationStack()
    }

    /// Dismiss keyboard
    ///
    /// - Parameters:
    ///   - touches: the touches
    ///   - event: the event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    // MARK: - UITextFieldDelegate

    /// Switch to next field if "Next" button is tapped
    ///
    /// - Parameter textField: the text field
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        }
        else if textField == confirmPasswordField {
            confirmPasswordField.resignFirstResponder()
            signUpAction(self)
        }
        return true
    }

    /// Sing In link action
    ///
    /// - parameter sender: the sender
    @IBAction func signInLinkAction(_ sender: Any) {
        pushViewController(SignInViewController.self)
    }

    // MARK: - Button actions

    /// "Sign Up" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func signUpAction(_ sender: Any) {
        self.view.endEditing(true)
        let loadingView = showLoadingView()

        // Validate the entered data
        api.checkIfAccountCanBeCreated(email: emailField.text ?? "",
                                       password: passwordField.text ?? "", confirmPassword: confirmPasswordField.text ?? "",
                                       callback: { userInfo in
                                        AuthenticationUtil.sharedInstance.userInfo = userInfo

                                        loadingView?.terminate()
                                        self.openProfileScreen(completion: {
                                            self.emailField.text = ""
                                            self.passwordField.text = ""
                                            self.confirmPasswordField.text = ""
                                        })
        }, failure: createGeneralFailureCallback(loadingView))
    }

}
