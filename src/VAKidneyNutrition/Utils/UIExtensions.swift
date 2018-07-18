//
//  UIExtensions.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 02/04/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

/**
 A set of helpful extensions for classes from UIKit
 */

/**
 View transition type (from corresponding side)
 */
enum Transition {
    case right, left, bottom, none

    /// The reverse Transition to given
    ///
    /// - Returns: Transition
    func reverse() -> Transition {
        switch self {
        case .right:
            return .left
        case .left:
            return .right
        default:
            return .none
        }
    }
}

/**
 * Methods for loading and removing a view controller and its views,
 * and shortcut helpful methods for instantiating UIViewController
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - new method
 */
extension UIViewController {

    /**
     Show view controller from the side.
     See also dismissViewControllerToSide()

     - parameter viewController: the view controller to show
     - parameter side:           the side to move the view controller from
     - parameter bounds:         the bounds of the view controller
     - parameter callback:       the callback block to invoke after the view controller is shown and stopped
     */
    func showViewControllerFromSide(_ viewController: UIViewController,
                                    inContainer containerView: UIView, bounds: CGRect, side: Transition, _ callback:(()->())?) {
        // New view
        let toView = viewController.view!

        // Setup bounds for new view controller view
        toView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        var frame = bounds
        frame.origin.y = containerView.frame.height - bounds.height
        switch side {
        case .bottom:
            frame.origin.y = containerView.frame.size.height // From bottom
        case .left:
            frame.origin.x = -containerView.frame.size.width // From left
        case .right:
            frame.origin.x = containerView.frame.size.width // From right
        default:break
        }
        toView.frame = frame

        self.addChildViewController(viewController)
        containerView.addSubview(toView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0, options: .curveEaseOut, animations: { () -> Void in
                        switch side {
                        case .bottom:
                            frame.origin.y = containerView.frame.height - bounds.height + bounds.origin.y
                        case .left, .right:
                            frame.origin.x = 0
                        default:break
                        }
                        toView.frame = frame
        }) { (fin: Bool) -> Void in
            viewController.didMove(toParentViewController: self)
            callback?()
        }
    }

    /**
     Dismiss the view controller through moving it back to given side
     See also showViewControllerFromSide()

     - parameter viewController: the view controller to dismiss
     - parameter side:           the side to move the view controller to
     - parameter callback:       the callback block to invoke after the view controller is dismissed
     */
    func dismissViewControllerToSide(_ viewController: UIViewController, side: Transition, _ callback:(()->())?) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0, options: .curveEaseOut, animations: { () -> Void in
                        // Move back to bottom
                        switch side {
                        case .bottom:
                            viewController.view.frame.origin.y = self.view.frame.height
                        case .left:
                            viewController.view.frame.origin.x = -self.view.frame.size.width
                        case .right:
                            viewController.view.frame.origin.x = self.view.frame.size.width
                        default:break
                        }

        }) { (fin: Bool) -> Void in
            viewController.willMove(toParentViewController: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
            callback?()
        }
    }

    /// Replace given view controller with another view controller from a side with animation
    ///
    /// - Parameters:
    ///   - viewController: the view controller to replace
    ///   - newViewController: the view controller to load
    ///   - containerView: the container view
    ///   - bounds: the bounds of the view controller (if nil, them containerView bounds are used)
    ///   - side: the side to animate from, if nil, then no animation
    ///   - callback: the callback to invoke when animation finished
    func replaceFromSide(_ viewController: UIViewController?, withViewController newViewController: UIViewController,
                         inContainer containerView: UIView, bounds: CGRect? = nil, side: Transition?, _ callback:(()->())?) {
        let bounds = bounds ?? containerView.bounds
        if let side = side {
            self.showViewControllerFromSide(newViewController, inContainer: containerView, bounds: bounds, side: side, callback)
            if let vc = viewController {
                self.dismissViewControllerToSide(vc, side: side.reverse(), nil)
            }
        }
        else {
            self.loadViewController(newViewController, containerView)
            viewController?.removeFromParent()
            callback?()
        }
        self.view.layoutIfNeeded()
    }

    /**
     Add the view controller and view into the current view controller
     and given containerView correspondingly.
     Uses autoconstraints.

     - parameter childVC:       view controller to load
     - parameter containerView: view to load into
     */
    func loadViewController(_ childVC: UIViewController, _ containerView: UIView) {
        let childView = childVC.view
        childView?.autoresizingMask = [UIViewAutoresizing.flexibleWidth,  UIViewAutoresizing.flexibleHeight]
        loadViewController(childVC, containerView, withBounds: containerView.bounds)
    }

    /// Load view controller and add connstraints
    ///
    /// - Parameters:
    ///   - childVC: the view controller
    ///   - containerView: the container view
    func loadViewControllerWithConstraints(_ childVC: UIViewController, _ containerView: UIView) {
        guard let childView = childVC.view else { return }
        childView
            .translatesAutoresizingMaskIntoConstraints = false
        loadViewController(childVC, containerView, withBounds: containerView.bounds)
        containerView.addConstraint(NSLayoutConstraint(item: childView,
                                                       attribute: NSLayoutAttribute.top,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: containerView,
                                                       attribute: NSLayoutAttribute.top,
                                                       multiplier: 1.0,
                                                       constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: childView,
                                                       attribute: NSLayoutAttribute.leading,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: containerView,
                                                       attribute: NSLayoutAttribute.leading,
                                                       multiplier: 1.0,
                                                       constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: childView,
                                                       attribute: NSLayoutAttribute.trailing,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: containerView,
                                                       attribute: NSLayoutAttribute.trailing,
                                                       multiplier: 1.0,
                                                       constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: childView,
                                                       attribute: NSLayoutAttribute.bottom,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: containerView,
                                                       attribute: NSLayoutAttribute.bottom,
                                                       multiplier: 1.0,
                                                       constant: 0))
    }

    /**
     Add the view controller and view into the current view controller
     and given containerView correspondingly.
     Sets fixed bounds for the loaded view in containerView.
     Constraints can be added manually or automatically.

     - parameter childVC:       view controller to load
     - parameter containerView: view to load into
     - parameter bounds:        the view bounds
     */
    func loadViewController(_ childVC: UIViewController, _ containerView: UIView, withBounds bounds: CGRect) {
        let childView = childVC.view

        childView?.frame = bounds

        // Adding new VC and its view to container VC
        self.addChildViewController(childVC)
        containerView.addSubview(childView!)

        // Finally notify the child view
        childVC.didMove(toParentViewController: self)
    }

    /**
     Remove view controller and view from their parents
     */
    func removeFromParent() {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

    /**
     Instantiate given view controller.
     The method assumes that view controller is identified the same as its class
     and view is defined in the same storyboard.

     - parameter viewControllerClass: the class name
     - parameter storyboardName:      the name of the storyboard (optional)

     - returns: view controller or nil
     */
    func create<T: UIViewController>(_ viewControllerClass: T.Type, storyboardName: String? = nil) -> T? {
        let className = NSStringFromClass(viewControllerClass).components(separatedBy: ".").last!
        var storyboard = self.storyboard
        if let storyboardName = storyboardName {
            storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        }
        return storyboard?.instantiateViewController(withIdentifier: className) as? T
    }

    /**
     Instantiate given view controller and push into navigation stack

     - parameter viewControllerClass: the class name
     - parameter storyboardName:      the name of the storyboard (optional)

     - returns: view controller or nil
     */
    @discardableResult
    func pushViewController<T: UIViewController>(_ viewControllerClass: T.Type, storyboardName: String? = nil) -> T? {
        if let vc = create(viewControllerClass, storyboardName: storyboardName) {
            self.navigationController?.pushViewController(vc, animated: true)
            return vc
        }
        return nil
    }

    /**
     Instantiate given view controller.
     The method assumes that view controller is identified the same as its class
     and view is defined in "Main" storyboard.

     - parameter viewControllerClass: the class name

     - returns: view controller or nil
     */
    class func createFromMainStoryboard<T: UIViewController>(_ viewControllerClass: T.Type) -> T? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let className = NSStringFromClass(viewControllerClass).components(separatedBy: ".").last!
        return storyboard.instantiateViewController(withIdentifier: className) as? T
    }

    /**
     Get currently opened view controller

     - returns: the top visible view controller
     */
    class func getCurrentViewController() -> UIViewController? {

        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            return navigationController.visibleViewController
        }

        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {

            var currentController: UIViewController! = rootController

            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }

    /**
     Returns the navigation controller if it exists

     - returns: the navigation controller or nil
     */
    class func getNavigationController() -> UINavigationController? {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController  {
            return navigationController as? UINavigationController
        }
        return nil
    }

    /**
     Wraps the given view controller into NavigationController

     - returns: NavigationController instance
     */
    func wrapInNavigationController() -> UINavigationController {
        let navigation = UINavigationController(rootViewController: self)
        navigation.navigationBar.isTranslucent = false
        return navigation
    }

    /// Update navigation stack to contain only first and last view controllers
    func cleanNavigationStack() {
        if let list = self.navigationController?.viewControllers {
            if list.count > 1 {
                let updatedStack = [list.last!]
                self.navigationController?.setViewControllers(updatedStack, animated: false)
            }
        }
    }
}

/**
 * Extends UIView with shortcut methods
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - new method
 */
extension UIView {

    /**
     Adds bottom border to the view

     - parameter color:       the border color
     - parameter borderWidth: the size of the border
     */
    func addBottomBorder(color: UIColor = UIColor.black, borderWidth: CGFloat = 0.5) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: self.frame.height - borderWidth, width: self.frame.size.width, height: borderWidth)
        bottomBorder.backgroundColor = color.cgColor
        self.layer.addSublayer(bottomBorder)
    }

    /// Animate with default settings
    ///
    /// - Parameter animations: the animation callback
    class func animateWithDefaultSettings(animations: @escaping () -> Swift.Void) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: animations, completion: nil)
    }
}

/**
 * Extension to display alerts
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UIViewController {

    /**
     Displays alert with specified title & message

     - parameter title:      the title
     - parameter message:    the message
     - parameter completion: the completion callback
     */
    func showAlert(_ title: String, _ message: String, completion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default,
                                      handler: { (_) -> Void in
                                        alert.dismiss(animated: true, completion: nil)
                                        DispatchQueue.main.async {
                                            completion?()
                                        }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    /// Show loading view
    ///
    /// - Parameter view: the parent view
    /// - Returns: the loading view
    func showLoadingView(_ view: UIView? = nil) -> LoadingView? {
        return LoadingView(parentView: view ?? UIViewController.getCurrentViewController()?.view ?? self.view).show()
    }

    /**
     Create general failure callback that show alert with error message over the current view controller

     - parameter loadingView: the loading view parameter

     - returns: FailureCallback instance
     */
    func createGeneralFailureCallback(_ loadingView: LoadingView? = nil) -> FailureCallback {
        return { (errorMessage) -> () in
            self.showAlert(NSLocalizedString("Error", comment: "Error"), errorMessage)
            loadingView?.terminate()
        }
    }
}


/**
 * Class for a general loading view (for api calls).
 *
 * - author: TCCODER
 * - version: 1.0
 */
class LoadingView: UIView {

    /// loading indicator
    var activityIndicator: UIActivityIndicatorView!

    /// flag: true - the view is terminated, false - else
    var terminated = false

    /// flag: true - the view is shown, false - else
    var didShow = false

    /// the reference to the parent view
    var parentView: UIView?

    /**
     Initializer

     - parameter parentView: the parent view
     - parameter dimming:    true - need to add semitransparent overlay, false - just loading indicator
     */
    init(parentView: UIView?, dimming: Bool = true) {
        super.init(frame: parentView?.bounds ?? UIScreen.main.bounds)

        self.parentView = parentView

        setupUI(dimming: dimming)
    }

    /**
     Required initializer
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Adds loading indicator and changes colors

     - parameter dimming: true - need to add semitransparent overlay, false - just loading indicator
     */
    private func setupUI(dimming: Bool) {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.center
        self.addSubview(activityIndicator)

        if dimming {
            self.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        }
        else {
            activityIndicator.activityIndicatorViewStyle = .gray
            self.backgroundColor = UIColor.clear
        }
        self.alpha = 0.0
    }

    /**
     Removes the view from the screen
     */
    func terminate() {
        terminated = true
        if !didShow { return }
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
        }, completion: { success in
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
        })
    }

    /**
     Show the view

     - returns: self
     */
    func show() -> LoadingView {
        didShow = true
        if !terminated {
            if let view = parentView {
                view.addSubview(self)
                return self
            }
            UIApplication.shared.delegate!.window!?.addSubview(self)
        }
        return self
    }

    /**
     Change alpha after the view is shown
     */
    override func didMoveToSuperview() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0.75
        }
    }
}

/**
 * Extension adds methods that change navigation bar
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes support
 */
extension UIViewController {

    /// Add right button to the navigation bar
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - selector: the selector to invoke when tapped
    ///   - xOffset: Ox offset
    ///   - yOffset: Oy offset
    func addRightButton(image: UIImage, selector: Selector, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        // Right navigation button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView:
            createBarButton(image, selector: selector, xOffset: xOffset, yOffset: yOffset))
    }

    /// Create button for the navigation bar
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - selector: the selector to invoke when tapped
    ///   - xOffset: Ox offset
    ///   - yOffset: Oy offset
    /// - Returns: the button
    func createBarButton(_ image: UIImage, selector: Selector, xOffset: CGFloat = 0, yOffset: CGFloat = 0) -> UIView {
        // Right navigation button
        let size = CGSize(width: 40, height: 40)
        let customBarButtonView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let b = UIButton()
        b.addTarget(self, action: selector, for: UIControlEvents.touchUpInside)
        b.frame = CGRect(x: xOffset, y: yOffset, width: size.width, height: size.height);
        b.setImage(image, for: .normal)

        customBarButtonView.addSubview(b)
        return customBarButtonView
    }

    /// Initialize back button for current view controller that will be pushed
    func initBackButtonFromChild() {
        let customBarButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        // Button
        let button = UIButton()
        button.addTarget(self, action: #selector(UIViewController.backButtonAction), for: .touchUpInside)
        button.frame = CGRect(x: -24, y: 1.5, width: 60, height: 30)

        // Button title
        button.setTitle(" ", for: .normal)
        button.setImage(#imageLiteral(resourceName: "iconBack"), for: .normal)

        // Set custom view for left bar button
        customBarButtonView.addSubview(button)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBarButtonView)
    }

    /// "Back" button action handler
    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }

    /// Instantiate initial view controller from given storyboard
    ///
    /// - Parameter storyboardName: the name of the storyboard
    /// - Returns: view controller or nil
    func createInitialViewController(fromStoryboard storyboardName: String) -> UIViewController? {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController()
    }

    /// Open Profile screen
    ///
    /// - Parameters:
    ///   - animated: the animation flag
    ///   - completion: the completion callback
    func openProfileScreen(animated: Bool = true, completion: (()->())? = nil) {
        if let vc = self.createInitialViewController(fromStoryboard: "Profile") {
            self.present(vc, animated: animated, completion: completion)
        }
    }

    /// Open Home screen
    ///
    /// - Parameter completion: the completion callback
    func openHomeScreen(completion: (()->())? = nil) {
        HealthKitUtil.shared.authorizeHealthKit(callback: { (success) in
            if !success {
                print("ALL DATA WILL BE SAVED IN THE APP (HeaithKit is not enabled)")
            }
        }, failure: { (error) in
            showError(errorMessage: error)
        })
        if let vc = self.createInitialViewController(fromStoryboard: "Home") {
            vc.modalTransitionStyle = .flipHorizontal
            UIViewController.getCurrentViewController()?.present(vc, animated: true, completion: completion)
        }
    }

    /// Setup navigation bar
    func setupNavigation() {
        navigationController?.navigationBar.barTintColor = Colors.darkBlue
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()

        let item = UIBarButtonItem(customView: createBarButton(#imageLiteral(resourceName: "goalsIcon"), selector: #selector(openGoals), xOffset: 12, yOffset: 0))
        self.navigationItem.rightBarButtonItem = item

        let menuItem = UIBarButtonItem(customView: createBarButton(#imageLiteral(resourceName: "menuIcon"), selector: #selector(menuAction(_:)), xOffset: -12, yOffset: 0))
        self.navigationItem.leftBarButtonItem = menuItem
    }


    /// Open left menu
    @objc func menuAction(_ sender: UIButton) {
        MenuViewController.show()
    }

    /// Open "Goals" screen
    @objc func openGoals() {
        if let parent = MainViewControllerReference, let vc = parent.create(GoalsCollectionViewController.self, storyboardName: "Goals") {
            parent.showViewController(vc.wrapInNavigationController())
        }
    }
}

/**
 * Shortcut methods for UITableView
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UITableView {

    /**
     Prepares tableView to have zero margins for separator
     and removes extra separators after all rows
     */
    func separatorInsetAndMarginsToZero() {
        let tableView = self
        if tableView.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            tableView.separatorInset = UIEdgeInsets.zero
        }
        if tableView.responds(to: #selector(setter: UIView.layoutMargins)) {
            tableView.layoutMargins = UIEdgeInsets.zero
        }

        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    /**
     Register given cell class for the tableView.

     - parameter cellClass: a cell class
     */
    func registerCell(_ cellClass: UITableViewCell.Type) {
        let className = NSStringFromClass(cellClass).components(separatedBy: ".").last!
        let nib = UINib(nibName: className, bundle: nil)
        self.register(nib, forCellReuseIdentifier: className)
    }

    /// Register given header class for the tableView
    ///
    /// - Parameter headerClass: the header class
    func registerHeader(_ headerClass: UITableViewHeaderFooterView.Type) {
        let className = NSStringFromClass(headerClass).components(separatedBy: ".").last!
        let nib = UINib(nibName: className, bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: className)
    }

    /// Get cell of given class for indexPath
    ///
    /// - Parameters:
    ///   - indexPath: the indexPath
    ///   - cellClass: a cell class
    /// - Returns: a reusable cell
    func getCell<T: UITableViewCell>(_ indexPath: IndexPath, ofClass cellClass: T.Type) -> T {
        let className = NSStringFromClass(cellClass).components(separatedBy: ".").last!
        return self.dequeueReusableCell(withIdentifier: className, for: indexPath) as! T
    }
}

/**
 * Shortcut methods for UICollectionView
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - new method
 */
extension UICollectionView {

    /// Get cell of given class for indexPath
    ///
    /// - Parameters:
    ///   - indexPath: the indexPath
    ///   - cellClass: a cell class
    /// - Returns: a reusable cell
    func getCell<T: UICollectionViewCell>(_ indexPath: IndexPath, ofClass cellClass: T.Type) -> T {
        let className = NSStringFromClass(cellClass).components(separatedBy: ".").last!
        return self.dequeueReusableCell(withReuseIdentifier: className, for: indexPath) as! T
    }

    /// Calculate collection height
    ///
    /// - Parameters:
    ///   - n: the number of columns
    ///   - items: the number of items
    ///   - cellHeight: the cell height
    func getCollectionHeight(forColumns n: Int = 2, items: Int, cellHeight: CGFloat) -> CGFloat {
        let layout = (self.collectionViewLayout as! UICollectionViewFlowLayout)
        let margins = layout.sectionInset
        let spacing = CGSize(width: layout.minimumInteritemSpacing, height: layout.minimumLineSpacing)

        let rows = Int(max(0, floor(Float(items - 1) / Float(n)) + 1))
        let spaces = max(0, rows - 1)
        let height = margins.top + CGFloat(rows) * cellHeight + CGFloat(spaces) * spacing.height + margins.bottom
        return height
    }
}

/**
 * Separator inset fix
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ZeroMarginsCell: UITableViewCell {

    /// separator inset fix
    override var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsets.zero }
        set(newVal) {}
    }

    /**
     Setup UI
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}

/// type alias for image request callback
typealias ImageCallback = (UIImage?)->()

/**
 * Class for storing in-memory cached images
 *
 * - author: TCCODER
 * - version: 1.0
 */
class UIImageCache {

    /// Cache for images
    var CachedImages = [String: (UIImage?, [ImageCallback])]()

    /// the singleton
    class var sharedInstance: UIImageCache {
        struct Singleton { static let instance = UIImageCache() }
        return Singleton.instance
    }
}

/**
 * Extends UIImage with a shortcut method.
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UIImage {

    /**
     Load image asynchronously

     - parameter url:      image URL
     - parameter callback: the callback to return the image
     */
    class func loadFromURLAsync(_ url: URL, callback: @escaping ImageCallback) {
        let key = url.absoluteString

        // If there is cached data, then use it
        if let data = UIImageCache.sharedInstance.CachedImages[key] {
            if data.1.isEmpty { // Is image already loadded, then use it
                callback(data.0)
            }
            else { // If image is not yet loaded, then add callback to the list of callbacks
                var savedCallbacks: [ImageCallback] = data.1
                savedCallbacks.append(callback)
                UIImageCache.sharedInstance.CachedImages[key] = (nil, savedCallbacks)
            }
            return
        }
        // If the image is first time requested, then load it
        UIImageCache.sharedInstance.CachedImages[key] = (nil, [callback])
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {

            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                DispatchQueue.main.async { () -> Void in
                    guard let data = data, error == nil else {
                        callback(nil);
                        UIImageCache.sharedInstance.CachedImages.removeValue(forKey: key)
                        return
                    }
                    if let image = UIImage(data: data) {

                        // Notify all callbacks
                        for callback in UIImageCache.sharedInstance.CachedImages[key]!.1 {
                            callback(image)
                        }
                        UIImageCache.sharedInstance.CachedImages[key] = (image, [])
                    }
                    else {
                        for callback in UIImageCache.sharedInstance.CachedImages[key]!.1 {
                            callback(nil)
                        }
                        UIImageCache.sharedInstance.CachedImages.removeValue(forKey: key)
                        // Temporary commented because server generates a lot of not exising URLs.
                        // Should be uncommeted after the challenge.
                        // print("ERROR: Error occured while creating image from the data: \(data) url=\(url)")
                    }
                }
            }) .resume()
        })
    }

    /**
     Load image asynchronously.
     More simple method than loadFromURLAsync() that helps to cover common fail cases
     and allow to concentrate on success loading.

     - parameter urlString: the url string
     - parameter callback:  the callback to return the image
     */
    class func loadAsync(_ urlString: String?, callback: @escaping (UIImage?)->()) {
        if let urlStr = urlString {
            if urlStr.hasPrefix("http") {
                if let url = URL(string: urlStr) {
                    UIImage.loadFromURLAsync(url, callback: { (image: UIImage?) -> () in
                        callback(image)
                    })
                    return
                }
                else {
                    print("ERROR: Wrong URL: \(urlStr)")
                    callback(nil)
                }
            }
                // If urlString is not real URL, then try to load image from assets
            else if let image = UIImage(named: urlStr) {
                callback(image)
            }
        }
        else {
            callback(nil)
        }
    }

    /**
     Resize image

     - parameter sizeChange: the new size

     - returns: resized image
     */
    func imageResize(_ sizeChange: CGSize)-> UIImage {
        let imageObj = self

        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}

/**
 * Helpful methods in UILabel
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UILabel {

    /// Updates line spacing in the label
    ///
    /// - Parameter lineSpacing: the linespacing
    func setLineSpacing(lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = self.textAlignment
        let attributedString = NSMutableAttributedString(string: self.text ?? "", attributes: [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: self.textColor,
            .font: UIFont(name: self.font.fontName, size: self.font.pointSize)!
            ])
        self.attributedText = attributedString
    }
}

/**
 * Applies default family fonts for UILabels from IB.
 *
 * - author TCCODER
 * - version 1.0
 */
extension UILabel {

    /// Applies default family fonts
    open override func awakeFromNib() {
        super.awakeFromNib()
        applyDefaultFontFamily()
    }

    /// Applies default family fonts
    ///
    /// - Parameter aDecoder: the decoder
    /// - Returns: UILabel instance
    open override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let label = super.awakeAfter(using: aDecoder)
        self.applyDefaultFontFamily()
        return label
    }


    /**
     Applies default family fonts
     */
    func applyDefaultFontFamily() {
        self.font = UIView.getCustomFont(self.font)
    }
}

/**
 * Applies default family fonts for UILabels from IB.
 *
 * - author TCCODER
 * - version 1.0
 */
extension UITextField {

    /// Applies default family fonts
    open override func awakeFromNib() {
        super.awakeFromNib()
        applyDefaultFontFamily()
    }

    /// Applies default family fonts
    ///
    /// - Parameter aDecoder: the decoder
    /// - Returns: UILabel instance
    open override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let label = super.awakeAfter(using: aDecoder)
        self.applyDefaultFontFamily()
        return label
    }


    /**
     Applies default family fonts
     */
    func applyDefaultFontFamily() {
        guard let font = font else {
            return
        }
        self.font = UIView.getCustomFont(font)
    }
}

/**
 * Applies default family fonts for UILabels from IB.
 *
 * - author TCCODER
 * - version 1.0
 */
extension UIButton {

    /// Applies default family fonts
    open override func awakeFromNib() {
        super.awakeFromNib()
        applyDefaultFontFamily()
        if contentEdgeInsets.top == 0 {
            contentEdgeInsets.top = 3
        }
    }

    /// Applies default family fonts
    ///
    /// - Parameter aDecoder: the decoder
    /// - Returns: UILabel instance
    open override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let label = super.awakeAfter(using: aDecoder)
        self.applyDefaultFontFamily()
        return label
    }

    /**
     Applies default family fonts
     */
    func applyDefaultFontFamily() {
        guard let title = self.attributedTitle(for: .normal) as? NSMutableAttributedString, !title.string.isEmpty else {
            self.titleLabel?.applyDefaultFontFamily()
            return
        }
        var attributes = title.attributes(at: 0, effectiveRange: nil)
        guard let font = attributes[.font] as? UIFont else { return }

        let newFont = UIView.getCustomFont(font)
        attributes[.font] = newFont
        title.setAttributes(attributes, range: NSMakeRange(0, title.string.length))
        self.setAttributedTitle(title, for: .normal)
    }
}

/**
 * Applies default family fonts for UILabels from IB.
 *
 * - author TCASSEMBLER
 * - version 1.0
 */
extension UIBarButtonItem {

    /// Applies default family fonts
    open override func awakeFromNib() {
        super.awakeFromNib()
        applyDefaultFontFamily()
    }

    /// Applies default family fonts
    ///
    /// - Parameter aDecoder: the decoder
    /// - Returns: UILabel instance
    open override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let label = super.awakeAfter(using: aDecoder)
        self.applyDefaultFontFamily()
        return label
    }


    /**
     Applies default family fonts
     */
    func applyDefaultFontFamily() {
        guard var attributes = self.titleTextAttributes(for: .normal), !(self.title ?? "").isEmpty else {
            return
        }
        guard let font = attributes[NSAttributedStringKey.font.rawValue] as? UIFont else { return }

        let newFont = UIView.getCustomFont(font)

        var newAttributes = [NSAttributedStringKey:Any]()
        for (k,v) in attributes {
            let key = NSAttributedStringKey(rawValue: k)
            newAttributes[key] = v
        }
        newAttributes[NSAttributedStringKey.font] = newFont
        self.setTitleTextAttributes(newAttributes, for: .normal)
    }
}

/**
 * Helpful methods in UIView
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UIView {

    /// Find labels in the view
    ///
    /// - Returns: the list of labels
    func findLabels() -> [UILabel] {
        var labels = [UILabel]()
        for view in subviews {
            if let label = view as? UILabel {
                labels.append(label)
            }
            labels.append(contentsOf: view.findLabels())
        }
        return labels
    }

    /// Apply given font to all labels or to labels with given text
    ///
    /// - Parameters:
    ///   - font: the font
    ///   - text: the text of the target labels
    func applyFontToLabels(font: UIFont, forText text: String? = nil) {
        for label in findLabels() {
            if let text = text {
                if label.text == text {
                    label.font = font
                }
            }
            else {
                label.font = font
            }
        }
    }

    class func getCustomFont(_ font: UIFont) -> UIFont {
        if font.fontName.contains("Semibold", caseSensitive: false) {
            return UIFont(name: Fonts.Semibold, size: font.pointSize)!
        }
        else if font.fontName.contains("Bold", caseSensitive: false) {
            return UIFont(name: Fonts.Bold, size: font.pointSize)!
        }
        else if font.fontName.contains("Regular", caseSensitive: false) {
            return UIFont(name: Fonts.Regular, size: font.pointSize)!
        }
        else if font.fontName.contains("Light", caseSensitive: false) {
            return UIFont(name: Fonts.Light, size: font.pointSize)!
        }
        else {
            return UIFont(name: Fonts.Regular, size: font.pointSize)!
        }
    }
}
