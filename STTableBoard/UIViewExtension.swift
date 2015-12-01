//
//  UIViewExtension.swift
//  STNumberLabel
//
//  Created by DangGu on 15/11/16.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

extension UIView {
    var width: CGFloat {
        get {
            return CGRectGetWidth(frame)
        }
    }
    
    var height: CGFloat {
        get {
            return CGRectGetHeight(frame)
        }
    }
    
    var minX: CGFloat {
        get {
            return CGRectGetMinX(frame)
        }
    }
    
    var minY: CGFloat {
        get {
            return CGRectGetMinY(frame)
        }
    }
    
    var maxX: CGFloat {
        get {
            return CGRectGetMaxX(frame)
        }
    }
    
    var maxY: CGFloat {
        get {
            return CGRectGetMaxY(frame)
        }
    }
    
    var absoluteCenter: CGPoint {
        get {
            return CGPoint(x: width / 2, y: height / 2)
        }
    }
    


}