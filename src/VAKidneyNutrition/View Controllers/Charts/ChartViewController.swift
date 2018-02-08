//
//  ChartViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/3/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Charts screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ChartViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var chart1View: UIImageView!
    @IBOutlet weak var chart2View: UIImageView!

    /// the items
    private var items = [Report]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// the selected cell indexPath
    private var lastSelectedIndexPath: IndexPath?

    /// the related report to open
    var report: Report?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        noDataLabel.isHidden = true

    }


    /// Load data
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }

    /// Load data
    private func loadData() {
        let loadingView = LoadingView(parentView: self.view, dimming: false).show()
        api.getReports(callback: { (reports) in
            loadingView.terminate()
            self.items = reports
            self.noDataLabel.isHidden = !self.items.isEmpty
            if self.report == nil {
                let lastId = UserDefaults.standard.value(forKey: kLastOpenedReportId) as? String
                self.report = reports.first
                if let lastId = lastId, let report = reports.filter({$0.id == lastId}).first {
                    self.report = report
                }
            }
            self.loadCharts()
            self.collectionView.reloadData()
            var index: Int?
            if let report = self.report {
                var i = 0
                for item in self.items {
                    if item.id == report.id {
                        index = i
                    }
                    i += 1
                }
            }
            if let index = index {
                DispatchQueue.main.async {
                    self.collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                }
            }
        }, failure: createGeneralFailureCallback(loadingView))
    }

    /// Load stub images for now
    private func loadCharts() {
        if let report = report {
            UserDefaults.standard.set(report.id, forKey: kLastOpenedReportId)
            UserDefaults.standard.synchronize()
            let chart = UIImage(named: "sampleChart\(report.id)") ?? UIImage(named: "sampleChart1")
            chart1View.image = chart
            chart2View.image = chart
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
        return items.count
    }

    /// Get cell
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    /// - Returns: the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        let cell = collectionView.getCell(indexPath, ofClass: ChartHeaderCollectionViewCell.self)
        let isSelected = lastSelectedIndexPath?.row == indexPath.row || self.report?.id == item.id
        if isSelected {
            lastSelectedIndexPath = indexPath
        }
        cell.configure(item, isSelected: isSelected)
        return cell
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let indexPath = lastSelectedIndexPath,
            let cell = collectionView.cellForItem(at: indexPath) as? ChartHeaderCollectionViewCell {
            cell.configure(cell.item, isSelected: false)
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? ChartHeaderCollectionViewCell {
            cell.configure(cell.item, isSelected: true)
        }
        lastSelectedIndexPath = indexPath
        self.report = items[indexPath.row]

        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        showReport(items[indexPath.row])
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

        let width = (collectionView.bounds.width - margins.left - margins.right) / 3
        return CGSize(width: width, height: collectionView.bounds.height)
    }

    /// Show report
    ///
    /// - Parameter item: the item
    private func showReport(_ item: Report) {
        loadCharts()
    }

}

/**
 * Cell for collection in ChartViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ChartHeaderCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!

    /// the item
    var item: Report!

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    ///   - isSelected: true - if selected
    func configure(_ item: Report, isSelected: Bool) {
        self.item = item
        titleLabel.text = item.title
        titleLabel.textColor = isSelected ? Colors.darkBlue : UIColor(r: 153, g: 153, b: 153)
        lineView.isHidden = !isSelected
    }
}
