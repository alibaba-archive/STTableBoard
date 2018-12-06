//
//  UIScrollView+Extension.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/30.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

extension UIScrollView {
    func presentContenOffset() -> CGPoint? {
        guard let presentLayer = self.layer.presentation() else {
            return nil
        }
        return presentLayer.bounds.origin
    }
}
