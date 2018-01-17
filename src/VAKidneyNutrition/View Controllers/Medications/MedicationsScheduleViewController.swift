//
//  MedicationsScheduleViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Schedule screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MedicationsScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// the medication height
    static let MEDICATION_HEIGHT: CGFloat = 40

    /// outlets
    @IBOutlet weak var tableView: UITableView!

    /// the items to show
    private var items = [MedicationScheduleItem]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        loadData()
    }

    /// Load data
    private func loadData() {
        api.getMedicationScheduleForToday(callback: { (items) in
            self.items = items
            self.tableView.reloadData()
        }, failure: createGeneralFailureCallback())
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    /**
     The number of rows

     - parameter tableView: the tableView
     - parameter section:   the section index

     - returns: the number of items
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    /**
     Get cell for given indexPath

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath

     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(indexPath, ofClass: MedicationsScheduleCell.self)
        let item = items[indexPath.row]
        cell.configure(item)
        return cell
    }

    /// Get cell height
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - indexPath: the indexPath
    /// - Returns: the height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.row]
        let height = CGFloat(max(item.1.count, 2)) * MedicationsScheduleViewController.MEDICATION_HEIGHT + 10
        return height
    }
}

/**
 * Cell for MedicationsScheduleViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MedicationsScheduleCell: UITableViewCell {

    /// outlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        for view in containerView.subviews {
            view.removeFromSuperview()
        }
    }

    /// Update UI with given data
    ///
    /// - Parameter item: the data to show in the cell
    func configure(_ item: MedicationScheduleItem) {
        timeLabel.text = item.0 < 13 ? "\(item.0):00 AM" : "\(item.0 - 12):00 PM"
        var i: CGFloat = 0
        let height: CGFloat = MedicationsScheduleViewController.MEDICATION_HEIGHT
        self.layoutIfNeeded()
        let paddingRight: CGFloat = 5
        for (medication, time) in item.1 {
            let rect = CGRect(x: 0, y: i * height, width: self.containerView.bounds.width - paddingRight, height: height)
            let view = MedicationRowView(frame: rect)
            view.title = medication.title
            view.units = time.units
            view.isSelected = time.taken
            view.backgroundColor = UIColor.white
            containerView.addSubview(view)
            i += 1
        }
    }
}
