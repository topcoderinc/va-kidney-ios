//
//  ResourcesViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Resources screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ResourcesViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevArrow: UIImageView!
    @IBOutlet weak var nextArrow: UIImageView!

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

    /// "Play" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func playVideo(_ sender: Any) {
        showStub()
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
}
