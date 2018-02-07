//
//  HomeSuggestionsViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Home Suggestions screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HomeSuggestionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the height
    let CELL_SIZE: CGFloat = 213

    /// outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noSuggestionsLabel: UILabel!

    /// the items
    private var items = [Suggestion]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        noSuggestionsLabel.isHidden = true
        loadData()
    }

    /// Load data
    private func loadData() {
        let loadingView = LoadingView(parentView: self.view, dimming: false).show()
        api.getMainSuggestions(callback: { (items) in
            loadingView.terminate()
            self.items = items
            self.noSuggestionsLabel.isHidden = !items.isEmpty
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
        let cell = collectionView.getCell(indexPath, ofClass: HomeSuggestionCollectionViewCell.self)
        cell.configure(items[indexPath.row])
        return cell
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showSuggestionDetails(items[indexPath.row])
    }

    /// Get cell size
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - collectionViewLayout: the layout
    ///   - indexPath: the indexPath
    /// - Returns: cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        let margins = layout.sectionInset

        let width = collectionView.bounds.width - margins.left - margins.right
        return CGSize(width: width, height: CELL_SIZE)
    }

    /// Show suggestion details
    ///
    /// - Parameter item: the item
    private func showSuggestionDetails(_ item: Suggestion) {
        showStub()
    }
}

/**
 * Cell for collection in HomeSuggestionCollectionViewCell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HomeSuggestionCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageContainer: UIView!

    /// the shown item
    private var item: Suggestion!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.masksToBounds = false
        self.layer.masksToBounds = false
        imageContainer.roundCorners()
        mainView.roundCorners()
        imageContainer.addBorder()
        shadowView.addShadow()
    }

    /// Update UI
    ///
    /// - Parameter item: the item to show
    func configure(_ item: Suggestion) {
        self.item = item
        UIImage.loadAsync(item.imageUrl) { (image) in
            if self.item.imageUrl == item.imageUrl {
                self.iconView.image = image
            }
        }
        titleLabel.text = item.title
        textLabel.text = item.text
        textLabel.setLineSpacing(lineSpacing: 2)
    }
}
