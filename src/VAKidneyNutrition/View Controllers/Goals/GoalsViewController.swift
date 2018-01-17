//
//  GoalsViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/24/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Goals screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class GoalsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the space between cells
    let CELL_SPACING: CGFloat = 10

    /// the cell size
    let CELL_CATEGORY_SIZE: CGSize = CGSize(width: 90, height: 62)

    /// the cell size
    let CELL_GOAL_SIZE: CGSize = CGSize(width: 170, height: 110)

    /// outlets
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var rewardDetailsLabel: UILabel!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var goalsCollectionView: UICollectionView!
    @IBOutlet weak var goalsCollectionViewHeight: NSLayoutConstraint!

    /// the reports
    private var categories = [GoalCategory]()

    /// the goals
    private var goals = [Goal]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        loadData()
    }

    /// Load data
    private func loadData() {
        self.view.layoutIfNeeded()
        let loadingView = showLoadingView()
        api.getGoals(callback: { (goals, categories) in
            loadingView?.terminate()
            self.goals = goals
            self.categories = categories
            let rows = Int(max(0, floor(Float(goals.count - 1) / 2) + 1))
            let spaces = max(0, rows - 1)
            let height = CGFloat(rows) * self.CELL_GOAL_SIZE.height + CGFloat(spaces) * self.CELL_SPACING
            self.goalsCollectionViewHeight.constant = height
            self.goalsCollectionView.reloadData()
            self.categoriesCollectionView.reloadData()
        }, failure: createGeneralFailureCallback(loadingView))

        pointsLabel.text = ""
        api.getRewards(callback: { (items) in
            let sum = items.map({$0.points}).reduce(0, +)
            self.pointsLabel.text = sum.toPointsText()
        }, failure: createGeneralFailureCallback())
    }

    /// Open rewards button action handler
    ///
    /// - parameter sender: the button
    @IBAction func openRewardsAction(_ sender: Any) {
        if let vc = create(RewardsViewController.self) {
            MainViewControllerReference?.showViewController(vc.wrapInNavigationController())
        }
    }

    /// Add new goals" rewards button action handler
    ///
    /// - parameter sender: the button
    @IBAction func addGoalAction(_ sender: Any) {
        if let vc = create(AddGoalViewController.self) {
            MainViewControllerReference?.showViewController(vc.wrapInNavigationController())
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
        if collectionView == goalsCollectionView {
            return goals.count
        }
        else {
            return categories.count + 1
        }
    }

    /// Get cell
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    /// - Returns: the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == goalsCollectionView {
            let cell = collectionView.getCell(indexPath, ofClass: GoalCollectionViewCell.self)
            cell.configure(goals[indexPath.row], cellWidth: getCellWidth())
            return cell
        }
        else {
            let cell = collectionView.getCell(indexPath, ofClass: GoalCategoryCollectionViewCell.self)
            if indexPath.row < categories.count {
                let item = categories[indexPath.row]
                cell.configure(item, goals: goals.filter({$0.category.id == item.id}))
            }
            else {
                cell.configureTotal(categories, goals: goals)
            }
            return cell
        }
    }

    /// Get report cell width
    ///
    /// - Returns: the width
    private func getCellWidth() -> CGFloat {
        self.view.layoutIfNeeded()
        return (self.goalsCollectionView.bounds.width - CELL_SPACING) / 2
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == goalsCollectionView {
            showGoalDetails(goals[indexPath.row])
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
        if collectionView == categoriesCollectionView {
            self.view.layoutIfNeeded()
            let width = (self.categoriesCollectionView.bounds.width - 3 * CELL_SPACING) / 4
            return CGSize(width: width, height: CELL_CATEGORY_SIZE.height)
        }
        else {
            return CGSize(width: getCellWidth(), height: CELL_GOAL_SIZE.height)
        }
    }

    /// Open goal details
    ///
    /// - Parameter goal: the goal
    func showGoalDetails(_ goal: Goal) {
        if let vc = create(AddGoalViewController.self) {
            vc.goal = goal
            MainViewControllerReference?.showViewController(vc.wrapInNavigationController())
        }
    }
}

/**
 * Cell for goals in GoalsViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class GoalCategoryCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: CustomProgressView!
    @IBOutlet weak var thumbIcon: UIImageView!

    /// Update UI
    ///
    /// - Parameter item: the item to show
    func configure(_ item: GoalCategory, goals: [Goal]) {
        numberLabel.text = "\(item.numberOfGoals)"
        titleLabel.text = item.title
        configure(goals)
        backgroundColor = Colors.lightGray
    }

    /// Update UI
    ///
    /// - Parameters:
    ///   - list: the categories
    ///   - goals: the goals
    func configureTotal(_ list: [GoalCategory], goals: [Goal]) {
        numberLabel.text = "\(list.map({$0.numberOfGoals}).reduce(0, +))"
        titleLabel.text = NSLocalizedString("Total Goals", comment: "Total Goals")
        configure(goals)
        backgroundColor = UIColor.white
    }

    /// Configure goals
    ///
    /// - Parameter goals: the goals
    private func configure(_ goals: [Goal]) {
        thumbIcon.image = #imageLiteral(resourceName: "tUp")
        var progress: Float = 0
        for item in goals {
            progress += item.progress
            if !item.isGoalAchived {
                thumbIcon.image = #imageLiteral(resourceName: "tDown")
            }
        }
        if goals.count > 0 {
            progress /= Float(goals.count)
        }
        progressView.progress = progress
    }
}

/**
 * Cell for reports in GoalsViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class GoalCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var buttonLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var addOneButton: UIButton!
    @IBOutlet weak var progressView: CustomProgressView!
    @IBOutlet weak var achievedView: UIView!
    @IBOutlet weak var achievedTitleLabel: UILabel!
    @IBOutlet weak var achievedPointsLabel: UILabel!

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    ///   - cellWidth: the width of the cell
    func configure(_ item: Goal, cellWidth: CGFloat) {
        iconView.image = item.getIcon()
        titleLabel.text = item.title
        category.text = NSLocalizedString("Category", comment: "Category") + ": \(item.category.title)"
        pointsLabel.text = "\(item.points) \(item.points == 1 ? "point" : "points")"
        valueLabel.text = item.getValueText()
        goalLabel.text = item.getTargetText()

        achievedView.isHidden = !item.isGoalAchived

        let showTwoButtons = item.hasExternalData
        syncButton.isHidden = !showTwoButtons
        let prefix = item.isAscendantTarget ? NSLocalizedString("Add one", comment: "Add one") : NSLocalizedString("Remove one", comment: "Remove one")
        addOneButton.setTitle(prefix + " " + item.valueText1.lowercased(), for: .normal)

        if showTwoButtons {
            buttonLeftMargin.constant = cellWidth / 2
        }
        else {
            buttonLeftMargin.constant = 0
        }
        progressView.progress = item.progress
    }

    /// "More" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func moreAction(_ sender: UIButton) {

        ContextMenuViewController.show([ContextItem(title: NSLocalizedString("Drag Position", comment: "Drag Position")) {
                showStub()
            }], from: sender)
    }

    /// "Sync" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func syncAction(_ sender: Any) {
        showStub()
    }

    /// "Add one ..." button action handler
    ///
    /// - parameter sender: the button
    @IBAction func addOneData(_ sender: Any) {
        showStub()
    }
}
