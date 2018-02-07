//
//  GoalsCollectionViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Goals screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class GoalsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the cell size
    let CELL_SIZE: CGSize = CGSize(width: 170, height: 181)

    /// outlets
    @IBOutlet weak var collectionView: UICollectionView!

    /// the items to show
    private var items = [Goal]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// flag: true - is initial loading, false - else
    private var initialLoading = true

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        self.navigationItem.rightBarButtonItem = nil
        if OPTION_FIX_DESIGN_ISSUES {
            title = NSLocalizedString("Goals", comment: "Goals").uppercased()
        }
    }

    /// Reload data
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }

    /// Load data
    private func loadData() {
        self.view.layoutIfNeeded()
        let loadingView = initialLoading ? showLoadingView() : nil
        initialLoading = false
        api.getGoals(callback: { (goals, categories) in
            loadingView?.terminate()
            self.items = goals

            self.collectionView.reloadData()
        }, failure: createGeneralFailureCallback(loadingView))
    }

    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate

    /// Get the number of cells
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - section: the section
    /// - Returns: the number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + 1
    }

    /// Get cell
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    /// - Returns: the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.getCell(indexPath, ofClass: FoodAddIntakeCollectionViewCell.self)
            return cell
        }
        else {
            let item = items[indexPath.row - 1]
            let cell = collectionView.getCell(indexPath, ofClass: GoalCollectionViewCell.self)
            cell.configure(item,  cellWidth: getCellWidth())
            return cell
        }
    }

    /// Get report cell width
    ///
    /// - Returns: the width
    private func getCellWidth() -> CGFloat {
        self.view.layoutIfNeeded()
        let layout = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        let margins = layout.sectionInset
        let spacing = CGSize(width: layout.minimumInteritemSpacing, height: layout.minimumLineSpacing)

        let n: CGFloat = 2
        let width = (collectionView.bounds.width - margins.left - margins.right - (n - 1) * spacing.width) / n
        return width
    }

    /// Get cell size
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - collectionViewLayout: the layout
    ///   - indexPath: the indexPath
    /// - Returns: cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: getCellWidth(), height: CELL_SIZE.height)
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: false)
        if indexPath.row == 0 {
            if let vc = create(AddGoalFormViewController.self) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            let item = items[indexPath.row - 1]
            showGoalDetails(item)
        }
    }

    /// Open goal details
    ///
    /// - Parameter goal: the goal
    func showGoalDetails(_ goal: Goal) {
        if let vc = create(AddGoalFormViewController.self) {
            vc.goal = goal
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


/**
 * Cell for goals
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - changes in UI
 */
class GoalCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var goalValueLabel: UILabel!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var progressCircle: CircleProgress!
    @IBOutlet weak var achievedView: UIView?
    @IBOutlet weak var achievedTitleLabel: UILabel?
    @IBOutlet weak var achievedPointsLabel: UILabel?
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shadowView: UIView!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.masksToBounds = false
        self.layer.masksToBounds = false
        mainView.roundCorners()
        shadowView.addShadow(size: 3, shift: 1.5, opacity: 1)
    }

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    ///   - cellWidth: the width of the cell
    func configure(_ item: Goal, cellWidth: CGFloat) {
        iconView.image = item.getIcon()
        titleLabel.text = item.title

        valueLabel.text = "\(item.value.toStringClear())/\(item.targetValue.toStringClear())"
        if OPTION_USE_SINGULAR_FOR_TOP_GOALS && item.value == 1 {
            goalValueLabel.text = item.valueText1
        }
        else {
            goalValueLabel.text = item.valueTextMultiple
        }

        progressCircle.processValue = item.progress
        progressCircle.mainColor = item.color
        iconView.tintColor = item.color

        if item.hasExternalData {
            syncButton.setTitle(NSLocalizedString("Sync Now", comment: "Sync Now"), for: .normal)
        }
        else {
            let prefix = item.isAscendantTarget ? NSLocalizedString("Add", comment: "Add") : NSLocalizedString("Remove", comment: "Remove")
            syncButton.setTitle(prefix + " " + item.valueText.capitalized, for: .normal)
        }
    }

    /// "Sync" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func syncAction(_ sender: Any) {
        showStub()
    }
}
