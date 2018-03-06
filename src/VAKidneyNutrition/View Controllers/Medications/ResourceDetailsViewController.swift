//
//  ResourceDetailsViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/4/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Resource details
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - integration changes
 */
class ResourceDetailsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var relatedInfoLabel: UILabel!

    /// the
    var medicationResource: MedicationResource?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        relatedInfoLabel.text = ""
        initBackButtonFromChild()
        
        shadowView.addShadow(size: 11, shift: 1.5, opacity: 0.2)
        containerView.roundCorners(5.5)
        bottomMargin.constant = OPTION_FIX_DESIGN_ISSUES ? 15 : 45 // as in design
        loadData()
    }

    /// Fix UITextView issue
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.contentOffset.y = 0
    }

    /// Load data
    private func loadData() {
        if let item = medicationResource {
            self.textView.text = item.text
            self.titleLabel.text = item.title
            self.iconView.image = nil
            self.view.layoutIfNeeded()
            self.textView.contentOffset.y = 0
            UIImage.loadAsync(item.imageUrl, callback: { (image) in
                self.iconView.image = image
            })

            if let color = item.tintColor {
                self.iconView.tintColor = color
            }
            if !item.relatedFoodInfo.isEmpty {
                relatedInfoLabel.text = NSLocalizedString("Related meal: ", comment: "Related meal: ") + item.relatedFoodInfo
            }
        }
    }

}
