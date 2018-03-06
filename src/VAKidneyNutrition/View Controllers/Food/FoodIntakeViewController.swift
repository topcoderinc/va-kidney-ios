//
//  FoodIntakeViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Food Intake screen
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - UI changes
 *
 * 1.2:
 * - integration changes
 */
class FoodIntakeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the cell size
    let CELL_SIZE: CGSize = CGSize(width: 170, height: 162.5)

    /// outlets
    @IBOutlet weak var collectionView: UICollectionView!

    /// the items to show
    private var items = [Food]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
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
        if let vc = create(FoodIntakeFormViewController.self) {
            if indexPath.row != 0 {
                vc.food = items[indexPath.row - 1]
            }
            navigationController?.pushViewController(vc, animated: true)
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
        let layout = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        let margins = layout.sectionInset
        let spacing = CGSize(width: layout.minimumInteritemSpacing, height: layout.minimumLineSpacing)
        
        let n: CGFloat = 2
        let width = (collectionView.bounds.width - margins.left - margins.right - (n - 1) * spacing.width) / n
        return CGSize(width: width, height: CELL_SIZE.height)
    }
}

/**
 * Cell for adding reports in FoodIntakeViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodAddIntakeCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var mainView: UIView!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.masksToBounds = false
        self.layer.masksToBounds = false
        mainView.roundCorners()
        shadowView.addShadow()
    }
}

/**
 * Cell for reports in FoodIntakeViewController
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes
 */
class FoodIntakeCollectionViewCell: FoodAddIntakeCollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet weak var imagesContainer: UIView!

    /// the related item
    private var item: Food!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.roundCorners()
        for view in imageViews {
            view.roundCorners()
        }
    }

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    func configure(_ item: Food) {
        self.item = item
        imagesContainer.isHidden = item.images.count == 1
        iconView.isHidden = item.images.count != 1
        if let first = item.images.first, item.images.count == 1 {
            loadImage(first, toView: iconView, item: item)
        }
        else {
            for view in imageViews {
                view.image = nil
            }
            for i in 0..<min(4, item.images.count) {
                if let view = imageViews.filter({$0.tag == i}).first {
                    loadImage(item.images[i], toView: view, item: item)
                }
            }
        }
        titleLabel.text = item.time.rawValue.capitalized
        valueLabel.text = item.items.map({$0.title}).joined(separator: ", ")
    }

    /// Load image
    ///
    /// - Parameters:
    ///   - image: the image or image URL
    ///   - imageView: the image view
    ///   - item: the related food item
    private func loadImage(_ image: Any, toView imageView: UIImageView, item: Food) {
        if let image = image as? UIImage {
            imageView.image = image
        }
        else if let url = image as? String {
            UIImage.loadAsync(url, callback: { (image) in
                if self.item.id == item.id {
                    imageView.image = image
                }
            })
        }
    }
}
