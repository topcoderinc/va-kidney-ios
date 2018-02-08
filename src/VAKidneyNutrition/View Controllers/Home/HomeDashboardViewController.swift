//
//  HomeDashboardViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

// option: true - will use singular words for top goals, false - will always use plural
let OPTION_USE_SINGULAR_FOR_TOP_GOALS = false

/**
 * First Home screen
 *
 * - author: TCCODER
 * - version: 1.0
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
    @IBOutlet weak var pointsLabel: CustomButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var topHeight: NSLayoutConstraint!

    /// the goals
    private var goals = [Goal]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        bgColor.backgroundColor = Colors.darkBlue
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
            api.getGoals(callback: { (goals, _) in
                loadingView.terminate()
                self.goals = goals
                self.updateUI()
            }, failure: createGeneralFailureCallback(loadingView))
        }
        // load profile and number of points
        pointsLabel.setTitle("-", for: .normal)
        api.getRewards(callback: { (items) in
            let sum = items.map({$0.points}).reduce(0, +)
            self.pointsLabel.setTitle(sum.toPointsText(), for: .normal)
        }, failure: createGeneralFailureCallback())

        if let userInfo = AuthenticationUtil.sharedInstance.userInfo {
            self.welcomeLabel.text = "\(NSLocalizedString("Welcome", comment: "Welcome")) \(userInfo.firstName),"
        }
    }

    /// Update UI
    private func updateUI() {
        let n = 4
        for i in 0..<n {
            goalViews[i].isHidden = true
        }
        if !goals.isEmpty {
            for i in 0..<min(goals.count, n) {
                goalViews[i].isHidden = false
                let item = goals[i]
                goalImages.filter({$0.tag == i}).first?.image = UIImage(named: item.iconName)
                goalTitles.filter({$0.tag == i}).first?.text = item.title
                goalValues.filter({$0.tag == i}).first?.text = "\(item.value.toString())/\(item.targetValue.toString())"
                if OPTION_USE_SINGULAR_FOR_TOP_GOALS && item.value == 1 {
                    goalValueLabels.filter({$0.tag == i}).first?.text = item.valueText1
                }
                else {
                    goalValueLabels.filter({$0.tag == i}).first?.text = item.valueTextMultiple
                }
                let percent = min(1, item.value / max(1, item.targetValue))
                if let view = goalProgresses.filter({$0.tag == i}).first {
                    view.processValue = percent
                    view.mainColor = item.color
                }
            }
        }
    }

}
