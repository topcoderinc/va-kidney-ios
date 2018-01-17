//
//  MedicationsMainViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/24/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Medications main view controller
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MedicationsMainViewController: UIViewController {

    /// outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scheduleUnderline: UIView!
    @IBOutlet weak var medicationsUnderline: UIView!

    /// the last loaded view controller
    private var lastLoadedViewController: UIViewController?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        scheduleTabAction(self)
    }

    /// "Add Medication" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func addMedicationAction(_ sender: Any) {
        if let vc = create(EditMedicationViewController.self) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /// "Schedule" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func scheduleTabAction(_ sender: Any) {
        lastLoadedViewController?.removeFromParent()
        scheduleUnderline.isHidden = false
        medicationsUnderline.isHidden = true
        if let vc = create(MedicationsScheduleViewController.self) {
            lastLoadedViewController = vc
            loadViewController(vc, self.containerView)
        }
    }

    /// "Medicines" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func medicinesTabAction(_ sender: Any) {
        scheduleUnderline.isHidden = true
        medicationsUnderline.isHidden = false
        if let vc = create(MedicationsCollectionViewController.self) {
            lastLoadedViewController = vc
            loadViewController(vc, self.containerView)
        }
    }
}
