//
//  DailyWorkoutViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Daily Workout screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class DailyWorkoutViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the space between cells
    let CELL_SPACING: CGFloat = 10

    /// the margins
    let COLLETION_VIEW_MARGINS: CGFloat = 5

    /// the cell size
    let CELL_SIZE: CGSize = CGSize(width: 170, height: 110)

    /// outlets
    @IBOutlet weak var lastSyncInfoLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    /// the items to show
    private var items = [Workout]()

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
        api.getWorkout(callback: { (items) in
            self.items = items
            self.collectionView.reloadData()
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
        return (self.collectionView.bounds.width -  CELL_SPACING - COLLETION_VIEW_MARGINS * 2) / 2
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
 * - version: 1.0
 */
class WorkoutCollectionViewCell: GoalCollectionViewCell {

    /// outlets
    @IBOutlet weak var goalIcon: UIImageView!

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    ///   - cellWidth: the width of the cell
    func configure(_ item: Workout, cellWidth: CGFloat) {
        iconView.image = item.getIcon()
        titleLabel.text = item.title
        category.text = ""
        pointsLabel.text = ""
        valueLabel.text = item.getValueText()
        goalLabel.text = item.getTargetText()


        let showTwoButtons = item.canBeManuallyChanged

        achievedView.isHidden = !showTwoButtons || !item.isGoalAchived

        addOneButton.isHidden = !showTwoButtons
        let prefix = NSLocalizedString("Add one", comment: "Add one")
        addOneButton.setTitle(prefix + " " + item.valueText1.lowercased(), for: .normal)

        if showTwoButtons {
            buttonLeftMargin.constant = cellWidth / 2
            goalIcon.image = #imageLiteral(resourceName: "goalsIcon")
        }
        else {
            buttonLeftMargin.constant = self.bounds.width - 1.5
            goalIcon.image = #imageLiteral(resourceName: "smileHappy")
        }
        progressView.isHidden = !showTwoButtons
        goalLabel.isHidden = !showTwoButtons
    }
}
