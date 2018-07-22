//
//  MedicationsCollectionViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Medication collection
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MedicationsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the cell size
    let CELL_SIZE: CGSize = CGSize(width: 170, height: 160)

    /// outlets
    @IBOutlet weak var collectionView: UICollectionView!

    /// the items to show
    private var items = [Medication]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        loadData()
    }

    /// Load data
    private func loadData() {
        api.getMedicationForToday(callback: { (items) in
            self.items = items
            self.collectionView.reloadData()
        }, failure: createGeneralFailureCallback())
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
        let cell = collectionView.getCell(indexPath, ofClass: MedicationCollectionViewCell.self)
        cell.parent = self
        cell.configure(items[indexPath.row])
        return cell
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        editMedication(items[indexPath.row])
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

    /// Open Edit screen
    ///
    /// - Parameter item: the item
    fileprivate func editMedication(_ item: Medication) {
        if let vc = create(EditMedicationViewController.self) {
            vc.medication = item
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

/**
 * Cell for reports in MedicationsCollectionViewController
 *
 * - author: TCCODER
 * - version: 1.0
 */
class MedicationCollectionViewCell: UICollectionViewCell {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var mainView: CustomView!
    
    /// the references to parent and shown item
    var parent: MedicationsCollectionViewController!
    var item: Medication!

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    func configure(_ item: Medication) {
        self.item = item
        titleLabel.text = item.title
        valueLabel.text = item.times.map({"\($0.getHourText())  \($0.getUnitsText())"}).joined(separator: "\n")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.roundCorners()
    }
    
    /// "More" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func moreAction(_ sender: UIButton) {

        ContextMenuViewController.show([ContextItem(title: NSLocalizedString("Halt this medication", comment: "Halt this medication")) {
            showStub()
            },
            ContextItem(title: NSLocalizedString("Drag Position", comment: "Drag Position")) {
                showStub()
            }], from: sender)
    }

    /// "Edit" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func editAction(_ sender: Any) {
        parent.editMedication(item)
    }
}

