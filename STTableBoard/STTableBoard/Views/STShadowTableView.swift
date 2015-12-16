//
//  STShadowTableView.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/25.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

class STShadowTableView: UITableView {
    
    var index: Int!
    private var topShadowBar: UIView!
    private var bottomShadowBar: UIView!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.separatorStyle = .None
        setupProperty()
    }
    
    func setupProperty() {
//        bottomShadowBar = UIView(frame: CGRectZero)
//        bottomShadowBar.backgroundColor = UIColor.blackColor()
//        addSubview(bottomShadowBar)
//        
//        bottomShadowBar.translatesAutoresizingMaskIntoConstraints = false
//        
//        let barBottom = NSLayoutConstraint(item: bottomShadowBar,
//            attribute: .Bottom,
//            relatedBy: .Equal,
//            toItem: self,
//            attribute: .Bottom,
//            multiplier: 1.0, constant: 0.0)
//        let barHeight = NSLayoutConstraint(item: bottomShadowBar,
//            attribute: .Height,
//            relatedBy: .Equal,
//            toItem: nil,
//            attribute: .NotAnAttribute,
//            multiplier: 1.0, constant: 5.0)
//        let barWidth = NSLayoutConstraint(item: bottomShadowBar,
//            attribute: .Width,
//            relatedBy: .Equal,
//            toItem: self,
//            attribute: .Width,
//            multiplier: 1.0, constant: 0.0)
//        let barLeft = NSLayoutConstraint(item: bottomShadowBar,
//            attribute: .Left,
//            relatedBy: .Equal,
//            toItem: self,
//            attribute: .Left,
//            multiplier: 1.0, constant: 0.0)
//        NSLayoutConstraint.activateConstraints([barHeight, barWidth, barLeft, barBottom])
        
//        topShadowBar = UIView(frame: CGRectZero)
//        bottomShadowBar = UIView(frame: CGRectZero)
//        topShadowBar.backgroundColor = UIColor.blackColor()
//        bottomShadowBar.backgroundColor = UIColor.blackColor()
//        
//        self.addSubview(topShadowBar)
//        self.addSubview(bottomShadowBar)
//        
//        topShadowBar.translatesAutoresizingMaskIntoConstraints = false
//        bottomShadowBar.translatesAutoresizingMaskIntoConstraints = false
//        
//        let topShadowBarHeight = 5.0, bottomShadowBarHeight = 5.0
//        
//        let topHorizontalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("H:|[topShadowBar(==superView)]", options: [], metrics: nil, views: ["topShadowBar":topShadowBar, "superView":self])
//        let topVerticalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("V:|[topShadowBar(==topShadowBarHeight)]", options: [], metrics: ["topShadowBarHeight":topShadowBarHeight], views: ["topShadowBar":topShadowBar])
//        let bottomHorizontalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottomShadowBar(==superView)]", options: [], metrics: nil, views: ["bottomShadowBar":bottomShadowBar, "superView":self])
//        let bottomVerticalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomShadowBar(==bottomShadowBarHeight)]|", options: [], metrics: ["bottomShadowBarHeight":bottomShadowBarHeight], views: ["bottomShadowBar":bottomShadowBar])
//        
//        NSLayoutConstraint.activateConstraints(topHorizontalConstraits + topVerticalConstraits + bottomHorizontalConstraits + bottomVerticalConstraits)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
