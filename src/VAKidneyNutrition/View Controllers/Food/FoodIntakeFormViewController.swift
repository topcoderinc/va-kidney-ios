//
//  FoodIntakeFormViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit

/// possible time for the meal
enum FoodIntakeTime: String {
    case breakfast = "breakfast", lunch = "lunch", dinner = "dinner", snacks = "snacks", casual = "casual"
}

/**
 * Food Intake form
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FoodIntakeFormViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!

    @IBOutlet weak var itemsField: UITextView!
    @IBOutlet weak var liquidItemsField: UITextView!

    @IBOutlet var mealTimeCheckboxes: [UIImageView]!
    @IBOutlet weak var imageButton: AddAssetButtonView!

    /// the food to edit
    var food: Food?

    /// the reference date
    var date = Date()

    // the index of the button
    private var selectedMealTime: Int?

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        self.navigationItem.rightBarButtonItem = item
        updateUI()
    }

    /// Update UI
    private func updateUI() {
        dateLabel.text = DateFormatters.shortDate.string(from: date)
        dayLabel.text = Date().isSameDay(date: date) ? NSLocalizedString("Today", comment: "Today") : ""
        timeLabel.text = DateFormatters.time.string(from: date)
    }

    /// Done action
    ///
    /// - Parameter sender: the button
    @objc func doneAction(_ sender: Any) {
        self.view.endEditing(true)
        let meal = itemsField.text ?? ""
        let liquid = liquidItemsField.text ?? ""
        if selectedMealTime == nil || (meal.isEmpty && liquid.isEmpty) {
            showError(errorMessage: NSLocalizedString("Please fill all fields", comment: "Please fill all fields"))
            return
        }

        let food = Food(id: "")
        food.items = meal + ((!meal.isEmpty && !liquid.isEmpty) ? ", " : "") + liquid
        switch selectedMealTime ?? 0 {
        case 0:
            food.time = .breakfast
        case 1:
            food.time = .lunch
        case 2:
            food.time = .dinner
        case 3:
            food.time = .snacks
        case 4:
            food.time = .casual
        default:
            break
        }
        food.date = date
        food.image = imageButton.image

        api.saveFood(food: food, callback: { (_) in
            self.navigationController?.popViewController(animated: true)
        }, failure: createGeneralFailureCallback())
    }

    /// "Change Date" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func changeDateAction(_ sender: Any) {
        self.view.endEditing(true)
        showStub() // date picker
    }

    /// "Change Time" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func changeTimeAction(_ sender: Any) {
        self.view.endEditing(true)
        showStub() // time picker
    }

    /// Meal time button action handler
    ///
    /// - parameter sender: the button
    @IBAction func mealTimeAction(_ sender: UIButton) {
        self.view.endEditing(true)
        selectedMealTime = sender.tag
        for item in mealTimeCheckboxes {
            item.image = sender.tag == item.tag ? #imageLiteral(resourceName: "checkboxSelected") : #imageLiteral(resourceName: "checkbox")
        }
    }

    /// Dismiss keyboard
    ///
    /// - Parameters:
    ///   - touches: the touches
    ///   - event: the event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
