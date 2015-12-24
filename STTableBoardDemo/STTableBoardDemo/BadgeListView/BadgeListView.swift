//
//  BadgeListView.swift
//  BadgeListView
//
//  Created by DangGu on 15/12/22.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

public class BadgeListView: UIView {
    
    var rowContainerViews: [UIView] = []
    var badgeViews: [BadgeView] = []
    var currentRow: Int = 0
    var currentRowWidth: CGFloat = 0
    
    var badgeSpacing: CGFloat = 5.0
    var rowSpacing: CGFloat = 2.0
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    public func addBadge(badge: BadgeView) {
        badgeViews.append(badge)
        
        var currentRowContainerView: UIView!
        if currentRow == 0 || currentRowWidth + badge.width + badgeSpacing > frame.width {
            currentRow += 1
            currentRowWidth = badge.width
            currentRowContainerView = UIView()
            let originYOfCurrentRowContainerView = rowContainerViews.flatMap({ view in view.height}).reduce(0, combine: {$0 + $1})
            print("originYOfCurrentRowContainerView \(originYOfCurrentRowContainerView)")
            print("badge.height \(badge.height)")
            badge.frame.origin = CGPoint(x: 0, y: 0)
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
        self.frame.size = intrinsicContentSize()
    }
    
    public func removeAllBadges() {
        badgeViews.forEach { (badgeView) -> () in
            badgeView.removeFromSuperview()
        }
        rowContainerViews.forEach { (containerView) -> () in
            containerView.removeFromSuperview()
        }
        badgeViews.removeAll()
        rowContainerViews.removeAll()
        self.frame.size = intrinsicContentSize()
    }
    
    public override func intrinsicContentSize() -> CGSize {
        super.intrinsicContentSize()
        let height: CGFloat = rowContainerViews.flatMap({ view in view.height}).reduce(0, combine: {$0 + $1}) + CGFloat(rowContainerViews.count - 1) * rowSpacing
        return CGSize(width: self.width, height: height)
        
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
