//
//  ChartViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/3/18.
//  Modified by TCCODER on 03/04/18.
//  Modified by TCCODER on 4/1/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents
import Charts
import HealthKit

/// Possible types of the chart
enum ChartType {
    case monthStatistic, discreteValues
}

/**
 * Charts screen
 *
 * - author: TCCODER
 * - version: 1.3
 *
 * changes:
 * 1.1:
 * - charts implementation
 *
 * 1.2:
 * - goal legend
 * - goal limit lines
 *
 * 1.3:
 * - bug fixes
 */
class ChartViewController: UIViewController, ChartAddItemViewControllerDelegate {

    /// outlets
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var goalLegend: UIView!
    @IBOutlet weak var goalLegendCircleView: UIView!
    @IBOutlet weak var goalTitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var topMargin: NSLayoutConstraint!

    /// the items
    private var items = [Report]()

    /// the reference to API
    private let api: ServiceApi = CachingServiceApi.shared

    /// the selected cell indexPath
    private var lastSelectedIndexPath: IndexPath?

    /// the type of the chart
    var type: ChartType = .monthStatistic

    /// the related value types
    var quantityTypes = [QuantityType]()

    /// the custom titles
    var customTitle: String?
    var customChartTitles = [String]()

    /// the info to show
    var info: String?

    /// the data for the chart view
    private var data: LineChartData!

    /// the animation interval
    private var animationInterval: TimeInterval = 0.3

    /// the storage
    private var storage: QuantitySampleService = QuantitySampleStorage.shared

    /// the line colors
    private var colors = [UIColor(hex: 0x003f72), UIColor(hex: 0x007220)]

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        goalLegendCircleView.makeRound()
        goalLegend.isHidden = true
        initBackButtonFromChild()

        if !quantityTypes.isEmpty {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItems))
        }

        noDataLabel.isHidden = true
        title = (customTitle ?? quantityTypes.first?.title ?? NSLocalizedString("Chart", comment: "Chart")).uppercased()
        setupLineChartView(chartView: chart)

        if let info = info {
            infoLabel.text = info
            topMargin.constant = 1000
        }
        infoLabel.isHidden = info == nil
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
        guard !quantityTypes.isEmpty else { return }

        let g = DispatchGroup()
        var list = [[(Date, Double)]]()
        var lastUnits = ""


        for quantityType in quantityTypes {
            g.enter()
            switch type {
            case .monthStatistic:
                storage.getPerMonthStatistics(quantityType, callback: { (data, units) in
                    list.append(data)
                    lastUnits = units
                    g.leave()
                }) {
                    g.leave()
                }
            case .discreteValues:
                storage.getDiscreteValues(quantityType, callback: { (data, units) in
                    list.append(data)
                    lastUnits = units
                    g.leave()
                }) {
                    g.leave()
                }
            }
        }
        g.notify(queue: .main) {
            let sum = list.map({$0.count}).reduce(0, +)
            if sum > 0 {
                self.setData(data: list)
                self.chart.chartDescription?.text = lastUnits
                self.noDataLabel.isHidden = !list.isEmpty
                self.addLimitLines(lastUnits)
            }
            else {
                self.noDataLabel.isHidden = false
            }
        }
    }

    /// Add limit lines
    private func addLimitLines(_ units: String) {
        findRelatedGoal { (goal) in
            var goalsNumber = 0
            let font = UIFont(name: Fonts.Regular, size: 16)!
            var goalMax: Float? = nil
            if let value = goal.max {
                goalMax = value
                if units == "mg" || units == HKUnit.literUnit(with: .milli).unitString {
                    goalMax = value * 1000
                }
            }
            if var value = goal.min {
                if units == "mg" || units == HKUnit.literUnit(with: .milli).unitString {
                    value *= 1000
                }
                let leftAxis = self.chart.leftAxis
                let limit = ChartLimitLine(limit: Double(value))
                limit.valueFont = font
                limit.lineColor = UIColor(hex: 0xc4262e)
                leftAxis.addLimitLine(limit)
                limit.label = "\(value.toStringClear()) (minimum)"
                limit.labelPosition = .leftBottom
                limit.drawLabelEnabled = true
                let (minValue, _) = self.getExtendedLimits(min: Double(value), max: goalMax != nil ? max(Double(goalMax!), self.chart.leftAxis.axisMaximum): self.chart.leftAxis.axisMaximum)
                self.chart.leftAxis.axisMinimum = min(minValue, self.chart.leftAxis.axisMinimum)
                goalsNumber += 1
            }
            if var value = goal.max {
                if units == "mg" || units == HKUnit.literUnit(with: .milli).unitString {
                    value *= 1000
                }
                let leftAxis = self.chart.leftAxis
                let maxLimit = ChartLimitLine(limit: Double(value))
                maxLimit.valueFont = font
                maxLimit.label = "\(value.toStringClear()) (maximum)"
                maxLimit.drawLabelEnabled = true
                maxLimit.labelPosition = .leftTop
                maxLimit.lineColor = UIColor(hex: 0xc4262e)
                leftAxis.addLimitLine(maxLimit)
                let (_, maxValue) = self.getExtendedLimits(min: self.chart.leftAxis.axisMinimum, max: Double(value))
                self.chart.leftAxis.axisMaximum = max(maxValue, self.chart.leftAxis.axisMaximum)
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
        guard !quantityTypes.isEmpty else { return }


        FoodUtils.shared.getNutritionGoals { (goals) in
            for goal in goals {
                if let relatedQuantityId = goal.relatedQuantityId {
                    for quantityType in self.quantityTypes {
                        if relatedQuantityId == quantityType.id {
                            callback(goal)
                            return
                        }
                    }
                }
            }
        }
    }

    /// Open add form
    @objc func addItems() {
        if let vc = create(ChartAddItemViewController.self), let parent = UIViewController.getCurrentViewController() {
            vc.quantityTypes = self.quantityTypes
            vc.customChartTitles = self.customChartTitles
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
    ///   - data: the statistics to display
    public func setData(data: [[(Date, Double)]]) {
        let sum = data.map({$0.count}).reduce(0, +)
        if sum > 0 {

            var dataSets = [LineChartDataSet]()
            var minValue: Double = Double.infinity
            var maxValue: Double = 0
            var i = 0
            for stats in data {
                var statistic = stats.sorted { $0.0.compare($1.0) == .orderedAscending }

                var xVals = [Double]()
                var values: [Double] = []

                for i in 0..<statistic.count {
                    values.append(statistic[i].1)
                    switch self.type {
                    case .monthStatistic:
                        xVals.append(statistic[i].0.toChartMonthValue())
                    case .discreteValues:
                        xVals.append(statistic[i].0.toChartDayValue())
                    }
                }

                var yVals = [ChartDataEntry]()
                for i in 0..<values.count {
                    yVals.append(ChartDataEntry(x: xVals[i], y: values[i]))
                }

                let color = self.colors[i % self.colors.count]
                var label = NSLocalizedString("Actual", comment: "Actual")
                if i < customChartTitles.count { label = customChartTitles[i] }
                let set1 = LineChartDataSet(values: yVals, label: label)
                set1.mode = LineChartDataSet.Mode.horizontalBezier
                set1.lineWidth = self.type == .discreteValues ? 0 : 2
                set1.drawValuesEnabled = false
                set1.circleColors = [color]
                set1.drawCirclesEnabled = values.count == 1 || self.type == .discreteValues
                set1.colors = [color]
                set1.highlightEnabled = false
                dataSets.append(set1)
                minValue = min(minValue, values.min() ?? 0)
                maxValue = max(maxValue, values.max() ?? 0)
                i += 1
            }

            let data = LineChartData(dataSets: dataSets)
            data.setValueFont(UIFont(name: Fonts.Regular, size: 16))

            let (correctedMinValue, correctedMaxValue) = getExtendedLimits(min: minValue, max: maxValue)
            chart?.leftAxis.axisMaximum = correctedMaxValue
            chart?.leftAxis.axisMinimum = max(Double(0), correctedMinValue)

            self.data = data
            updateChartWithData(data)
        }
        else {
            updateChartWithData(nil)
        }
    }

    /// Get extended limits
    ///
    /// - Parameters:
    ///   - min: the minimum value
    ///   - max: the maximum value
    /// - Returns: the extended limits
    private func getExtendedLimits(min: Double, max: Double) -> (Double, Double) {
        let maxValue = max
        let minValue = min
        let delta = maxValue - minValue
        var oYPaddingValue = delta * 0.1
        if oYPaddingValue == 0 {
            oYPaddingValue = 10
        }
        return (minValue - oYPaddingValue, maxValue + oYPaddingValue)
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
        let labelsFont = UIFont(name: Fonts.Regular, size: 16)!

        let desc = Description()
        desc.text = ""
        chartView.chartDescription = desc
        chartView.noDataText = ""

        chartView.drawGridBackgroundEnabled = false

        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false

        chartView.rightAxis.enabled = false
        chartView.extraRightOffset = 20
        chartView.extraLeftOffset = 20

        chartView.maxVisibleCount = 60
        chartView.chartDescription?.font = labelsFont

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom

        xAxis.labelPosition = .bottom
        xAxis.labelFont = labelsFont
        xAxis.labelTextColor = labelColor
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = false
        xAxis.granularity = 1
        xAxis.valueFormatter = self.type == .monthStatistic ? DateValueFormatter() : DayValueFormatter()

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
    ///   - amounts: the amounts
    ///   - unit: the units
    ///   - date: the date
    func chartItemAdd(amounts: [Double], unit: String, date: Date) {
        if amounts.count == quantityTypes.count {
            let g = DispatchGroup()
            var success = true
            for i in 0..<quantityTypes.count {
                g.enter()
                let quantityType = quantityTypes[i]
                let amount = amounts[i]
                let sample = QuantitySample.create(type: quantityType, amount: amount, unit: unit)
                sample.createdAt = date
                storage.addSample(sample, callback: { (res) in
                    g.leave()
                    if !res { success = false }
                })
            }
            g.notify(queue: .main) {
                if success {
                    self.loadData()
                }
                FoodUtils.shared.updateGoals {}
            }
        }
        else {
            print("Inconsistency error")
        }
    }
}

/**
 * Date formatter for Ox axis
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - month date rendering issue fixed
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
        let date = Date.fromChartMonthValue(value)
        return dateFormatter.string(from: date)
    }
}

/**
 * Day formatter for Ox axis
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class DayValueFormatter: NSObject, IAxisValueFormatter {

    /// the date formatter
    private let dateFormatter = DateFormatter()

    /// Initializer
    override init() {
        super.init()
        dateFormatter.dateFormat = "EEE"
    }

    /// Get string value for axis
    ///
    /// - Parameters:
    ///   - value: the value
    ///   - axis: the axis
    /// - Returns: date
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date.fromChartDayValue(value)
        return dateFormatter.string(from: date)
    }
}
