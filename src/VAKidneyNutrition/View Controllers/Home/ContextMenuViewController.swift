//
//  ContextMenuViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/24/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIComponents

/// Context item
struct ContextItem {
    let title: String
    let action: ()->()
}

/**
 * Context menu
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ContextMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// the size of the cell
    static let CELL_SIZE: CGSize = CGSize(width: 100, height: 30)

    /// the shift use to compensate wider buttons
    static let SHIFT: CGSize = CGSize(width: 9, height: 8)

    /// outlets
    @IBOutlet weak var tableView: UITableView!

    /// the items to show
    private var items = [ContextItem]()

    /// true - light version, false - dark
    private var isLight: Bool = false

    /// the overlay button
    private var overlayButton: UIButton!

    /// Show context menu
    ///
    /// - Parameters:
    ///   - items: the items
    ///   - isLight: true - light version, false - dark
    ///   - targetView: the targetView
    class func show(_ items: [ContextItem], isLight: Bool = false, from targetView: UIView) {
        if let parent = UIViewController.getCurrentViewController(),
            let vc = parent.create(ContextMenuViewController.self, storyboardName: "Home") {
            vc.items = items
            vc.isLight = isLight

            vc.overlayButton = UIButton(frame: parent.view.bounds)
            vc.overlayButton.addTarget(vc, action: #selector(ContextMenuViewController.closeAction(_:)), for: .touchUpInside)
            parent.view.addSubview(vc.overlayButton)
            let targetRect = targetView.superview?.convert(targetView.frame, to: parent.view) ?? parent.view.bounds
            let width = (isLight ? 1.5 : 1) * ContextMenuViewController.CELL_SIZE.width
            var rect = CGRect(x: targetRect.origin.x + targetRect.width - width - ContextMenuViewController.SHIFT.width,
                              y: targetRect.origin.y + targetRect.height - ContextMenuViewController.SHIFT.height,
                              width: width,
                              height: CGFloat(items.count) * ContextMenuViewController.CELL_SIZE.height)
            if rect.origin.x < 0 {
                rect.origin.x = 0
            }
            parent.loadViewController(vc, parent.view, withBounds: rect)
        }
    }

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentOffset.y = -tableView.contentInset.top
    }

    /// Close context menu
    ///
    /// - Parameter sender: the sender
    @objc func closeAction(_ sender: Any) {
        self.overlayButton.removeFromSuperview()
        self.removeFromParent()
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

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
        let cell = tableView.getCell(indexPath, ofClass: ContextItemCell.self)
        let item = items[indexPath.row]
        cell.configure(item)
        if isLight {
            cell.button.setTitleColor(UIColor.black, for: .normal)
            cell.button.setTitleColor(UIColor.black, for: .selected)
            cell.button.selectedBgColor = Colors.lightGray
        }
        return cell
    }

    /**
     Cell selection handler

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.action()
        closeAction(self)
    }
}

/**
 * Cell for table in ContextMenuViewController
 *
 * - author TCCODER
 * - version 1.0
 */
class ContextItemCell: ZeroMarginsCell {

    /// outlets
    @IBOutlet weak var button: CustomButton!

    /// Update UI with given data
    ///
    /// - Parameter item: the data to show in the cell
    func configure(_ item: ContextItem) {
        button.setTitle(item.title, for: .selected)
    }
}
