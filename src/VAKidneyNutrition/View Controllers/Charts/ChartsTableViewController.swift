//
//  ChartsTableViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/3/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Table with all lab values used to show Charts
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ChartsTableViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    /// the related report to open
    var report: Report?

    /// the table model
    private var table = SectionInfiniteTableViewModel<LabValue, LabValueTableViewCell>()

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()

        noDataLabel.isHidden = true

        table.noDataLabel = noDataLabel
        table.configureCell = { indexPath, item, _, cell in
            cell.titleLabel?.text = item.title
        }
        table.onSelect = { _, item in
            self.openChart(item)
        }
        table.loadSectionItems = { callback, failure in
            CachingServiceApi.shared.getLabValues(callback: { (values) in
                callback(values, [NSLocalizedString("Major", comment: "Major"), NSLocalizedString("Other", comment: "Other")])
            }, failure: failure)
        }
        table.bindData(to: tableView)
    }

    /// Open chart for given lab value
    ///
    /// - Parameter item: the item
    private func openChart(_ item: LabValue) {
        if let vc = create(ChartViewController.self) {
            vc.labValue = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

/**
 * Cell for food items
 *
 * - author: TCCODER
 * - version: 1.0
 */
class LabValueTableViewCell: ZeroMarginsCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
}
