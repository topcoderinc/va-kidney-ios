//
//  CustomProgressView.swift
//  UIComponents
//
//  Created by TCCODER on 12/24/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation

/**
 * Progress view
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class CustomProgressView: UIView {

    /// the background color
    @IBInspectable public var bgColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)

    /// the progress color
    @IBInspectable public var progressColor = UIColor(red: 148/255, green: 148/255, blue: 148/255, alpha: 1)

    /// the progress
    public var progress: Float = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    /// the progress view
    private var progressView: UIView!

    /// Layout subviews
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = bgColor
        let percent = CGFloat(max(min(1, progress), 0))
        let frame = CGRect(x: 0, y: 0, width: self.bounds.width * percent, height: self.bounds.height)
        if progressView == nil {
            progressView = UIView(frame: frame)
            progressView.backgroundColor = progressColor
            addSubview(progressView)
        }
        else {
            UIView.animate(withDuration: 0.3) {
                self.progressView.frame = frame
            }
        }
    }
}
