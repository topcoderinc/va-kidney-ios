//
//  DailyWorkoutViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/// Supported workouts
enum WorkoutType: String {
    case steps = "Steps", distance = "Distance", flights = "Flights Climbed"
}

/// the constant for last synced date
let kLastWorkoutSyncDate = "kLastWorkoutSyncDate"
let kLastWorkoutSyncType = "kLastWorkoutSyncType"

/// option: true - will save "last sync date" even if one particular activit is synchronized, false - else
let OPTION_SAVE_SYNC_DATE_WHEN_PARTICULAR_ACTIVITY_SYNCED = true
/// option: true - will use correct words for synchronization date label, false - will use "Auto synched" as in design.
let OPTION_CORRECT_SYNC_DATE_LABEL = true

/**
 * Daily Workout screen
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
 *
 * 1.3:
 * - synchronization date updated
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

    /// the timer to update UI
    private var timer: Timer?

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.roundCorners()
        shadowView.addShadow(size: 3, shift: 1.5, opacity: 1)
        setupNavigation()
        loadData()
        lastSyncInfoLabel.text = ""
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            self.updateUI()
        })
    }

    /// Stop timer
    ///
    /// - Parameter animated: the animation flag
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }

    /// Update UI
    private func updateUI() {
        lastSyncInfoLabel.text = ""
        let date: Date? = AuthenticationUtil.sharedInstance.getValueByKey(kLastWorkoutSyncDate)
        let syncType: Bool = AuthenticationUtil.sharedInstance.getValueByKey(kLastWorkoutSyncType) ?? false
        if let date = date {
            var perfix = syncType ? NSLocalizedString("Auto synched %@", comment: "Auto synched %@") : NSLocalizedString("Manually synched %@", comment: "Manually synched %@")
            if OPTION_CORRECT_SYNC_DATE_LABEL {
                perfix = syncType ? NSLocalizedString("Automatically synchronized\n%@", comment: "Automatically synchronized\n%@") : NSLocalizedString("Manually synchronized\n%@", comment: "Manually synchronized\n%@")
            }
            lastSyncInfoLabel.text = String(format: perfix, date.timeAgo(useFullText: true))
        }
        else {
            lastSyncInfoLabel.text = NSLocalizedString("Not synchronized", comment: "Not synchronized")
        }
    }

    /// Load data
    private func loadData() {
        api.getWorkout(callback: { (items) in
            self.items = items
            self.collectionView.reloadData()
            self.collectionView.isScrollEnabled = false
            self.collectionViewHeight.constant = self.collectionView.getCollectionHeight(items: self.items.count, cellHeight: self.CELL_SIZE.height)

            self.syncFromHK(automatically: true)
        }, failure: createGeneralFailureCallback())
    }

    /// Synchronize
    private func syncFromHK(automatically: Bool) {
        let g = DispatchGroup()
        g.enter()
        HealthKitUtil.shared.getDistance(callback: { (distance) in
            self.items.filter({$0.title == WorkoutType.distance.rawValue}).first?.value = Float(distance)
            g.leave()
        })
        g.enter()
        HealthKitUtil.shared.getSteps(callback: { (steps) in
            self.items.filter({$0.title == WorkoutType.steps.rawValue}).first?.value = Float(steps)
            g.leave()
        })
        g.enter()
        HealthKitUtil.shared.getFlights(callback: { (flights) in
            self.items.filter({$0.title == WorkoutType.flights.rawValue}).first?.value = Float(flights)
            g.leave()
        })
        g.notify(queue: DispatchQueue.main) {
            self.collectionView.reloadData()
            self.saveLastSyncDate(automaticalSync: automatically)
        }
    }

    /// Sync data
    ///
    /// - Parameter item: the item to sync
    fileprivate func sync(with item: Workout) {
        if let type = WorkoutType(rawValue: item.title) {
            switch type {
            case .distance:
                HealthKitUtil.shared.getDistance(callback: { (distance) in
                    self.items.filter({$0.title == WorkoutType.distance.rawValue}).first?.value = Float(distance)
                    self.collectionView.reloadData()
                    if OPTION_SAVE_SYNC_DATE_WHEN_PARTICULAR_ACTIVITY_SYNCED {
                        self.saveLastSyncDate(automaticalSync: false)
                    }
                })
            case .steps:
                HealthKitUtil.shared.getSteps(callback: { (steps) in
                    self.items.filter({$0.title == WorkoutType.steps.rawValue}).first?.value = Float(steps)
                    self.collectionView.reloadData()
                    if OPTION_SAVE_SYNC_DATE_WHEN_PARTICULAR_ACTIVITY_SYNCED {
                        self.saveLastSyncDate(automaticalSync: false)
                    }
                })
            case .flights:
                HealthKitUtil.shared.getFlights(callback: { (flgihts) in
                    self.items.filter({$0.title == WorkoutType.flights.rawValue}).first?.value = Float(flgihts)
                    self.collectionView.reloadData()
                    if OPTION_SAVE_SYNC_DATE_WHEN_PARTICULAR_ACTIVITY_SYNCED {
                        self.saveLastSyncDate(automaticalSync: false)
                    }
                })
            }
        }
    }

    /// Update last sync date
    private func saveLastSyncDate(automaticalSync: Bool) {
        AuthenticationUtil.sharedInstance.saveValueForKey(Date(), key: kLastWorkoutSyncDate)
        AuthenticationUtil.sharedInstance.saveValueForKey(automaticalSync, key: kLastWorkoutSyncType)
        updateUI()
    }

    /// "Sync Data" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func syncAllAction(_ sender: Any) {
        syncFromHK(automatically: false)
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
        cell.parent = self
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
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - UI changes
 *
 * changes:
 * 1.2:
 * - partial data synchronization implementation
 */
class WorkoutCollectionViewCell: GoalCollectionViewCell {

    var parent: DailyWorkoutViewController?
    private var item: Workout!

    /// Update UI
    ///
    /// - Parameters:
    ///   - item: the item to show
    ///   - cellWidth: the width of the cell
    func configure(_ item: Workout, cellWidth: CGFloat) {
        self.item = item
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

    /// Sync action
    ///
    /// - Parameter sender: the button
    override func syncAction(_ sender: Any) {
        parent?.sync(with: self.item)
    }
}
