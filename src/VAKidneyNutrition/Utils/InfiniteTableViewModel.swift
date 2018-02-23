//
//  InfiniteTableViewModel.swift
//  VAKidneyNutrition
//
//  Created by Volkov Alexander on 2/23/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Convenience viewmodel for table view controllers
 *
 * - author: TCCODER
 * - version: 1.0
 */
class InfiniteTableViewModel<T, C: UITableViewCell>: NSObject, UITableViewDataSource, UITableViewDelegate {

    // the table view
    var tableView: UITableView!
    var tableHeight: NSLayoutConstraint?

    /// the extra height added to the table
    var extraHeight: CGFloat = 0

    /// selection handler
    var onSelect: ((_ indexPath: IndexPath, _ item: T) -> ())?

    /// cell configuration
    var configureCell: ((_ indexPath: IndexPath, _ item: T, _ items: [T], _ cell: C) -> ())?

    /// fetch items callback
    var fetchItems: ((_ offset: Any?, _ limit: Int, _ callback: @escaping ([T], Any)->(), _ failure: @escaping FailureCallback) -> ())!

    /// load items callback
    var loadItems: ((_ callback: @escaping ([T])->(), _ failure: @escaping FailureCallback) -> ())!

    /// the reference to "no data" label
    var noDataLabel: UILabel?

    /// the number of items to load at once
    internal var LIMIT = 10

    /// the items to show
    internal var items = [T]()

    /// the last used offset
    internal var offset: Any?

    /// flag: true - the loading completed (no more data), false - else
    internal var loadCompleted = false

    /// flag: is currently loading
    internal var isLoading = false

    /// the minimum height of the cell
    internal var cellMinHeight: CGFloat = 44

    /// the request ID
    private var requestId = ""

    /// the heights of the cell
    internal var heights = [Int: [Int:CGFloat]]()

    /// binds data to table view
    ///
    /// - Parameter tableView: tableView to bind to
    /// - Parameter sequence: data sequence
    func bindData(to tableView: UITableView) {
        self.tableView = tableView
        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentOffset.y = -tableView.contentInset.top
        loadData()
    }

    /// Load data
    internal func loadData() {
        self.noDataLabel?.isHidden = true
        self.offset = nil
        self.loadCompleted = false
        self.items.removeAll()
        self.initCellHeights()
        self.updateTableHeight()
        tableView.reloadData()

        loadNextItems(showLoadingIndicator: true)
    }

    /// Loading next items
    private func loadNextItems(showLoadingIndicator: Bool = false) {
        if !loadCompleted {
            let requestId = UUID().uuidString
            self.requestId = requestId
            isLoading = true
            let loadingView = showLoadingIndicator ? UIViewController.getCurrentViewController()?.showLoadingView() : nil
            let callback: ([T], Any)->() = { list, offset in
                if self.requestId == requestId {
                    self.offset = offset
                    self.loadCompleted = list.count < self.LIMIT
                    if !list.isEmpty {
                        self.items.append(contentsOf: list)
                        if showLoadingIndicator {
                            self.initCellHeights()
                            self.updateTableHeight()
                        }
                        self.tableView.reloadData()
                    }

                    self.noDataLabel?.isHidden = self.items.count > 0

                    self.isLoading = false
                    self.tableView.tableFooterView = nil
                }
                loadingView?.terminate()
            }
            let failure: FailureCallback = { (errorMessage) -> () in
                showError(errorMessage: errorMessage)
                self.isLoading = false
                self.tableView.tableFooterView = nil
                loadingView?.terminate()
            }
            if let fetch = self.fetchItems {
                fetch(offset, LIMIT, callback, failure)
            }
            else {
                if offset == nil {
                    loadItems?({ items in
                        callback(items, items.count)
                    }, failure)
                }
                else {
                    callback([], 0)
                }
            }
        }
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    /// Get number of sections
    ///
    /// - Parameter tableView: the tableView
    /// - Returns: the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /**
     The number of rows

     - parameter tableView: the tableView
     - parameter section:   the section index

     - returns: the number of items
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    /**
     Get cell for given indexPath

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath

     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getCell(indexPath, ofClass: C.self)
        let value = items[indexPath.row]
        configureCell?(indexPath, value, items, cell)
        return cell
    }

    /// Open details screen
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - indexPath: the indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = items[indexPath.row]
        self.onSelect?(indexPath, value)
    }

    /// Load more items
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - cell: the cell
    ///   - indexPath: the indexPath
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableHeight != nil {
            if var sectionHeights = heights[indexPath.section] {
                sectionHeights[indexPath.row] = cell.bounds.height
                heights[indexPath.section] = sectionHeights
            }
            updateTableHeight()
        }
        if indexPath.row + 1 == items.count && !isLoading {
            loadNextItems()
        }
    }

    // MARK: - Table height

    /// Initialize heights array
    private func initCellHeights() {
        heights.removeAll()
        let n = self.numberOfSections(in: tableView)
        for i in 0..<n {
            var sectionHeights = [Int:CGFloat]()
            for j in 0..<getItems(inSection: i).count {
                sectionHeights[j] = self.cellMinHeight
            }
            heights[i] = sectionHeights
        }
    }

    /// Get items in given section
    ///
    /// - Parameter section: the section
    /// - Returns: the number of items in section
    private func getItems(inSection section: Int) -> [T] {
        return items
    }

    /// Update table height
    private func updateTableHeight() {
        if let tableHeight = tableHeight {
            var height: CGFloat = 0
            for (_,list) in heights{
                for (_,h) in list {
                    height += h
                }
            }
            tableHeight.constant = height + extraHeight
        }
    }
}

