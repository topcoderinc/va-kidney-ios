//
//  HomeReportsViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Reports collection for Home screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class HomeReportsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the height
    let CELL_SIZE: CGFloat = 140

    /// outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDataLabel: UILabel!

    /// the items
    private var items = [Report]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        noDataLabel.isHidden = true
        loadData()
    }

    /// Load data
    private func loadData() {
        let loadingView = LoadingView(parentView: self.view, dimming: false).show()
        api.getReports(callback: { (items) in
            loadingView.terminate()
            self.items = items
            self.noDataLabel.isHidden = !items.isEmpty
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
        let cell = collectionView.getCell(indexPath, ofClass: HomeReportCollectionViewCell.self)
        cell.configure(items[indexPath.row], cellWidth: getCellWidth())
        return cell
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showReportDetails(items[indexPath.row])
    }

    /// Get cell size
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - collectionViewLayout: the layout
    ///   - indexPath: the indexPath
    /// - Returns: cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: getCellWidth(), height: CELL_SIZE)
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

    /// Open report details
    ///
    /// - Parameter report: the report
    func showReportDetails(_ report: Report) {
        MainViewControllerReference?.openCharts(report: report)
    }
}

/**
 * Cell for reports in Home screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - design related changes
 */
class HomeReportCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var smile: UIImageView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var unitsValueLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var buttonLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var suggestionButton: CustomButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var addDataButton: UIButton!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!

    /// the parent view controller
    var parent: UIViewController!

    /// the shown item
    var item: Report!

    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.masksToBounds = false
        self.layer.masksToBounds = false
        mainView.roundCorners()
        mainView.addBorder(color: UIColor(r: 204, g: 204, b: 204), borderWidth: 0.5)
        shadowView.addShadow()
        suggestionButton.backgroundColor = Colors.darkBlue
        addDataButton.backgroundColor = Colors.darkBlue
    }

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    ///   - cellWidth: the width of the cell
    func configure(_ item: Report, cellWidth: CGFloat) {
        self.item = item
        iconView.image = item.limitStatus.getIconImage()
        titleLabel.text = item.title
        unitsValueLabel.text = "\(item.units)"
        unitsLabel.text = "\(item.unitsLabel)"
        suggestionButton.isHidden = !item.showTwoButtons

        iconView.isHidden = !item.showTwoButtons

        separatorView.isHidden = !item.showTwoButtons

        if item.showTwoButtons {
            buttonLeftMargin.constant = cellWidth / 2
        }
        else {
            iconView.isHidden = true
            unitsValueLabel.text = " "
            buttonLeftMargin.constant = 0
            unitsLabel.text = NSLocalizedString("Report not added", comment: "Report not added") + "    "
        }
        iconWidth.constant = (iconView.isHidden || iconView.image == nil) ? 0 : 15
        smile.image = item.limitStatus.getSmile()
        self.layoutIfNeeded()
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
        showStub()
    }

    /// "Add new data" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func addNewData(_ sender: Any) {
        showStub()
    }
}
