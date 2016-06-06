//
//  CustomRefreshLoadingView.swift
//  RefreshView
//
//  Created by bruce on 16/5/20.
//  Copyright © 2016年 ZouLiangming. All rights reserved.
//

import UIKit

public class CustomRefreshLoadingView: UIView {
    var scrollView: UIScrollView?
    var imageViewLogo: UIImageView!
    var imageViewLoading: UIImageView!
    public var offsetX: CGFloat?
    public var offsetY: CGFloat?
    private let loadingWidth: CGFloat = 26.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }

    private func prepare() {
        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }

    private func placeSubviews() {
        var originX: CGFloat = 0
        var originY: CGFloat = 0
        if let offsetX = offsetX {
            originX = offsetX
        } else {
            originX = (sizeWidth - loadingWidth) / 2.0
        }
        if let offsetY = offsetY {
            originY = offsetY
        } else {
            originY = (sizeHeight - loadingWidth) / 2.0 - 30
        }
        self.imageViewLogo.frame = CGRect(x: originX, y: originY, width: loadingWidth, height: loadingWidth)
        self.imageViewLoading.frame = CGRect(x: originX, y: originY, width: loadingWidth, height: loadingWidth)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)

        if let newScrollView = newSuperview as? UIScrollView {
            scrollView = newScrollView
            scrollView?.bounces = false
            sizeWidth = newScrollView.sizeWidth
            sizeHeight = newScrollView.sizeHeight
            commonInit()
            backgroundColor = scrollView?.backgroundColor
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        placeSubviews()
    }

    private func commonInit() {
        self.imageViewLogo = UIImageView()
        self.imageViewLoading = UIImageView()
        self.imageViewLogo.image = getImage("loading_logo")
        self.imageViewLoading.image = getImage("loading_circle")
        self.imageViewLogo.backgroundColor = UIColor.clearColor()
        self.imageViewLoading.backgroundColor = UIColor.clearColor()
        self.addSubview(self.imageViewLogo)
        self.addSubview(self.imageViewLoading)
        self.placeSubviews()
    }

    private func getImage(name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: 3)
        let bundle = NSBundle(forClass: self.classForCoder)
        guard let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection) else { return UIImage() }

        return image
    }

    public func startAnimation() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = 1
        rotateAnimation.repeatCount = Float(CGFloat.max)
        self.imageViewLoading.layer.addAnimation(rotateAnimation, forKey: "rotation")
    }

    public func stopAnimation() {
        UIView.animateWithDuration(0.5, animations: {
            self.alpha = 0
            self.scrollView?.bounces = true
        }) { (competition) -> Void in
            self.imageViewLoading.layer.removeAnimationForKey("rotation")
            self.removeFromSuperview()
            self.alpha = 1
        }
    }
}
