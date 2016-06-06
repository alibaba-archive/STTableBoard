//
//  UIScrollView+Extension.swift
//  RefreshDemo
//
//  Created by ZouLiangming on 16/1/25.
//  Copyright © 2016年 ZouLiangming. All rights reserved.
//

import UIKit

extension UIScrollView {
    var insetTop: CGFloat {
        get {
            return self.contentInset.top
        }
        set(newValue) {
            var inset = self.contentInset
            inset.top = newValue
            self.contentInset = inset
        }
    }

    var insetBottom: CGFloat {
        get {
            return self.contentInset.bottom
        }
        set(newValue) {
            var inset = self.contentInset
            inset.bottom = newValue
            self.contentInset = inset
        }
    }

    var insetLeft: CGFloat {
        get {
            return self.contentInset.left
        }
        set(newValue) {
            var inset = self.contentInset
            inset.left = newValue
            self.contentInset = inset
        }
    }

    var insetRight: CGFloat {
        get {
            return self.contentInset.right
        }
        set(newValue) {
            var inset = self.contentInset
            inset.right = newValue
            self.contentInset = inset
        }
    }

    var offsetX: CGFloat {
        get {
            return self.contentOffset.x
        }
        set(newValue) {
            var inset = self.contentOffset
            inset.x = newValue
            self.contentOffset = inset
        }
    }

    var offsetY: CGFloat {
        get {
            return self.contentOffset.y
        }
        set(newValue) {
            var inset = self.contentOffset
            inset.y = newValue
            self.contentOffset = inset
        }
    }

    var contentWidth: CGFloat {
        get {
            return self.contentSize.width
        }
        set(newValue) {
            var inset = self.contentSize
            inset.width = newValue
            self.contentSize = inset
        }
    }

    var contentHeight: CGFloat {
        get {
            return self.contentSize.height
        }
        set(newValue) {
            var inset = self.contentSize
            inset.height = newValue
            self.contentSize = inset
        }
    }
}
