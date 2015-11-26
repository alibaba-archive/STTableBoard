//
//  STBoardView.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/25.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

let headerFooterViewHeight: CGFloat = 44.0

class STBoardView: UIView {
    
    var headerView: UIView!
    var footerView: UIView!
    var tableView: STShadowTableView!
    
    var index: Int? {
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
        backgroundColor = UIColor.grayColor()
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
        tableView.backgroundColor = UIColor.蓝灰()
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
