//
//  SignInViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIComponents

/// option: true - disable "Login" button if fiels are empty, false - else
let OPTION_DISABLE_LOGIN_IF_EMPTY_FIELDS = true

/// option: true - wrap login errors and replace with special messages, false - else
let OPTION_WRAP_LOGIN_ERRORS = false

/**
 * Sign In screen
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - UI changes
 * 1.2:
 * - font size related changes
 */
class SignInViewController: UIViewController, UITextFieldDelegate {

    /// outlets
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var passwordField: CustomTextField!
    @IBOutlet weak var loginButton: CustomButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signUpButton: CustomButton!
    @IBOutlet weak var loginButtonMargin: NSLayoutConstraint!
    @IBOutlet weak var loginErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordBottomMargin: NSLayoutConstraint!

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        updateLoginButtonState()
        self.view.layoutIfNeeded()
        showLoginError(nil)
        showPasswordError(nil)
    }

    /// View did appear
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cleanNavigationStack()
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
        self.passwordBottomMargin.constant = error == nil ? 56.5 : 74
        if let error = error {
            self.passwordErrorLabel.text = error
        }
    }

    /// "Login" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func loginAction(_ sender: Any) {
        self.view.endEditing(true)
        showLoginError(nil)
        showPasswordError(nil)
        self.view.layoutIfNeeded()
        let loadingView = LoadingView(parentView: self.view).show()

        api.authenticate(email: emailField.text ?? "", password: passwordField.text ?? "",
                         callback: { _ in
                            self.openHomeScreen() {
                                self.emailField.text = ""
                                self.passwordField.text = ""
                                loadingView.terminate()
                            }
        }, failure: { error1, error2 in
            loadingView.terminate()
            var error1 = error1
            var error2 = error2
            if OPTION_WRAP_LOGIN_ERRORS {
                if let _ = error1 {
                    error1 = NSLocalizedString("*Please re enter email address", comment: "*Please re enter email address")
                }
                if error2 == ERROR_WRONG_CREDENTIALS || error2 == ERROR_EMPTY_CREDENTIALS {
                    error2 = NSLocalizedString("Please re enter password", comment: "Please re enter password")
                }
                if let error = error2 {
                    error2 = "*\(error)"
                }
            }
            UIView.animate(withDuration: 0.3) {
                self.showLoginError(error1)
                self.showPasswordError(error2)
                self.view.layoutIfNeeded()
            }
        })
    }

    /// "Forgot password?" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func forgotPasswordAction(_ sender: Any) {
        showForgotPasswordFormPopup { (email) in
            let loadingView = LoadingView(parentView: self.view).show()
            self.api.forgotPassword(email: email, callback: {
                loadingView.terminate()

                self.showAlert( NSLocalizedString("Check Email", comment: "Check Email"),
                    NSLocalizedString("Please continue by tapping on the link sent to your email.", comment: "Please continue by tapping on the link sent to your email."))
            }, failure: { error in
                if error == ERROR_STUB {
                    showStub()
                }
                else {
                    showError(errorMessage: error)
                }
                loadingView.terminate()
            })
        }
    }

    /// "Sign Up" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func signUpAction(_ sender: Any) {
        showStub()
    }

    /// Show popup with text field to enter email
    ///
    /// - Parameter callback: the callback to return an email
    private func showForgotPasswordFormPopup(callback: @escaping (String)->()) {
        let alert = UIAlertController(
            title: NSLocalizedString("Forgot password", comment: "Forgot password"),
            message: NSLocalizedString("Enter your email used during registration", comment: "Enter your email used during registration"), preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields?[0]
            callback((textField?.text ?? "").trim())
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
            passwordField.resignFirstResponder()
            loginAction(self)
        }
        return true
    }

    /// Enable/disable Login button
    ///
    /// - Parameters:
    ///   - textField: the textField
    ///   - range: the range
    ///   - string: the string
    /// - Returns: true
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text ?? ""
        text.replaceSubrange(range.toRange(string: text), with: string)
        updateLoginButtonState(field: textField, text: text)
        return true
    }

    /// Update Login button state
    ///
    /// - Parameters:
    ///   - field: one of the fields
    ///   - text: the text
    private func updateLoginButtonState(field: UITextField? = nil, text: String? = nil) {
        let email = (field == emailField ? text ?? "" : emailField.text) ?? ""
        let password = (field == passwordField ? text ?? "" : passwordField.text) ?? ""
        if OPTION_DISABLE_LOGIN_IF_EMPTY_FIELDS {
            loginButton.isEnabled = !email.trim().isEmpty && !password.isEmpty
        }
    }
}


