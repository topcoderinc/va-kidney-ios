//
//  SignInViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Sign In screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SignInViewController: UIViewController, UITextFieldDelegate {

    /// outlets
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: CustomButton!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signUpButton: CustomButton!

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        forgotPasswordLabel.addUnderline()
        self.view.backgroundColor = UIColor.clear
    }

    /// View did appear
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cleanNavigationStack()
    }

    /// "Login" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func loginAction(_ sender: Any) {
        self.view.endEditing(true)
        let loadingView = LoadingView(parentView: self.view).show()

        api.authenticate(email: emailField.text ?? "", password: passwordField.text ?? "",
                         callback: { _ in
                            self.openHomeScreen() {
                                self.emailField.text = ""
                                self.passwordField.text = ""
                                loadingView.terminate()
                            }
        }, failure: createGeneralFailureCallback(loadingView))
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
        pushViewController(SignUpViewController.self)
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
}
