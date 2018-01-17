//
//  HomeViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/22/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Home screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the space between cells
    let CELL_SPACING: CGFloat = 10

    /// the cell size
    let CELL_GOAL_SIZE: CGSize = CGSize(width: 90, height: 77)

    /// the cell size
    let CELL_REPORT_SIZE: CGSize = CGSize(width: 170, height: 110)

    /// outlets
    @IBOutlet weak var goalsView: CustomView!
    @IBOutlet weak var goalsCollection: UICollectionView!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var suggestionView: CustomView!
    @IBOutlet weak var suggestionHeight: NSLayoutConstraint!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleText: UILabel!
    @IBOutlet weak var suggestionStatus: UILabel!
    @IBOutlet weak var reportsView: CustomView!
    @IBOutlet weak var reportsCollectionView: UICollectionView!
    @IBOutlet weak var reportsCollectionHeight: NSLayoutConstraint!

    /// the goals
    private var goals = [Goal]()

    /// the reports
    private var reports = [Report]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        setupNavigation()
        loadData()
    }

    /// Load data
    private func loadData() {
        self.view.layoutIfNeeded()
        do {
            let loadingView = LoadingView(parentView: goalsView, dimming: false).show()
            api.getGoals(callback: { (goals, _) in
                loadingView.terminate()
                self.goals = goals
                self.goalsCollection.reloadData()
            }, failure: createGeneralFailureCallback(loadingView))
        }
        do {
            let loadingView = LoadingView(parentView: suggestionView, dimming: false).show()
            articleImage.image = #imageLiteral(resourceName: "subImage")
            articleTitle.text = "-"
            articleText.text = "-"
            suggestionStatus.text = ""
            api.getMainSuggestion(callback: { (item) in
                loadingView.terminate()
                if let item = item {
                    if let imageName = item.imageUrl, let image = UIImage(named: imageName) {
                        self.articleImage.image = image
                    }
                    self.articleTitle.text = item.title
                    self.articleText.text = item.text
                    self.suggestionStatus.text = item.status
                    self.suggestionView.isHidden = false
                    self.suggestionHeight.constant = 110
                }
                else {
                    self.suggestionView.isHidden = true
                    self.suggestionHeight.constant = 0
                }
            }, failure: createGeneralFailureCallback(loadingView))
        }
        do {
            let loadingView = LoadingView(parentView: reportsView, dimming: false).show()
            api.getReports(callback: { (items) in
                let rows = Int(max(0, floor(Float(items.count - 1) / 2) + 1))
                let spaces = max(0, rows - 1)
                let height = CGFloat(rows) * self.CELL_REPORT_SIZE.height + CGFloat(spaces) * self.CELL_SPACING
                self.reportsCollectionHeight.constant = height
                loadingView.terminate()
                self.reports = items
                self.reportsCollectionView.reloadData()
            }, failure: createGeneralFailureCallback(loadingView))
        }
    }

    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate

    /// Get the number of cells
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - section: the section
    /// - Returns: the number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == goalsCollection {
            return goals.count
        }
        else {
            return reports.count
        }
    }

    /// Get cell
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    /// - Returns: the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == goalsCollection {
            let cell = collectionView.getCell(indexPath, ofClass: HomeGoalCollectionViewCell.self)
            cell.configure(goals[indexPath.row])
            return cell
        }
        else {
            let cell = collectionView.getCell(indexPath, ofClass: HomeReportCollectionViewCell.self)
            cell.parent = self
            cell.configure(reports[indexPath.row], cellWidth: getCellWidth())
            return cell
        }
    }

    /// Get report cell width
    ///
    /// - Returns: the width
    private func getCellWidth() -> CGFloat {
        self.view.layoutIfNeeded()
        return (self.reportsCollectionView.bounds.width - CELL_SPACING) / 2
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == goalsCollection {
            showGoalDetails(goals[indexPath.row])
        }
        else {
            showReportDetails(reports[indexPath.row])
        }
    }

    /// Get cell size
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - collectionViewLayout: the layout
    ///   - indexPath: the indexPath
    /// - Returns: cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == goalsCollection {
            self.view.layoutIfNeeded()
            let width = self.goalsCollection.bounds.width / 4
            return CGSize(width: width, height: CELL_GOAL_SIZE.height)
        }
        else {
            return CGSize(width: getCellWidth(), height: CELL_REPORT_SIZE.height)
        }
    }

    /// Open goal details
    ///
    /// - Parameter goal: the goal
    func showGoalDetails(_ goal: Goal) {
        // nothing to do
    }

    /// "More" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func moreGoalsAction(_ sender: Any) {
        showStub()
    }

    /// Open report details
    ///
    /// - Parameter report: the report
    func showReportDetails(_ report: Report) {
        MainViewControllerReference?.openCharts(report: report)
    }
}

/**
 * Cell for goals in HomeViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HomeGoalCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbIcon: UIImageView!

    /// Update UI
    ///
    /// - Parameter item: the item to show
    func configure(_ item: Goal) {
        iconView.image = UIImage(named: item.iconName)
        titleLabel.text = item.title
        thumbIcon.image = item.isGoalAchived ? #imageLiteral(resourceName: "tUp") : #imageLiteral(resourceName: "tDown")
    }
}

/**
 * Cell for reports in HomeViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HomeReportCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var buttonLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var suggestionButton: CustomButton!
    @IBOutlet weak var smile: UIImageView!

    var parent: UIViewController!
    var item: Report!

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    ///   - cellWidth: the width of the cell
    func configure(_ item: Report, cellWidth: CGFloat) {
        self.item = item
        iconView.image = item.limitStatus.getIconImage()
        titleLabel.text = item.title
        unitsLabel.text = item.getUnitsText()
        daysLabel.text = item.getDaysText()
        suggestionButton.isHidden = !item.showTwoButtons

        iconView.isHidden = !item.showTwoButtons
        smile.isHidden = !item.showTwoButtons
        daysLabel.isHidden = !item.showTwoButtons

        if item.showTwoButtons {
            buttonLeftMargin.constant = cellWidth / 2
        }
        else {
            buttonLeftMargin.constant = 0
            unitsLabel.text = NSLocalizedString("Report not added", comment: "Report not added")
        }
        smile.image = item.limitStatus.getSmile()
    }

    /// "More" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func moreAction(_ sender: UIButton) {

        ContextMenuViewController.show([ContextItem(title: NSLocalizedString("Add a Reminder", comment: "Add a Reminder")) {
            showStub()
            },
            ContextItem(title: NSLocalizedString("Drag Position", comment: "Drag Position")) {
                showStub()
            }], from: sender)
    }

    /// "Suggestions" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func suggestionsAction(_ sender: Any) {
        if let vc = parent.create(ResourcesViewController.self) {
            vc.report = self.item
            parent.navigationController?.pushViewController(vc, animated: true)
        }
    }

    /// "Add new data" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func addNewData(_ sender: Any) {
        showStub()
    }
}

