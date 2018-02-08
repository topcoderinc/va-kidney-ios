//
//  DailyWorkoutViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Daily Workout screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes
 */
class DailyWorkoutViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the cell size
    let CELL_SIZE: CGSize = CGSize(width: 170, height: 181)

    /// outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var lastSyncInfoLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    /// the items to show
    private var items = [Workout]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.roundCorners()
        shadowView.addShadow(size: 3, shift: 1.5, opacity: 1)
        setupNavigation()
        loadData()
    }

    /// Load data
    private func loadData() {
        api.getWorkout(callback: { (items) in
            self.items = items
            self.collectionView.reloadData()
            self.collectionView.isScrollEnabled = false
            self.collectionViewHeight.constant = self.collectionView.getCollectionHeight(items: self.items.count, cellHeight: self.CELL_SIZE.height)
        }, failure: createGeneralFailureCallback())
    }

    /// "Sync Data" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func syncAllAction(_ sender: Any) {
        showStub()
    }

    /// "Manage Devices" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func mangeDevicesAction(_ sender: Any) {
        showStub()
    }

    /// "More" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func moreAction(_ sender: Any) {
        showStub()
    }

    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate

    /// Get the number of cells
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - section: the section
    /// - Returns: the number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    /// Get cell
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    /// - Returns: the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.getCell(indexPath, ofClass: WorkoutCollectionViewCell.self)
        cell.configure(items[indexPath.row],  cellWidth: getCellWidth())
        return cell
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
}

/**
 * Cell for reports in DailyWorkoutViewController
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes
 */
class WorkoutCollectionViewCell: GoalCollectionViewCell {

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    ///   - cellWidth: the width of the cell
    func configure(_ item: Workout, cellWidth: CGFloat) {
        iconView.image = item.getIcon()
        titleLabel.text = item.title

        achievedPointsLabel?.text = "+\(item.targetValue.toStringClear())"

        valueLabel.text = "\(item.value.toStringClear())/\(item.targetValue.toStringClear())"
        if OPTION_USE_SINGULAR_FOR_TOP_GOALS && item.value == 1 {
            goalValueLabel.text = item.valueText1
        }
        else {
            goalValueLabel.text = item.valueTextMultiple
        }

        achievedView?.isHidden = !item.isGoalAchived
        progressCircle.processValue = item.progress
        progressCircle.mainColor = item.color
        iconView.tintColor = item.color
    }
}
