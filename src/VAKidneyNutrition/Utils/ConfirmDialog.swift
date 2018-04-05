//
//  ConfirmDialog.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/28/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Provides easy API for Confirmation Dialog.
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ConfirmDialog: NSObject {

    /// optional block to invoke when user cancels the confirmation
    var cancelled: (()->())?

    /// Open Confirmation dialog with given title, text and action.
    ///
    /// - parameter title:         the dialog title
    /// - parameter text:          the message to show
    /// - parameter action:        action block
    /// - parameter okButtonTitle: optional "OK" button title
    ///
    /// - returns: ConfirmDialog instance that must be saved in a variable
    @discardableResult
    init(title: String, text:  String, action: @escaping ()->(), _ okButtonTitle: String = "Yes") {
        super.init()

        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertActionStyle.default,
                                      handler: { (_) -> Void in
                                        alert.dismiss(animated: true, completion: nil)
                                        DispatchQueue.main.async {
                                            action()
                                        }
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
            alert.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                self.cancelled?()
            }
        }))

        DispatchQueue.main.async {
            UIViewController.getCurrentViewController()?.present(alert, animated: true, completion: nil)
        }
    }

    /// Save as previous init method, but this takes cancel callback block
    ///
    /// - parameter title:     the dialog title
    /// - parameter text:      the message to show
    /// - parameter cancelled: cancel callback block
    /// - parameter action:    action block
    ///
    /// - returns: ConfirmDialog instance that must be saved in a variable
    convenience init(title: String, text:  String, cancelled: @escaping ()->(), action: @escaping ()->()) {
        self.init(title: title, text: text, action: action)
        self.cancelled = cancelled
    }
}

