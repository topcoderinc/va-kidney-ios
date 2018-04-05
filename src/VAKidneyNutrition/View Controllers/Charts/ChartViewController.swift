//
//  ChartViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/3/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents
import Charts
import HealthKit

/**
 * Charts screen
 *
 * - author: TCCODER
 * - version: 1.2
 *
 * changes:
 * 1.1:
 * - charts implementation
 *
 * 1.2:
 * - goal legend
 * - goal limit lines
 */
class ChartViewController: UIViewController, ChartAddItemViewControllerDelegate {

    /// outlets
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var goalLegend: UIView!
    @IBOutlet weak var goalLegendCircleView: UIView!
    @IBOutlet weak var goalTitleLabel: UILabel!

    /// the items
    private var items = [Report]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// the selected cell indexPath
    private var lastSelectedIndexPath: IndexPath?

    /// the related value type
    var quantityType: QuantityType?

    /// the data for the chart view
    private var data: LineChartData!

    /// the animation interval
    private var animationInterval: TimeInterval = 0.3

    /// the storage
    private var storage: QuantitySampleService = QuantitySampleStorage.shared

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        goalLegendCircleView.makeRound()
        goalLegend.isHidden = true
        initBackButtonFromChild()

        if let _ = quantityType {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItems))
        }

        noDataLabel.isHidden = true
        title = (quantityType?.title ?? NSLocalizedString("Chart", comment: "Chart")).uppercased()
        setupLineChartView(chartView: chart)
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
        guard let quantityType = quantityType else { return }
        storage.getPerMonthStatistics(quantityType, callback: { (data, units) in

            self.setData(stats: data)
            self.chart.chartDescription?.text = units
            self.noDataLabel.isHidden = !data.isEmpty
            self.addLimitLines(units)
        }) {
            self.noDataLabel.isHidden = false
        }
    }

    /// Add limit lines
    private func addLimitLines(_ units: String) {
        findRelatedGoal { (goal) in
            var goalsNumber = 0
            if var value = goal.min {
                if units == "mg" || units == HKUnit.literUnit(with: .milli).unitString {
                    value *= 1000
                }
                let leftAxis = self.chart.leftAxis
                let limit = ChartLimitLine(limit: Double(value))
                limit.lineColor = UIColor(hex: 0xc4262e)
                leftAxis.addLimitLine(limit)
                limit.label = "\(value.toStringClear()) (minimum)"
                limit.labelPosition = .leftTop
                limit.drawLabelEnabled = true
                self.chart.leftAxis.axisMinimum = min(self.chart.leftAxis.axisMinimum, Double(value))
                goalsNumber += 1
            }
            if var value = goal.max {
                if units == "mg" || units == HKUnit.literUnit(with: .milli).unitString {
                    value *= 1000
                }
                let leftAxis = self.chart.leftAxis
                let maxLimit = ChartLimitLine(limit: Double(value))
                maxLimit.label = "\(value.toStringClear()) (maximum)"
                maxLimit.drawLabelEnabled = true
                maxLimit.labelPosition = .leftBottom
                maxLimit.lineColor = UIColor(hex: 0xc4262e)
                leftAxis.addLimitLine(maxLimit)
                self.chart.leftAxis.axisMaximum = max(self.chart.leftAxis.axisMaximum, Double(value))
                goalsNumber += 1
            }
            self.goalLegend.isHidden = goalsNumber == 0 || !self.noDataLabel.isHidden
            self.goalTitleLabel.text = goalsNumber == 1 ? NSLocalizedString("Goal", comment: "Goal") : NSLocalizedString("Goals", comment: "Goals")
        }
    }

    /// Find related goal
    ///
    /// - Parameter callback: the callback to return related goal
    private func findRelatedGoal(callback: @escaping (Goal)->()) {
        guard let quantityType = quantityType else { return }

        FoodUtils.shared.getNutritionGoals { (goals) in
            for goal in goals {
                if let relatedQuantityId = goal.relatedQuantityId {
                    if relatedQuantityId == quantityType.id {
                        callback(goal)
                        return
                    }
                }
            }
        }
    }

    /// Open add form
    @objc func addItems() {
        if let vc = create(ChartAddItemViewController.self), let parent = UIViewController.getCurrentViewController() {
            vc.quantityType = self.quantityType
            vc.delegate = self
            parent.showViewControllerFromSide(vc, inContainer: parent.view, bounds: parent.view.bounds, side: .bottom, nil)
        }
    }

    /**
     Updates data for the chart

     - parameter stats: statistics to display
     */

    /// Updates data for the chart
    ///
    /// - Parameters:
    ///   - stats: the statistics to display
    public func setData(stats: [(Date, Double)]) {
        if !stats.isEmpty {

            var statistic = stats.sorted { $0.0.compare($1.0) == .orderedAscending }

            var xVals = [Double]()
            var values: [Double] = []

            for i in 0..<statistic.count {
                values.append(statistic[i].1)
                xVals.append(statistic[i].0.timeIntervalSinceReferenceDate)
            }

            var yVals = [ChartDataEntry]()
            for i in 0..<values.count {
                yVals.append(ChartDataEntry(x: xVals[i], y: values[i]))
            }

            let color = UIColor(hex: 0x003f72)
            let set1 = LineChartDataSet(values: yVals, label: NSLocalizedString("Actual", comment: "Actual"))
            set1.mode = .cubicBezier
            set1.lineWidth = 2
            set1.drawValuesEnabled = false
            set1.circleColors = [color]
            set1.drawCirclesEnabled = values.count == 1
            set1.colors = [color]
            set1.highlightEnabled = false
            let dataSets = [set1]

            let data = LineChartData(dataSets: dataSets)
            data.setValueFont(UIFont(name: Fonts.Regular, size: 14))

            chart?.leftAxis.axisMaximum = (values.max() ?? 0) + 10
            chart?.leftAxis.axisMinimum = max(Double(0), ((values.min() ?? 0) - 10))

            self.data = data
            updateChartWithData(data)
        }
        else {
            updateChartWithData(nil)
        }
    }

    /**
     Update chart with data

     - parameter data: the data
     */
    func updateChartWithData(_ data: LineChartData?) {
        if let data = data {
            chart?.data = data
            chart?.isHidden = false
            chart?.animate(yAxisDuration: animationInterval, easingOption: ChartEasingOption.easeOutExpo)
            noDataLabel?.isHidden = true
        }
        else {
            chart?.isHidden = true
            noDataLabel?.isHidden = false
        }
    }

    /**
     Setup charts view

     - parameter chartView: the charts view
     */
    func setupLineChartView(chartView: LineChartView) {
        let labelColor = Colors.black
        let labelsFont = UIFont(name: Fonts.Regular, size: 14)!

        let desc = Description()
        desc.text = ""
        chartView.chartDescription = desc
        chartView.noDataText = ""

        chartView.drawGridBackgroundEnabled = false

        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false

        chartView.rightAxis.enabled = false

        chartView.maxVisibleCount = 60

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom

        xAxis.labelPosition = .bottom
        xAxis.labelFont = labelsFont
        xAxis.labelTextColor = labelColor
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 24 * 60 * 60 * 30
        xAxis.valueFormatter = DateValueFormatter()

        xAxis.axisLineColor = UIColor(white: 1, alpha: 0.5)

        let leftAxis = chartView.leftAxis;
        leftAxis.axisMinimum = 0
        leftAxis.labelFont = labelsFont
        leftAxis.labelTextColor = labelColor
        leftAxis.setLabelCount(10, force: false)
        leftAxis.drawGridLinesEnabled = false
        leftAxis.axisLineWidth = 0.5

        leftAxis.labelPosition = .outsideChart
        leftAxis.axisLineColor = UIColor(white: 1, alpha: 0.5)
        leftAxis.spaceTop = 0.15

        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        chartView.legend.direction = .leftToRight
        chartView.legend.form = .circle
        chartView.legend.formSize = 12
        chartView.legend.textColor = labelColor
        chartView.legend.font = labelsFont
        chartView.legend.xEntrySpace = 19
    }

    // MARK: - ChartAddItemViewControllerDelegate

    /// Add item
    ///
    /// - Parameters:
    ///   - amount: the amount
    ///   - unit: the units
    ///   - date: the date
    func chartItemAdd(amount: Double, unit: String, date: Date) {
        if let quantityType = quantityType {
            let sample = QuantitySample.create(type: quantityType, amount: amount, unit: unit)
            sample.createdAt = date
            storage.addSample(sample, callback: { (success) in
                if success {
                    self.loadData()
                }

                FoodUtils.shared.updateGoals {}
            })
        }
    }
}

/**
 * Date formatter for Ox axis
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class DateValueFormatter: NSObject, IAxisValueFormatter {

    /// the date formatter
    private let dateFormatter = DateFormatter()

    /// Initializer
    override init() {
        super.init()
        dateFormatter.dateFormat = "MMM"
    }

    /// Get string value for axis
    ///
    /// - Parameters:
    ///   - value: the value
    ///   - axis: the axis
    /// - Returns: date
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
