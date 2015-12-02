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