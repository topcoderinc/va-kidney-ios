//
//  EditMedicationScheduleViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIComponents

/// type alias for time in a schedule (currently just hour)
typealias MedicationScheduleTime = Int

// the value representing each weekday
let EVERY_DAY = -1

/**
 * Edit schedule
 *
 * - author: TCCODER
 * - version: 1.0
 */
class EditMedicationScheduleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// possible hours to select
    let HOURS: [MedicationScheduleTime] = [8, 11, 14, 17, 19, 21]

    /// the space between cells
    let CELL_SPACING: CGFloat = 10

    /// the margins
    let COLLETION_VIEW_MARGINS: CGFloat = 5

    /// the cell size
    let CELL_SIZE: CGSize = CGSize(width: 170, height: 44)
    
    /// outlets
    @IBOutlet weak var titleField: CustomTextField!
    @IBOutlet weak var collectionView: UICollectionView!

    /// the medication to show
    var medication: Medication!

    /// the selected days and time
    var selectedDays = [Int]()
    var selectedTimeForDays = [Int: [MedicationScheduleTime]]()

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        initBackButtonFromChild()
        navigationItem.rightBarButtonItem = nil
        updateUI()
    }

    /// Update UI
    private func updateUI() {
        titleField.text = medication.title
        selectedDays.removeAll()
        selectedTimeForDays.removeAll()
        var weekdays = [Int]()
        for time in medication.times {
            if !weekdays.contains(time.weekday) {
                weekdays.append(time.weekday)
            }
            var list = selectedTimeForDays[time.weekday]
            if list == nil {
                list = [MedicationScheduleTime]()
            }
            list!.append(time.hour)
            selectedTimeForDays[time.weekday] = list!
        }
        selectedDays = weekdays.sorted()
        self.collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate

    /// Get number of sections
    ///
    /// - Parameter collectionView: the collectionView
    /// - Returns: the number of section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if selectedDays.contains(EVERY_DAY) {
            return 2
        }
        else {
            return selectedDays.count + 1
        }
    }

    /// Get the number of cells
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - section: the section
    /// - Returns: the number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return selectedDays.contains(EVERY_DAY) ? 1 : 8
        }
        else {
            return HOURS.count
        }
    }

    /// Get cell
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    /// - Returns: the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.getCell(indexPath, ofClass: EditMedicationScheduleCell.self)
        // weekdays
        if indexPath.section == 0 {
            let weekday = indexPath.row - 1
            let isSelected = selectedDays.contains(weekday)
            let title = weekday == EVERY_DAY ? "Every Day" : DateFormatters.weekday.string(from: Date.create(withWeekday: weekday))
            cell.configure(title, isSelected: isSelected)
            return cell
        }
        // time
        else {
            var weekday = EVERY_DAY
            if indexPath.section - 1 < selectedDays.count && !selectedDays.contains(EVERY_DAY) {
                weekday = selectedDays[indexPath.section - 1]
            }
            let selectedTime = selectedTimeForDays[weekday] ?? []
            let hour = HOURS[indexPath.row]
            let isSelected = selectedTime.map({$0}).contains(hour)
            let title = hour.toHourText()
            cell.configure(title, isSelected: isSelected)
            return cell
        }
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // weekdays
        if indexPath.section == 0 {
            let weekday = indexPath.row - 1
            if let index = selectedDays.index(of: weekday) {
                selectedDays.remove(at: index)
            }
            else {
                selectedDays.append(weekday)
            }
            selectedDays = selectedDays.sorted()
        }
        // time
        else {
            var weekday = EVERY_DAY
            if indexPath.section - 1 < selectedDays.count && !selectedDays.contains(EVERY_DAY) {
                weekday = selectedDays[indexPath.section - 1]
            }
            var selectedTime = selectedTimeForDays[weekday] ?? []
            let hour = HOURS[indexPath.row]
            if let index = selectedTime.map({$0}).index(of: hour) {
                selectedTime.remove(at: index)
            }
            else {
                selectedTime.append(hour)
            }
            selectedTimeForDays[weekday] = selectedTime
        }
        self.collectionView.reloadData()
    }

    /// Get cell size
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - collectionViewLayout: the layout
    ///   - indexPath: the indexPath
    /// - Returns: cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.view.layoutIfNeeded()
        let width = (self.collectionView.bounds.width -  CELL_SPACING - COLLETION_VIEW_MARGINS * 2) / 2
        return CGSize(width: width, height: CELL_SIZE.height)
    }

    /// Get section height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.bounds.width, height: 40)
    }

    /// Get section view
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - kind: teh kind
    ///   - indexPath: the indexPath
    /// - Returns: the view
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EditMedicationScheduleSection", for: indexPath) as! EditMedicationScheduleSection

        view.copyButton.isHidden = true
        if kind == UICollectionElementKindSectionHeader {
            if indexPath.section == 0 {
                view.titleLabel.text = NSLocalizedString("Select Days", comment: "Select Days")
            }
            else {
                var weekday = EVERY_DAY
                if indexPath.section - 1 < selectedDays.count && !selectedDays.contains(EVERY_DAY) {
                    weekday = selectedDays[indexPath.section - 1]
                }
                if weekday == EVERY_DAY {
                    view.titleLabel.text = NSLocalizedString("Every Day Schedule", comment: "Every Day Schedule")
                }
                else {
                    view.titleLabel.text = DateFormatters.weekday.string(from: Date.create(withWeekday: weekday)) + " " + NSLocalizedString("Schedule", comment: "Schedule")
                }
            }
            view.copyButton.isHidden = indexPath.section < 2
        }
        else {
            view.titleLabel.text = ""
        }
        return view
    }

    /// "Save" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func saveAction(_ sender: Any) {
        showStub()
    }
}

/**
 * Cell for EditMedicationScheduleViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class EditMedicationScheduleCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var checkboxButton: UIButton!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        checkboxButton.isUserInteractionEnabled = false
    }

    /// Update UI
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - isSelected: true - if selected checkbox, false - else
    func configure(_ title: String, isSelected: Bool) {
        checkboxButton.setTitle(title, for: .normal)
        checkboxButton.setTitle(title, for: .selected)
        checkboxButton.isSelected = isSelected
    }
}

/**
 * Section header for EditMedicationScheduleViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class EditMedicationScheduleSection: UICollectionReusableView {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var copyButton: CustomButton!

    /// "Copy.." button action handler
    ///
    /// - parameter sender: the button
    @IBAction func copyFromAboveAction(_ sender: Any) {
        showStub()
    }

}
