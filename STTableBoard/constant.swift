//
//  constant.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/26.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

enum SnapViewStatus {
    case Moving
    case Origin
}

enum ScrollDirection {
    case Left
    case Right
    case None
}

var screenWidth: CGFloat {
    get {
        return CGRectGetWidth(UIScreen.mainScreen().bounds)
    }
}

let TimerUserInfoTableViewKey = "theTableView"
let leading: CGFloat  = 30.0
let trailing: CGFloat = leading
let top: CGFloat = 20.0
let bottom: CGFloat = top
let pageSpacing: CGFloat = leading / 2
let overlap: CGFloat = pageSpacing * 3
let rotateAngel: CGFloat = CGFloat(M_PI/36)
let headerFooterViewHeight: CGFloat = 44.0