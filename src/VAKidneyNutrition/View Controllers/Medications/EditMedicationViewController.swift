//
//  EditMedicationViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Edit medication
 *
 * - author: TCCODER
 * - version: 1.0
 */
class EditMedicationViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scheduleDetailsLabel: UILabel!

    /// the medication to show
    var medication: Medication? { didSet { if let medication = medication { self.editableMedication = medication } } }

    /// the editable medication
    var editableMedication: Medication!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        updateUI()
    }

    /// Update UI
    private func updateUI() {
        if editableMedication == nil {
            editableMedication = Medication(id: "")
        }
        titleLabel.text = editableMedication?.title ?? ""
        scheduleDetailsLabel.text = editableMedication?.times.map({"\($0.getHourText())   |   \($0.getUnitsText())   |   \($0.getWeekdayText())"}).joined(separator: "\n") ?? ""
        title = self.medication == nil ? NSLocalizedString("Add A Medication", comment: "Add A Medication") : NSLocalizedString("Edit A Medication", comment: "Edit A Medication")
    }

    /// "Edit title" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func editName(_ sender: Any) {
        openEditSchedule()
    }

    /// "Edit schedule" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func editScheduleAction(_ sender: Any) {
        openEditSchedule()
    }

    /// "Re-enter details" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func reEnterDetailsAction(_ sender: Any) {
        openEditSchedule()
    }

    /// "Delete" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func deleteAction(_ sender: Any) {
        showStub()
    }

    /// Open Schedule editor
    private func openEditSchedule() {
        if let vc = create(EditMedicationScheduleViewController.self) {
            vc.medication = editableMedication
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
