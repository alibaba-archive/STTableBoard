//
//  UIViewExtension.swift
//  STNumberLabel
//
//  Created by DangGu on 15/11/16.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

extension UIView {
    var width: CGFloat {
        get {
            return bounds.width
        }
    }
    
    var height: CGFloat {
        get {
            return bounds.height
        }
    }
    
    var minX: CGFloat {
        get {
            return frame.minX
        }
    }
    
    var minY: CGFloat {
        get {
            return frame.minY
        }
    }
    
    var maxX: CGFloat {
        get {
            return frame.maxX
        }
    }
    
    var maxY: CGFloat {
        get {
            return frame.maxY
        }
    }
    
    var absoluteCenter: CGPoint {
        get {
            return CGPoint(x: width / 2, y: height / 2)
        }
    }
    


}
