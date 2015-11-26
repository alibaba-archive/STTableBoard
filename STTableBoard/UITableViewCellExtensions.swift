//
//  UITableViewCellExtensions.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/23.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

extension UITableViewCell {
    var snapshot: UIView {
        get {
            let snapshot = snapshotViewAfterScreenUpdates(true)
            let layer = snapshot.layer
            layer.masksToBounds = false
            layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
            layer.shadowRadius = 5.0
            layer.shadowOpacity = 0.4
            return snapshot
        }
    }
}