//
//  MedicationsTableViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/3/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Medications main screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API changes
 */
class MedicationsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// the section header height
    let SECTION_HEADER_HEIGHT: CGFloat = 50

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var underLineLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var underLineWidth: NSLayoutConstraint!

    /// the items
    private var items = [(String,[Recommendation])]()

    /// the reference to API
    private let api: RecommendationServiceApi = CachingServiceApi.shared

    /// the selected tab index
    private var selectedTabIndex = -1

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutIfNeeded()
        setupNavigation()
        self.navigationItem.rightBarButtonItem = nil

        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentOffset.y = -tableView.contentInset.top
        tableView.registerHeader(MedicationHeader.self)

        noDataLabel.isHidden = true
        tabButtonAction(tabButtons.filter({$0.tag == 0}).first!)
    }

    /// Load data
    private func loadData() {
        let loadingView = LoadingView(parentView: self.view, dimming: false).show()
        let callback: ([(String,[Recommendation])])->() = { (items) in
            loadingView.terminate()
            self.items = items
            self.noDataLabel.isHidden = !items.isEmpty
            self.tableView.reloadData()
        }
        switch selectedTabIndex {
        case 0:
            api.getMedicationRecommendations(callback: callback, failure: createGeneralFailureCallback(loadingView))
        case 1:
            api.getDragRecommendations(callback: callback, failure: createGeneralFailureCallback(loadingView))
        default:
            loadingView.terminate()
            break
        }
    }

    /// Top tab button action handler
    ///
    /// - parameter sender: the button
    @IBAction func tabButtonAction(_ sender: UIButton) {
        if selectedTabIndex != sender.tag {
            selectedTabIndex = sender.tag
            for button in tabButtons {
                button.isSelected = button.tag == sender.tag
                if button.isSelected {
                    updateUnderLine(button)
                    loadData()
                }
            }
        }
    }

    /// Update meal time
    ///
    /// - Parameter button: the button
    private func updateUnderLine(_ button: UIButton) {
        UIView.animateWithDefaultSettings {
            self.underLineWidth.constant = button.bounds.width + 10
            self.underLineLeftMargin.constant = button.frame.origin.x - 5
            self.view.layoutIfNeeded()
        }
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    /**
     The number of rows

     - parameter tableView: the tableView
     - parameter section:   the section index

     - returns: the number of items
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].1.count
    }

    /**
     Get cell for given indexPath

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath

     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section].1[indexPath.row]
        let cell = tableView.getCell(indexPath, ofClass: MedicationResourceCell.self)
        cell.configure(item, isLast: indexPath.row == items[indexPath.section].1.count - 1)
        return cell
    }

    /**
     Cell selection handler

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.section].1[indexPath.row]
        if let vc = create(ResourceDetailsViewController.self, storyboardName: "Medications") {
            if let button = tabButtons.filter({$0.tag == selectedTabIndex}).first,
                let buttonTitle = button.title(for: .normal) {
                vc.title = "\(buttonTitle) \(NSLocalizedString("Details", comment: "Details"))".uppercased()
                if !OPTION_FIX_DESIGN_ISSUES {
                    // In design the title slightly differs
                    vc.title = vc.title?.replace("Nutrition Details".uppercased(), withString: "Nutritions Details".uppercased())
                }
            }
            else {
                vc.title = NSLocalizedString("Resource Details", comment: "Resource Details").uppercased()
            }

            vc.medicationResource = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    /// Get section header view
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = items[section].0
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MedicationHeader") as! MedicationHeader
        view.titleLabel.text = title
        return view
    }

    /// Get section header height
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: section header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_HEADER_HEIGHT
    }

}

/**
 * Section for table in MedicationsTableViewController
 *
 * - author TCCODER
 * - version 1.0
 */
class MedicationHeader: UITableViewHeaderFooterView {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
}

/**
 * Cell for table in MedicationsTableViewController
 *
 * - author TCCODER
 * - version 1.0
 */
class MedicationResourceCell: ZeroMarginsCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var lineView: UIView!

    /// Update UI with given data
    ///
    /// - Parameters:
    ///   - item: the data to show in the cell
    ///   - isLast: true - if last row
    func configure(_ item: Recommendation, isLast: Bool) {
        titleLabel.text = item.title
        titleLabel.textColor = Colors.green
        detailsLabel.text = item.text
        detailsLabel.setLineSpacing(lineSpacing: 3)
        lineView.isHidden = isLast
    }
}
