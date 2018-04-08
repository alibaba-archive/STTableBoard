//
//  BadgeListView.swift
//  BadgeListView
//
//  Created by DangGu on 15/12/22.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

open class BadgeListView: UIView {

    var rowContainerViews = [UIView]()
    var badgeViews = [BadgeView]()
    var currentRow = 0
    var currentRowWidth: CGFloat = 0

    var badgeSpacing: CGFloat = 5.0
    var rowSpacing: CGFloat = 2.0

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    open func addBadge(_ badge: BadgeView) {
        badgeViews.append(badge)

        var currentRowContainerView: UIView!
        if currentRow == 0 || currentRowWidth + badge.width + badgeSpacing > frame.width {
            currentRow += 1
            currentRowWidth = badge.width
            currentRowContainerView = UIView()
            let originYOfCurrentRowContainerView = rowContainerViews.compactMap({ view in view.height}).reduce(0, {$0 + $1})
            badge.frame.origin = .zero
            currentRowContainerView.frame = CGRect(x: 0, y: originYOfCurrentRowContainerView + (currentRow == 1 ? 0 : rowSpacing), width: currentRowWidth, height: badge.height)
            currentRowContainerView.addSubview(badge)
            rowContainerViews.append(currentRowContainerView)
            addSubview(currentRowContainerView)
        } else {
            badge.frame.origin = CGPoint(x: currentRowWidth + badgeSpacing, y: 0)
            currentRowWidth += badge.width + badgeSpacing
            currentRowContainerView = rowContainerViews[currentRow - 1]
            currentRowContainerView.frame.size.width = currentRowWidth
            currentRowContainerView.frame.size.height = max(currentRowContainerView.height, badge.height)
            currentRowContainerView.addSubview(badge)
        }
        self.frame.size = intrinsicContentSize
    }

    open func removeAllBadges() {
        badgeViews.forEach { (badgeView) -> Void in
            badgeView.removeFromSuperview()
        }
        rowContainerViews.forEach { (containerView) -> Void in
            containerView.removeFromSuperview()
        }
        badgeViews.removeAll()
        rowContainerViews.removeAll()
        self.frame.size = intrinsicContentSize
    }

    open override var intrinsicContentSize: CGSize {
        let height: CGFloat = rowContainerViews.compactMap({ view in view.height}).reduce(0, {$0 + $1}) + CGFloat(rowContainerViews.count - 1) * rowSpacing
        return CGSize(width: self.width, height: height)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
