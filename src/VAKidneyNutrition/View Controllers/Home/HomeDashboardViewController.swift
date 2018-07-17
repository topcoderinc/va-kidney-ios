//
//  HomeDashboardViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * First Home screen
 *
 * - author: TCCODER
 * - version: 1.3
 *
 * changes:
 * 1.1:
 * - integration changes
 *
 * 1.2:
 * - API change
 *
 * 1.3:
 * - Measurements info in Home page
 */
class HomeDashboardViewController: UIViewController {

    /// outlets
    @IBOutlet weak var goalsView: UIView!
    @IBOutlet weak var bgColor: UIView!
    @IBOutlet var goalImages: [UIImageView]!
    @IBOutlet var goalTitles: [UILabel]!
    @IBOutlet var goalValues: [UILabel]!
    @IBOutlet var goalValueLabels: [UILabel]!
    @IBOutlet var goalViews: [UIView]!
    @IBOutlet var goalProgresses: [CircleProgress]!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var topHeight: NSLayoutConstraint!

    /// the items to show
    private var items = [HomeInfo]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        bgColor.backgroundColor = Colors.darkBlue
        updateUI()
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
        if isIPhone5() {
            topMargin.constant = 0
            topHeight.constant = 115
        }
        self.view.layoutIfNeeded()
        do {
            let loadingView = LoadingView(parentView: goalsView, dimming: false).show()
            api.getDashboardInfo(callback: { (list) in
                loadingView.terminate()
                self.items = list
                self.updateUI()
            }, failure: createGeneralFailureCallback(loadingView))
        }
        // load profile and number of points
        pointsLabel.text = "-"
        api.getRewards(callback: { (items) in
            let sum = items.map({$0.points}).reduce(0, +)
            self.pointsLabel.text = sum.toPointsText()
        }, failure: createGeneralFailureCallback())

        if let userInfo = AuthenticationUtil.sharedInstance.userInfo {
            self.nameLabel.text = userInfo.firstName
        }
    }

    /// Update UI
    private func updateUI() {
        let n = 4
        for i in 0..<n {
            goalViews[i].isHidden = true
        }
        if !items.isEmpty {
            for i in 0..<min(items.count, n) {
                goalViews.filter({$0.tag == i}).first?.isHidden = false
                let item = items[i]
                goalImages.filter({$0.tag == i}).first?.image = UIImage(named: item.iconName)
                goalTitles.filter({$0.tag == i}).first?.text = item.title
                goalValues.filter({$0.tag == i}).first?.text = item.value
                goalValueLabels.filter({$0.tag == i}).first?.text = item.value.isEmpty ? "" : item.valueText
                let percent = item.percent
                if let view = goalProgresses.filter({$0.tag == i}).first {
                    view.processValue = percent
                    view.mainColor = item.color
                }
            }
        }
    }

    /// Button action handler
    ///
    /// - parameter sender: the button
    @IBAction func infoButtonAction(_ sender: UIButton) {
        if sender.tag < items.count {
            let item = items[sender.tag]
            if !item.relatedQuantityIds.isEmpty {
                if let vc = create(ChartViewController.self, storyboardName: "Charts") {
                    vc.quantityTypes = item.relatedQuantityIds.map({QuantityType.fromId($0)})
                    vc.customTitle = item.title
                    vc.customChartTitles = item.quantityTitles
                    vc.type = .discreteValues
                    vc.info = item.info
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
