//
//  UIView+Extension.swift
//  RefreshDemo
//
//  Created by ZouLiangming on 16/1/25.
//  Copyright © 2016年 ZouLiangming. All rights reserved.
//

import UIKit

extension UIView {
    var originX: CGFloat {
        get {
            return self.frame.origin.x
        }
        set(newValue) {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }

    var originY: CGFloat {
        get {
            return self.frame.origin.y
        }
        set(newValue) {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }

    var sizeWidth: CGFloat {
        get {
            return self.frame.size.width
        }
        set(newValue) {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }

    var sizeHeight: CGFloat {
        get {
            return self.frame.size.height
        }
        set(newValue) {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }

    var size: CGSize {
        get {
            return self.frame.size
        }
        set(newValue) {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }

    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set(newValue) {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }

}
