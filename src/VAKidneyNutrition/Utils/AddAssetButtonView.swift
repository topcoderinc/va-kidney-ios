//
//  AddAssetButtonView.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/25/17.
//  Modified by TCCODER on 4/1/18.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIComponents
import MobileCoreServices
import Photos

/**
 * Delegate protocol for AddAssetButtonView
 *
 * - author: TCCODER
 * - version: 1.0
 */
public protocol AddAssetButtonViewDelegate {

    /**
     User has tapped on the view

     - parameter view: the view with button
     */
    func addAssetButtonTapped(_ view: AddAssetButtonView)

    /// Notify about selected image.
    /// WARNING! The method is invoked twice with different modalDismissed values
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - filename: the filename
    ///   - modalDismissed: true - if modal was dismissed, false - if not yet.
    func addAssetImageChanged(_ image: UIImage, filename: String, modalDismissed: Bool)
}


/**
 * View that contains a button that allows to add a photo
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - Bug fixed: authorization was requested after user selected a very first photo
 */
open class AddAssetButtonView: CustomView, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AddAssetButtonViewDelegate {

    /// The image name prefix
    let IMAGE_NAME_PREFIX = "IMG "

    /// the maximum image name length
    let IMAGE_NAME_LENGTH = 13

    /// the maximum size of the image
    let MAX_IMAGE_SIZE: CGSize = CGSize(width: 400, height: 400)

    /// the delegate
    open var delegate: AddAssetButtonViewDelegate? = nil

    /// added subviews
    internal var button: UIButton!
    internal var imageView: UIImageView?
    internal var removeButton: UIButton!

    /// the attached image
    open var image: UIImage?

    /// the last image
    fileprivate var previousImage: UIImage?

    /// supported media types
    internal var mediaTypes: [String] {
        return [kUTTypeImage as String]
    }

    /**
     Layout subviews
     */
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutImage()
        layoutButton()
    }

    /**
     Update selected image

     - parameter image: the image
     */
    open func setSelectedImage(_ image: UIImage?, resetPreviousImage: Bool = false) {
        if resetPreviousImage {
            previousImage = nil
        }
        else {
            previousImage = self.image
        }
        imageView?.layer.masksToBounds = true
        imageView?.contentMode = .scaleAspectFill
        imageView?.image = image
        self.image = image
    }

    /**
     Restore image
     */
    open func restoreImage() {
        imageView?.image = previousImage
        self.image = previousImage
        previousImage = nil
    }

    /**
     Reset previous image
     */
    open func resetPreviousImage() {
        previousImage = nil
    }

    /**
     Check if image was changed

     - returns: true - if has previous image (image was updated), false - else
     */
    open func isImageChanged() -> Bool {
        return previousImage != nil
    }

    /**
     Layout button and specify action handler method
     */
    internal func layoutButton() {
        if button == nil {
            button = UIButton(frame: self.bounds)
            button.addTarget(self, action: #selector(buttonActionHandler), for: .touchUpInside)
            self.addSubview(button)
            removeButton.superview?.bringSubview(toFront: removeButton)
            removeButton.isHidden = true
        }
        button.frame = self.bounds
    }

    /**
     Layout image view
     */
    internal func layoutImage() {
        let buttonSize: CGFloat = 30
        let buttonFrame = CGRect(x: self.bounds.width - buttonSize, y: self.bounds.height - buttonSize,
                                 width: buttonSize, height: buttonSize)

        if imageView == nil {
            imageView = UIImageView(frame: self.bounds)
            imageView?.image = self.image
            imageView?.contentMode = .scaleAspectFill
            self.addSubview(imageView!)
            self.sendSubview(toBack: imageView!)

            // Remove photo button

            removeButton = UIButton(frame: buttonFrame)
            removeButton.setImage(UIImage(named: "removePhoto"), for: UIControlState())
            removeButton.addTarget(self, action: #selector(removePhoto), for: .touchUpInside)
            self.addSubview(removeButton)
        }
        removeButton.frame = buttonFrame
        imageView?.frame = self.bounds
    }

    // MARK: Image selection

    /**
     Button action handler
     */
    @objc func buttonActionHandler() {
        UIViewController.getCurrentViewController()?.view.endEditing(true)
        (delegate ?? self).addAssetButtonTapped(self)
    }

    /**
     Check if can change photo

     - returns: true - if tapping on the view will show the dialog, false - will do nothing
     */
    func canChangePhoto() -> Bool {
        return true
    }

    /**
     Remove button action handler
     */
    @objc func removePhoto() {
        UIViewController.getCurrentViewController()?.view.endEditing(true)
        let alert = UIAlertController(title: nil, message: nil,
                                      preferredStyle: UIAlertControllerStyle.actionSheet)

        alert.addAction(UIAlertAction(title: "Delete Photo",
                                      style: UIAlertActionStyle.destructive,
                                      handler: { (action: UIAlertAction!) in
                                        self.setSelectedImage(nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        UIViewController.getCurrentViewController()?.present(alert, animated: true, completion: nil)
    }

    /**
     Show camera capture screen
     */
    func showCameraPicker() {
        self.showPickerWithSourceType(UIImagePickerControllerSourceType.camera)
    }

    /**
     Show photo picker
     */
    func showPhotoLibraryPicker() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == PHAuthorizationStatus.authorized {
                self.showPickerWithSourceType(UIImagePickerControllerSourceType.photoLibrary)
            }
        }
    }

    /**
     Show image picker

     - parameter sourceType: the type of the source
     */
    func showPickerWithSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.mediaTypes = self.mediaTypes
            imagePicker.sourceType = sourceType
            imagePicker.videoQuality = UIImagePickerControllerQualityType.typeMedium
            UIViewController.getCurrentViewController()?.present(imagePicker, animated: true,
                                                                 completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "This feature is supported on real devices only",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            UIViewController.getCurrentViewController()?.present(alert, animated: true, completion: nil)
        }
    }

    /**
     Image selected/captured

     - parameter picker: the picker
     - parameter info:   the info
     */
    open func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [String : Any]) {
        var resizedImage: UIImage?
        var filename = "\(IMAGE_NAME_PREFIX)\(UUID().uuidString)"
        if let mediaType = info[UIImagePickerControllerMediaType] {
            if (mediaType as AnyObject).description == kUTTypeImage as String {
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

                    if let url = info[UIImagePickerControllerReferenceURL] as? URL {
                        let result = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
                        let asset = result.firstObject
                        filename = asset?.value(forKey: "filename") as? String ?? filename
                    }
                    if filename.length > IMAGE_NAME_LENGTH {
                        filename = IMAGE_NAME_PREFIX + filename[..<filename.index(filename.startIndex, offsetBy: IMAGE_NAME_LENGTH)]
                    }

                    let newWidth = MAX_IMAGE_SIZE.width
                    let newHeight = newWidth * image.size.height / image.size.width
                    resizedImage = image.imageResize(CGSize(width: newWidth, height: newHeight))
                    self.setSelectedImage(resizedImage!)
                    self.delegate?.addAssetImageChanged(resizedImage!, filename: filename, modalDismissed: false)
                }
            }
        }
        if let resizedImage = resizedImage {
            picker.dismiss(animated: true, completion: {
                self.delegate?.addAssetImageChanged(resizedImage, filename: filename, modalDismissed: true)
            })
        }
    }

    /**
     Image selection canceled

     - parameter picker: the picker
     */
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: AddAssetButtonViewDelegate

    /**
     User has tapped on the view

     - parameter view: the view with button
     */
    open func addAssetButtonTapped(_ view: AddAssetButtonView) {
        // Open action sheet only if photo is not selected
        if canChangePhoto() {
            let alert = UIAlertController(title: nil, message: nil,
                                          preferredStyle: UIAlertControllerStyle.alert)

            alert.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default,
                                          handler: { (action: UIAlertAction!) in
                                            self.showCameraPicker()
            }))

            alert.addAction(UIAlertAction(title: "Choose Photo", style: .default,
                                          handler: { (action: UIAlertAction!) in
                                            self.showPhotoLibraryPicker()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            UIViewController.getCurrentViewController()?.present(alert, animated: true, completion: nil)
        }
    }

    /// Nothing to do. Only external delegate can implement this method to process the image
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - filename: the filename
    ///   - modalDismissed: true - if modal was dismissed, false - if not yet.
    open func addAssetImageChanged(_ image: UIImage, filename: String, modalDismissed: Bool) {
    }
}
