//
//  ChartsTableViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/3/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Table with all lab values used to show Charts
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - bold font if data is presented
 */
class ChartsTableViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    /// the related report to open
    var report: Report?

    /// the table model
    private var table = SectionInfiniteTableViewModel<QuantityType, LabValueTableViewCell>()

    /// the storage
    private var storage: QuantitySampleService = QuantitySampleStorage.shared

    /// the cached metadata
    private var hasData = [String: Bool]()

    /// flag: true - data availability check in progress, false - else
    private var dataAvailabilityCheckInProgress = false
    /// the reference to API
    private let serviceApi: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()

        noDataLabel.isHidden = true

        table.noDataLabel = noDataLabel
        table.configureCell = { indexPath, item, _, cell in
            cell.configure(title: item.title, hasData: self.hasData[item.id] ?? false)
        }
        table.onSelect = { _, item in
            self.openChart(item)
        }
        table.loadSectionItems = { callback, failure in
            self.serviceApi.getLabValues(callback: { (values) in
                callback(values, [NSLocalizedString("Major", comment: "Major"), NSLocalizedString("Other", comment: "Other")])
            }, failure: failure)
        }
        table.bindData(to: tableView)
    }

    /// Update table to show if there are data or not
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkDataAvailability()
    }

    /// Check data availability
    private func checkDataAvailability() {
        guard !dataAvailabilityCheckInProgress else { return }
        dataAvailabilityCheckInProgress = true
        var items = [QuantityType]()
        for section in table.sectionItems {
            items.append(contentsOf: section)
        }
        checkDataAvailability(index: 0, list: items) {
            self.dataAvailabilityCheckInProgress = false
            self.tableView.reloadData()
        }
    }

    /// Check data availability for item at index
    ///
    /// - Parameters:
    ///   - index: the index
    ///   - list: the list
    ///   - callback: the callback to invoke after all items are checked
    private func checkDataAvailability(index: Int, list: [QuantityType], callback: @escaping ()->()) {
        if index < list.count {
            let item = list[index]
            self.storage.hasData(item, callback: { (result) in
                self.hasData[item.id] = result
                self.checkDataAvailability(index: index + 1, list: list, callback: callback)
            }, customTypeCallback: {
                self.checkDataAvailability(index: index + 1, list: list, callback: callback)
            })
        }
        else {
            callback()
        }
    }

    /// Open chart for given lab value
    ///
    /// - Parameter item: the item
    private func openChart(_ item: QuantityType) {
        if let vc = create(ChartViewController.self) {
            vc.quantityType = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

/**
 * Cell for food items
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - font change support
 */
class LabValueTableViewCell: ZeroMarginsCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!

    /// Update UI
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - hasData: true - if has data, false - else
    func configure(title: String, hasData: Bool) {
        let font = UIFont(name: hasData ? Fonts.Bold : Fonts.Regular, size: titleLabel.font.pointSize)!
        let color: UIColor = titleLabel.textColor
        let string = NSMutableAttributedString(string: title, attributes: [.font : font, .foregroundColor: color])
        titleLabel.attributedText = string
    }
}
