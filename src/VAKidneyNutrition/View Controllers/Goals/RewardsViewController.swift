//
//  RewardsViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/24/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Rewards screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RewardsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the space between cells
    let CELL_SPACING: CGFloat = 10

    /// the margins
    let COLLETION_VIEW_MARGINS: CGFloat = 5

    /// the cell size
    let CELL_SIZE: CGSize = CGSize(width: 170, height: 110)

    /// outlets
    @IBOutlet weak var collectionView: UICollectionView!

    /// the items to show
    private var items = [Reward]()

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
        let loadingView = showLoadingView()
        api.getRewards(callback: { (items) in
            loadingView?.terminate()
            self.items = items
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
        return items.count
    }

    /// Get cell
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    /// - Returns: the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.getCell(indexPath, ofClass: RewardCollectionViewCell.self)
        cell.configure(items[indexPath.row])
        return cell
    }

    /// Get cell size
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - collectionViewLayout: the layout
    ///   - indexPath: the indexPath
    /// - Returns: cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.view.layoutIfNeeded()
        let width = (self.collectionView.bounds.width -  CELL_SPACING - COLLETION_VIEW_MARGINS * 2) / 2
        return CGSize(width: width, height: CELL_SIZE.height)
    }
}

/**
 * Cell for reports in RewardsViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RewardCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    func configure(_ item: Reward) {
        iconView.image = item.isCompleted ? #imageLiteral(resourceName: "tUp") : #imageLiteral(resourceName: "smileHappy")
        iconView.contentMode = item.isCompleted ? .center : .scaleAspectFit
        titleLabel.text = item.points.toPointsText()
        descriptionLabel.text = item.text
        messageLabel.text = item.message
    }

}
