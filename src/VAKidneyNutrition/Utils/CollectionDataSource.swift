//
//  CollectionDataSource.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 3/30/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 * UICollectionView data source and delegate
 *
 * - author: TCCODER
 * - version: 1.0
 */
open class CollectionDataSource<T: UICollectionViewCell>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the collection view
    private let collectionView: UICollectionView

    /// the cell class
    private let cellClass: T.Type

    /// configuration callbacks
    let preConfigure: ((Any, IndexPath)->(T))?
    private let configure: (Any, T, IndexPath)->()

    /// the items to show
    var items = [Any]()

    /// the event handlers
    var selected: ((Any)->())?
    var hasData: ((Bool)->())?
    var calculateCellSize: ((Any, IndexPath)->(CGSize))?

    /// Initializer
    ///
    /// - Parameter tableView: the tableView
    @discardableResult
    public init(_ collectionView: UICollectionView, cellClass: T.Type, preConfigure: ((Any, IndexPath)->(T))? = nil, configure: @escaping (Any, T, IndexPath)->()) {
        self.collectionView = collectionView
        self.cellClass = cellClass
        self.preConfigure = preConfigure
        self.configure = configure
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    /// Set items
    ///
    /// - Parameter items: the items
    public func setItems(_ items: [Any]) {
        self.items = items
        hasData?(!items.isEmpty)
        self.collectionView.reloadData()
    }

    /// Set resource with data
    ///
    /// - Parameter resource: the resource file name
    func setResource(_ resource: String) {
        if let json = JSON.resource(named: resource) {
            setItems(json.arrayValue)
        }
    }

    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate

    /// Get the number of cells
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - section: the section
    /// - Returns: the number of cells
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    /// Get cell
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    /// - Returns: the cell
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        if let preConfigure = preConfigure {
            let cell = preConfigure(item, indexPath)
            configure(item, cell, indexPath)
            return cell
        }
        else {
            let cell = collectionView.getCell(indexPath, ofClass: T.self)
            configure(item, cell, indexPath)
            return cell
        }
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        selected?(item)
        collectionView.reloadData()
    }

    /// Get cell size
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - collectionViewLayout: the layout
    ///   - indexPath: the indexPath
    /// - Returns: cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.row]
        return calculateCellSize?(item, indexPath) ?? CGSize(width: 100, height: 100)
    }
}

