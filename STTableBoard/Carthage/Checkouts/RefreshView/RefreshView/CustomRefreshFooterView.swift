//
//  RefreshView.swift
//  RefreshDemo
//
//  Created by ZouLiangming on 16/1/28.
//  Copyright © 2016年 ZouLiangming. All rights reserved.
//

import UIKit

public class CustomRefreshFooterView: CustomRefreshView {

    var state: RefreshState? {
        didSet {
            if state == .Refreshing {
                startAnimation()
                executeRefreshingCallback()
            } else if state == .Idle {
                circleImageView?.layer.removeAnimationForKey(kCustomRefreshAnimationKey)
            }
        }
    }

    var loadingText = LocalizedString(key: "Loading")
    public var showLoadingView = true {
        didSet {
            if oldValue != showLoadingView {
                if !showLoadingView {
                    showFooterView(false)
                } else {
                    if self.cellsCount() != 0 {
                        showFooterView(true)
                    } else {
                        showFooterView(false)
                    }
                }
                setNeedsLayout()
            }
        }
    }

    var isAutomaticallyRefresh: Bool = true
    var triggerAutomaticallyRefreshPercent: CGFloat = 0.1

    lazy var logoImageView: UIImageView? = {
        let image = self.getImage("refresh_logo")
        let imageView = UIImageView(image: image)
        self.addSubview(imageView)
        return imageView
    }()

    lazy var circleImageView: UIImageView? = {
        let image = self.getImage("refresh_circle")
        let imageView = UIImageView(image: image)
        self.addSubview(imageView)
        return imageView
    }()

    func getImage(name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: 3)
        let bundle = NSBundle(forClass: classForCoder)
        let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection)
        guard let newImage = image else {
            return UIImage()
        }
        return newImage
    }

    lazy var statusLabel: UILabel? = {
        let statusLabel = UILabel()
        statusLabel.font = statusLabel.font.fontWithSize(15)
        statusLabel.text = self.loadingText
        statusLabel.textColor = kCustomRefreshFooterStatusColor
        self.addSubview(statusLabel)
        return statusLabel
    }()

    func showFooterView(show: Bool) {
        if !show {
            scrollView?.insetBottom = 0
            sizeHeight = 0
            self.logoImageView?.hidden = true
            self.circleImageView?.hidden = true
            self.statusLabel?.hidden = true
        } else {
            scrollView?.insetBottom = kRefreshFooterHeight
            sizeHeight = kRefreshFooterHeight
            self.logoImageView?.hidden = false
            self.circleImageView?.hidden = false
            self.statusLabel?.hidden = false
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
        state = .Idle
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        placeSubviews()
    }

    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)

        if let newScrollView = newSuperview as? UIScrollView {
            removeObservers()
            sizeWidth = newScrollView.sizeWidth
            scrollView = newScrollView
            scrollView?.alwaysBounceVertical = true
            addObservers()

            scrollView?.insetBottom += kRefreshFooterHeight
            originY = scrollView!.contentHeight
        }
    }

    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)

        if state == .WillRefresh {
            state = .Refreshing
        }
    }

    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !userInteractionEnabled {
            return
        }

        if keyPath == kRefreshKeyPathContentSize {
            scrollViewContentSizeDidChange(change)
        }

        if keyPath == kRefreshKeyPathContentOffset {
            scrollViewContentOffsetDidChange(change)
        } else if keyPath == kRefreshKeyPathPanState {
            scrollViewPanStateDidChange(change)
        }
    }

    func executeRefreshingCallback() {
        if let start = start {
            start()
        }
    }

    func scrollViewContentOffsetDidChange(change: [String : AnyObject]?) {
        if state != .Idle || !isAutomaticallyRefresh || originY == 0 || cellsCount() == 0 || !showLoadingView {
            return
        }

        if scrollView!.insetTop + scrollView!.contentHeight > scrollView!.sizeHeight {
            let offsetY = scrollView!.contentHeight - scrollView!.sizeHeight + sizeHeight * triggerAutomaticallyRefreshPercent + scrollView!.insetBottom - sizeHeight
            if scrollView!.offsetY >= offsetY {
                if let old = change!["old"]!.CGPointValue {
                    if let new = change!["new"]!.CGPointValue {
                        if new.y < old.y {
                            return
                        }
                        beginRefreshing()
                    }
                }
            }
        }
    }

    func scrollViewContentSizeDidChange(change: [String : AnyObject]?) {
        originY = scrollView!.contentHeight
    }

    func scrollViewPanStateDidChange(chnage: [String : AnyObject]?) {
        if state != .Idle || cellsCount() == 0 || !showLoadingView {
            return
        }

        if scrollView?.panGestureRecognizer.state == UIGestureRecognizerState.Ended {
            if scrollView!.insetTop + scrollView!.contentHeight <= scrollView!.sizeHeight {
                if scrollView!.offsetY >= -scrollView!.insetTop {
                    beginRefreshing()
                }
            } else {
                if scrollView!.offsetY >= scrollView!.contentHeight + scrollView!.insetBottom - scrollView!.sizeHeight {
                    beginRefreshing()
                }
            }
        }
    }

    public class func footerWithLoadingText(loadingText: String, startLoading: () -> ()) -> CustomRefreshFooterView {
        let footer = footerWithRefreshingBlock(startLoading)
        footer.loadingText = loadingText
        return footer
    }

    public class func footerWithRefreshingBlock(startLoading: () -> ()) -> CustomRefreshFooterView {
        let footer = self.init()
        footer.start = startLoading
        return footer
    }

    func startAnimation() {
        placeSubviews()
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = 1
        rotateAnimation.repeatCount = Float(CGFloat.max)
        circleImageView?.layer.addAnimation(rotateAnimation, forKey: kCustomRefreshAnimationKey)
    }

    func addObservers() {
        let options = NSKeyValueObservingOptions([.New, .Old])
        scrollView?.addObserver(self, forKeyPath: kRefreshKeyPathContentOffset, options: NSKeyValueObservingOptions([.New, .Old]), context: nil)
        scrollView?.addObserver(self, forKeyPath: kRefreshKeyPathContentSize, options: options, context: nil)
        pan = scrollView?.panGestureRecognizer
        pan?.addObserver(self, forKeyPath: kRefreshKeyPathPanState, options: options, context: nil)
    }

    func removeObservers() {
        superview?.removeObserver(self, forKeyPath: kRefreshKeyPathContentOffset)
        superview?.removeObserver(self, forKeyPath: kRefreshKeyPathContentSize)
        pan?.removeObserver(self, forKeyPath: kRefreshKeyPathPanState)
        pan = nil
    }

    func placeSubviews() {
        if cellsCount() != 0 {
            let text = (statusLabel?.text)!
            let font = (statusLabel?.font)!
            let statusLabelWidth: CGFloat =  ceil(text.sizeWithAttributes([NSFontAttributeName:font]).width)
            let originX = (sizeWidth - statusLabelWidth - (circleImageView?.sizeWidth)! - kCustomRefreshFooterMargin) / 2.0
            logoImageView?.center = CGPoint(x: originX+13, y: 20)
            circleImageView?.center = CGPoint(x: originX+13, y: 20)
            statusLabel?.originX = logoImageView!.originX + (circleImageView?.sizeWidth)! + kCustomRefreshFooterMargin
            statusLabel?.size = CGSize(width: statusLabelWidth, height: kRefreshFooterHeight)
        }
    }

    func prepare() {
        autoresizingMask = .FlexibleWidth
        backgroundColor = UIColor.clearColor()
        isAutomaticallyRefresh = true
        triggerAutomaticallyRefreshPercent = 0.0
    }

    func beginRefreshing() {
        UIView.animateWithDuration(kCustomRefreshFastAnimationTime) {
            self.alpha = 1.0
        }

        pullingPercent = 1.0
        if let _ = window {
            state = .Refreshing
        } else {
            if state != .Refreshing {
                state = .WillRefresh
                setNeedsDisplay()
            }
        }
    }

    public func endRefreshing() {
        state = .Idle
    }
}
