//
//  FoodIntakeViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/**
 * Food Intake screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodIntakeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the space between cells
    let CELL_SPACING: CGFloat = 10

    /// the margins
    let COLLETION_VIEW_MARGINS: CGFloat = 5

    /// the cell size
    let CELL_SIZE: CGSize = CGSize(width: 170, height: 137)

    /// outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    /// the items to show
    private var items = [Food]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        leftButton.setTitle(NSLocalizedString("Yesterday", comment: "Yesterday"), for: .normal)
        dateLabel.text = DateFormatters.shortDate.string(from: Date())
        dayLabel.text = NSLocalizedString("Today", comment: "Today")
    }

    /// Load data
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    /// Load data
    private func loadData() {
        let loadingView = showLoadingView()
        api.getFood(callback: { (items) in
            loadingView?.terminate()
            self.items = items
            self.collectionView.reloadData()
        }, failure: createGeneralFailureCallback(loadingView))
    }

    /// Left button action handler
    ///
    /// - parameter sender: the button
    @IBAction func prevButtonAction(_ sender: Any) {
        showStub()
    }

    /// Calendar button action handler
    ///
    /// - parameter sender: the button
    @IBAction func calendarButtonAction(_ sender: Any) {
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "new", for: indexPath)
            return cell
        }
        else {
            let cell = collectionView.getCell(indexPath, ofClass: FoodIntakeCollectionViewCell.self)
            cell.configure(items[indexPath.row - 1])
            return cell
        }
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let vc = create(FoodIntakeFormViewController.self) {
                navigationController?.pushViewController(vc, animated: true)
            }
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
        self.view.layoutIfNeeded()
        let width = (self.collectionView.bounds.width -  CELL_SPACING - COLLETION_VIEW_MARGINS * 2) / 2
        return CGSize(width: width, height: CELL_SIZE.height)
    }
}

/**
 * Cell for reports in FoodIntakeViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodIntakeCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    func configure(_ item: Food) {
        iconView.image = item.image ?? #imageLiteral(resourceName: "subImage")
        titleLabel.text = item.time.rawValue.capitalized
        valueLabel.text = item.items
    }

}
