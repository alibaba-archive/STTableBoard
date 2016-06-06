//
//  RefreshView.swift
//  RefreshDemo
//
//  Created by ZouLiangming on 16/1/28.
//  Copyright © 2016年 ZouLiangming. All rights reserved.
//

import UIKit

public class CustomRefreshHeaderView: CustomRefreshView {

    var customBackgroundColor = UIColor.clearColor()
    var angle: CGFloat = 0
    var circleLayer: CAShapeLayer?
    var state: RefreshState? {
        willSet {
            willSetRefreshState(newValue)
        }
        didSet {
            didSetRefreshState()
        }
    }

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

    func willSetRefreshState(newValue: RefreshState?) {
        if newValue == .Idle {
            if state != .Refreshing {
                return
            }
            UIView.animateWithDuration(kCustomRefreshSlowAnimationTime, animations: {
                self.scrollView?.insetTop += self.insetTDelta
                self.pullingPercent = 0.0
                self.alpha = 0.0
                }, completion: { (Bool) -> () in
                    self.circleImageView?.layer.removeAnimationForKey(kCustomRefreshAnimationKey)
                    self.circleImageView?.hidden = true
                    self.circleLayer?.hidden = false
            })
        }
    }

    func didSetRefreshState() {
        if state == .Refreshing {
            UIView.animateWithDuration(kCustomRefreshFastAnimationTime, animations: {
                let top = (self.scrollViewOriginalInset?.top)! + self.sizeHeight
                self.scrollView?.insetTop = top
                self.scrollView?.offsetY = -top
                }, completion: { (Bool) -> () in
                    self.circleImageView?.hidden = false
                    self.circleLayer?.hidden = true
                    self.startAnimation()
                    self.executeRefreshingCallback()
            })
        }
    }

    func getImage(name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: 3)
        let bundle = NSBundle(forClass: classForCoder)
        let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection)
        guard let newImage = image else {
            return UIImage()
        }
        return newImage
    }

    func initCircleLayer() {
        if circleLayer == nil {
            circleLayer = CAShapeLayer()
        }
        circleLayer?.shouldRasterize = false
        circleLayer?.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(circleLayer!)
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
            originX = 0
            scrollView = newScrollView
            scrollView?.alwaysBounceVertical = true
            scrollViewOriginalInset = scrollView?.contentInset
            originInset = scrollView?.contentInset

            addObservers()
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

        if hidden {
            return
        }

        if keyPath == kRefreshKeyPathContentOffset {
            scrollViewContentOffsetDidChange(change)
        } else if keyPath == kRefreshKeyPathPanState {
            scrollViewPanStateDidChange(change)
        }
    }

    func executeRefreshingCallback() {
        if let newStart = start {
            newStart()
        }
    }

    func changeCircleLayer(value: CGFloat) {
        let startAngle = kPai/2
        let endAngle = kPai/2+2*kPai*CGFloat(value)
        let ovalRect = CGRect(x: round(sizeWidth/2-6), y: 26, width: 12, height: 12)
        let x = ovalRect.midX
        let y = ovalRect.midY
        let point = CGPoint(x: x, y: y)
        let radius = ovalRect.width
        let ovalPath = UIBezierPath(arcCenter: point, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        circleLayer?.path = ovalPath.CGPath
        circleLayer?.strokeColor = UIColor(red: 56/255, green: 56/255, blue: 56/255, alpha: 1).CGColor
        circleLayer?.fillColor = nil
        circleLayer?.lineWidth = 2
        circleLayer?.lineCap = kCALineCapRound
    }

    func scrollViewContentSizeDidChange(chnage: [String : AnyObject]?) { }
    func scrollViewPanStateDidChange(chnage: [String : AnyObject]?) { }

    func scrollViewContentOffsetDidChange(change: [String : AnyObject]?) {
        if self.state == .Refreshing {
            if let _ = window {
                var insetT = -scrollView!.offsetY > scrollViewOriginalInset?.top ? -scrollView!.offsetY : scrollViewOriginalInset?.top
                insetT = insetT > sizeHeight + (scrollViewOriginalInset?.top)! ? sizeHeight + (scrollViewOriginalInset?.top)! : insetT
                scrollView?.insetTop = insetT!
                insetTDelta = scrollViewOriginalInset!.top - insetT!
                return
            } else {
                return
            }
        }

        scrollViewOriginalInset = scrollView?.contentInset
        let offsetY = scrollView!.offsetY
        let happenOffsetY = -scrollViewOriginalInset!.top
        let realOffsetY = happenOffsetY - offsetY - kRefreshNotCircleHeight

        if realOffsetY > 0 {
            if state != .Pulling {
                let value = realOffsetY / (kRefreshHeaderHeight - 20)
                if value < 1 {
                    changeCircleLayer(value)
                } else {
                    changeCircleLayer(1)
                }
            } else {
                changeCircleLayer(1)
            }
        }

        if offsetY > happenOffsetY {
            return
        }

        //let normal2pullingOffsetY = happenOffsetY - sizeHeight
        let currentPullingPercent = (happenOffsetY - offsetY) / (sizeHeight - 5)
        alpha = currentPullingPercent * 0.8

        if scrollView!.dragging {
            pullingPercent = currentPullingPercent
            if pullingPercent >= 1 {
                state = .Pulling
            } else {
                state = .Idle
            }
//            if state == .Idle && offsetY < normal2pullingOffsetY {
//                state = .Pulling
//            } else if state == .Pulling && offsetY >= normal2pullingOffsetY {
//                state = .Idle
//            }
        } else if state == .Pulling {
            beginRefreshing()
        } else if pullingPercent < 1 {
            pullingPercent = currentPullingPercent
        }
    }

    public class func headerWithRefreshingBlock(startLoading: () -> (), customBackgroundColor: UIColor = UIColor.clearColor()) -> CustomRefreshHeaderView {
        let header = self.init()
        header.start = startLoading
        header.customBackgroundColor = customBackgroundColor
        return header
    }

    func startAnimation() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = -angle
        rotateAnimation.toValue = -angle + CGFloat(M_PI * 2.0)
        rotateAnimation.duration = 1
        rotateAnimation.repeatCount = Float(CGFloat.max)
        circleImageView?.layer.addAnimation(rotateAnimation, forKey: kCustomRefreshAnimationKey)
    }

    func addObservers() {
        let options = NSKeyValueObservingOptions([.New, .Old])
        scrollView?.addObserver(self, forKeyPath: kRefreshKeyPathContentOffset, options: options, context: nil)
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
        if customBackgroundColor != UIColor.clearColor() {
            backgroundColor = customBackgroundColor
        } else {
            backgroundColor = scrollView?.backgroundColor
        }

        logoImageView?.center = CGPoint(x: sizeWidth/2, y: 32)
        circleImageView?.center = CGPoint(x: sizeWidth/2, y: 32)
        circleImageView?.hidden = true
        initCircleLayer()
        originY = -sizeHeight
    }

    func prepare() {
        autoresizingMask = .FlexibleWidth
        sizeHeight = kRefreshHeaderHeight
    }

    func beginRefreshing() {
        UIView.animateWithDuration(kCustomRefreshFastAnimationTime) { () -> Void in
            self.alpha = 1.0
        }

        pullingPercent = 1.0
        if let _ = window {
            state = .Refreshing
        } else {
            if state != .Refreshing {
                state = .Refreshing
                setNeedsDisplay()
            }
        }
    }

    public func endRefreshing() {
        state = .Idle
    }

    func isRefreshing() -> Bool {
        return state == .Refreshing || state == .WillRefresh
    }
}
