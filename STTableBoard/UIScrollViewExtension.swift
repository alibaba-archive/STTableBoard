//
//  UIScrollViewExtension.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/30.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

extension UIScrollView {
    func presentContenOffset() -> CGPoint? {
        guard let presentLayer = self.layer.presentationLayer() else { return nil }
        return presentLayer.bounds.origin
    }
}