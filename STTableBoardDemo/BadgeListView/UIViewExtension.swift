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
        return bounds.width
    }

    var height: CGFloat {
        return bounds.height
    }

    var minX: CGFloat {
        return frame.minX
    }

    var minY: CGFloat {
        return frame.minY
    }

    var maxX: CGFloat {
        return frame.maxX
    }

    var maxY: CGFloat {
        return frame.maxY
    }

    var absoluteCenter: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }

}
