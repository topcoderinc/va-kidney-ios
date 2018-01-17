//
//  ChartsViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/24/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/// the key for storing last opened report
let kLastOpenedReportId = "kLastOpenedReportId"

/**
 * Charts screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ChartsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var lastAddedLabel: UILabel!
    @IBOutlet weak var reportTitleLabel: UILabel!
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var prevArrow: UIImageView!
    @IBOutlet weak var nextArrow: UIImageView!
    @IBOutlet weak var smileyImage: UIImageView!

    /// the related report to open
    var report: Report?
    var previousReport: Report?
    var nextReport: Report?

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
        if let report = report {
            titleLabel.text = report.title
            smileyImage.isHidden = false
            smileyImage.image = report.limitStatus.getSmile()
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
            lastAddedLabel.text = report.getDaysFullText()
        }
        else {
            titleLabel.text = ""
            smileyImage.isHidden = true
            prevButton.isHidden = true
            prevArrow.isHidden = true
            nextButton.isHidden = true
            nextArrow.isHidden = true
            lastAddedLabel.text = ""

            suggestionLabel.text = ""
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

            api.getSuggestion(forReport: report, callback: { (suggestion) in
                if let suggestion = suggestion {
                    self.suggestionLabel.text = suggestion.text
                }
                else {
                    self.suggestionLabel.text = NSLocalizedString("No suggestions", comment: "No suggestions")
                }
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
        if let prev = previousReport {
            self.report = prev
            loadData()
        }
    }

    /// Next report button action handler
    ///
    /// - parameter sender: the button
    @IBAction func nextAction(_ sender: Any) {
        if let next = nextReport {
            self.report = next
            loadData()
        }
    }

    /// "Table view" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func tableViewAction(_ sender: Any) {
        showStub()
    }

    /// "Graph view" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func graphViewAction(_ sender: Any) {
        // nothing to do
    }

    /// "Add new data" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func addNewDataAction(_ sender: Any) {
        showStub()
    }

    /// "Sync" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func syncDataAction(_ sender: Any) {
        showStub()
    }

    /// "Super reminder" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func setupReminderAction(_ sender: Any) {
        if let vc = create(ReminderViewController.self) {
            vc.report = self.report
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
