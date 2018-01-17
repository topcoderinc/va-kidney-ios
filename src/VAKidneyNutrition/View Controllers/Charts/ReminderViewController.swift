//
//  ReminderViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Reminder screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ReminderViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevArrow: UIImageView!
    @IBOutlet weak var nextArrow: UIImageView!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!

    /// the related report to open
    var report: Report?
    var previousReport: Report?
    var nextReport: Report?

    /// the reference date
    var date = Date()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        loadData()
    }

    /// Update UI
    func updateUI() {
        dateLabel.text = DateFormatters.shortDate.string(from: date)
        dayLabel.text = Date().isSameDay(date: date) ? NSLocalizedString("Today", comment: "Today") : ""
        timeLabel.text = DateFormatters.time.string(from: date)

        if let report = report {
            titleLabel.text = report.title
            prevButton.isHidden = previousReport == nil
            prevArrow.isHidden = previousReport == nil
            if let report = previousReport {
                prevButton.setTitle(report.title, for: .normal)
            }
            nextButton.isHidden = nextReport == nil
            nextArrow.isHidden = nextReport == nil
            if let report = nextReport {
                nextButton.setTitle(report.title, for: .normal)
            }
        }
        else {
            titleLabel.text = ""
            prevButton.isHidden = true
            prevArrow.isHidden = true
            nextButton.isHidden = true
            nextArrow.isHidden = true
        }
    }

    /// Load data
    private func loadData() {
        updateUI()
        let failure: FailureCallback = { error in
            showError(errorMessage: error)
        }
        if let report = report {
            UserDefaults.standard.set(report.id, forKey: kLastOpenedReportId)
            UserDefaults.standard.synchronize()
            api.getNearbyReports(report: report, callback: { (prev, next) in
                self.previousReport = prev
                self.nextReport = next
                self.updateUI()
            }, failure: failure)
        }
        else {
            api.getReports(callback: { (reports) in
                let lastId = UserDefaults.standard.value(forKey: kLastOpenedReportId) as? String
                self.report = reports.first
                if let lastId = lastId, let report = reports.filter({$0.id == lastId}).first {
                    self.report = report
                }
                self.loadData()
            }, failure: failure)
        }
    }

    /// Previous report button action handler
    ///
    /// - parameter sender: the button
    @IBAction func previosAction(_ sender: Any) {
        self.view.endEditing(true)
        if let prev = previousReport {
            self.report = prev
            loadData()
        }
    }

    /// Next report button action handler
    ///
    /// - parameter sender: the button
    @IBAction func nextAction(_ sender: Any) {
        self.view.endEditing(true)
        if let next = nextReport {
            self.report = next
            loadData()
        }
    }

    /// "Change Date" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func changeDateAction(_ sender: Any) {
        self.view.endEditing(true)
        showStub() // date picker
    }

    /// "Change Time" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func changeTimeAction(_ sender: Any) {
        self.view.endEditing(true)
        showStub() // time picker
    }

    /// "Save this reminder" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func saveReminder(_ sender: Any) {
        self.view.endEditing(true)
        showStub()
    }

    /// "Delete" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func deleteReminder(_ sender: Any) {
        self.view.endEditing(true)
        showStub()
    }

    /// Dismiss keyboard
    ///
    /// - Parameters:
    ///   - touches: the touches
    ///   - event: the event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
