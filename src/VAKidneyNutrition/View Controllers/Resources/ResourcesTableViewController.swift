//
//  ResourcesTableViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/// Possible resource types
enum ResourceType: Int {
    case articles = 0, tutorials, education
}

/**
 * Resources screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ResourcesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
    private var items = [Resource]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

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
        self.items.removeAll()
        self.tableView.reloadData()
        let loadingView = LoadingView(parentView: self.view, dimming: false).show()
        api.getResources(type: ResourceType(rawValue: selectedTabIndex) ?? .articles, callback: { (items) in
            loadingView.terminate()
            self.items = items
            self.noDataLabel.isHidden = !items.isEmpty
            self.tableView.reloadData()
        }, failure: createGeneralFailureCallback(loadingView))
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
        let item = items[indexPath.row]
        let cell = tableView.getCell(indexPath, ofClass: ResourceTableCell.self)
        cell.configure(item)
        return cell
    }

    /**
     Cell selection handler

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        if let vc = create(ResourceDetailsViewController.self, storyboardName: "Medications") {
            vc.title = NSLocalizedString("Resource Details", comment: "Resource Details").uppercased()

            vc.medicationResource = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

/**
 * Cell for table in ResourcesViewController
 *
 * - author TCCODER
 * - version 1.0
 */
class ResourceTableCell: ZeroMarginsCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shadowView: UIView!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.masksToBounds = false
        self.layer.masksToBounds = false
        mainView.roundCorners()
        shadowView.addShadow(size: 8, shift: 0, opacity: 0.2)
    }
    
    /// Update UI with given data
    ///
    /// - Parameters:
    ///   - item: the data to show in the cell
    ///   - isLast: true - if last row
    func configure(_ item: Resource) {
        titleLabel.text = item.title
        titleLabel.textColor = Colors.blue
        detailsLabel.text = item.text
        detailsLabel.setLineSpacing(lineSpacing: 3)
    }
}
