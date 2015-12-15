//
//  STBoardView.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/25.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

class STBoardView: UIView {
    
    var headerView: UIView!
    var footerView: UIView!
    var tableView: STShadowTableView!
    
    var snapshot: UIView {
        get {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0);
            self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            let snapshot = UIImageView(image: image)
            let layer = snapshot.layer
            layer.masksToBounds = false;
            layer.cornerRadius = 0.0;
            layer.shadowOffset = CGSizeMake(-5.0, 0.0);
            layer.shadowRadius = 5.0;
            layer.shadowOpacity = 0.4;
            return snapshot;
        }
    }
    
    var moving: Bool = false {
        didSet {
            let alpha: CGFloat = moving ? 0.0 : 1.0
            self.alpha = alpha
        }
    }
    
    var index: Int {
        get {
            return self.tableView.index
        }
        set {
            self.tableView.index = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperty()
    }
    
    func setupProperty() {
        backgroundColor = UIColor.蓝灰()
        let layer = self.layer
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        
        headerView = UIView(frame: CGRectZero)
        footerView = UIView(frame: CGRectZero)
        headerView.backgroundColor = UIColor.藏墨蓝()
        footerView.backgroundColor = UIColor.藏墨蓝()
        addSubview(headerView)
        addSubview(footerView)
        tableView = STShadowTableView(frame: CGRectZero, style: .Plain)
        tableView.backgroundColor = UIColor.clearColor()
        addSubview(tableView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let headerViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[headerView]|", options: [], metrics: nil, views: ["headerView":headerView])
        let tableViewHorizontalConstraints  = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: [], metrics: nil, views: ["tableView":tableView])
        let footerViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[footerView]|", options: [], metrics: nil, views: ["footerView":footerView])
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[headerView(==height)][tableView][footerView(==height)]|", options: [], metrics: ["height":headerFooterViewHeight], views: ["headerView":headerView, "tableView":tableView, "footerView":footerView])
        NSLayoutConstraint.activateConstraints(headerViewHorizontalConstraints + tableViewHorizontalConstraints + footerViewHorizontalConstraints + verticalConstraints)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
