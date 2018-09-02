//
//  SectionInfiniteTableViewModel.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/4/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIComponents

/**
 * Viewmodel for table with sections
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SectionInfiniteTableViewModel<T, C: UITableViewCell>: InfiniteTableViewModel<T, C> {

    /// load items callback
    var loadSectionItems: ((_ callback: @escaping ([[T]], [String])->(), _ failure: @escaping FailureCallback) -> ())!

    /// the items to show
    internal var sectionItems = [[T]]()
    internal var sectionTitles = [String]()

    /// Get item for indexPath
    ///
    /// - Parameter indexPath: the indexPath
    /// - Returns: the item
    internal override func getItem(indexPath: IndexPath) -> T {
        return sectionItems[indexPath.section][indexPath.row]
    }

    /// Loading next items
    internal override func loadNextItems(showLoadingIndicator: Bool = false) {
        if !loadCompleted {
            let requestId = UUID().uuidString
            self.requestId = requestId
            isLoading = true
            let loadingView = showLoadingIndicator ? UIViewController.getCurrentViewController()?.showLoadingView() : nil
            let callback: ([[T]], [String])->() = { items, sectionTitles in
                if self.requestId == requestId {
                    self.loadCompleted = true
                    self.sectionItems = items
                    self.sectionTitles = sectionTitles
                    self.initCellHeights()
                    self.updateTableHeight()
                    self.tableView.reloadData()
                    let count = items.map{$0.count}.reduce(0, +)
                    self.noDataLabel?.isHidden = count > 0

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
            loadSectionItems?(callback, failure)
        }
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    /// Get number of sections
    ///
    /// - Parameter tableView: the tableView
    /// - Returns: the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionItems.count
    }

    /**
     The number of rows

     - parameter tableView: the tableView
     - parameter section:   the section index

     - returns: the number of items
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItems[section].count
    }

    /// Load more items
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - cell: the cell
    ///   - indexPath: the indexPath
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableHeight != nil {
            if var sectionHeights = heights[indexPath.section] {
                sectionHeights[indexPath.row] = cell.bounds.height
                heights[indexPath.section] = sectionHeights
            }
            updateTableHeight()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
