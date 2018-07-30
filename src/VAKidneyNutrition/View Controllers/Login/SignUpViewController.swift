//
//  SignUpViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Sign Up screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SignUpViewController: UIViewController, UITextFieldDelegate {

    /// outlets
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var passwordField: CustomTextField!
    @IBOutlet weak var confirmPasswordField: CustomTextField!
    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet weak var loginErrorLabel: UILabel!
    @IBOutlet weak var loginButtonMargin: NSLayoutConstraint!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordBottomMargin: NSLayoutConstraint!
    
    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoginError(nil)
        showPasswordError(nil)
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
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Button actions

    /// "Sign Up" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func signUpAction(_ sender: Any) {
        self.view.endEditing(true)
        showLoginError(nil)
        showPasswordError(nil)
        let loadingView = showLoadingView()

        // Validate the entered data
        api.checkIfAccountCanBeCreated(email: emailField.text ?? "",
                                       password: passwordField.text ?? "", confirmPassword: confirmPasswordField.text ?? "",
                                       callback: { userInfo in
                                        AuthenticationUtil.sharedInstance.userInfo = userInfo

                                        loadingView?.terminate()
                                        self.dismiss(animated: false, completion: {
                                            self.openProfileScreen(animated: false, completion: {
                                                self.emailField.text = ""
                                                self.passwordField.text = ""
                                                self.confirmPasswordField.text = ""
                                            })
                                        })
                                        
        }, failure: { error in
            loadingView?.terminate()
            UIView.animate(withDuration: 0.3) {
                self.showLoginError(error)
                self.view.layoutIfNeeded()
            }
        })
    }

    /// Show login error
    ///
    /// - Parameter error: the error
    private func showLoginError(_ error: String?) {
        self.emailField.borderWidth = error == nil ? 0 : 1
        self.loginErrorLabel.isHidden = error == nil
        self.loginButtonMargin.constant = error == nil ? 18 : 30.5
        if let error = error {
            self.loginErrorLabel.text = error
        }
    }
    
    /// Show password error
    ///
    /// - Parameter error: the error
    private func showPasswordError(_ error: String?) {
        self.passwordField.borderWidth = error == nil ? 0 : 1
        self.passwordErrorLabel.isHidden = error == nil
        self.passwordBottomMargin.constant = error == nil ? 18 : 30.5
        if let error = error {
            self.passwordErrorLabel.text = error
        }
    }
}
