//
//  CardView.swift
//  STTableBoardDemo
//
//  Created by DangGu on 15/12/24.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    let cornerRadius: CGFloat = 4.0

    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let contentRect = CGRectInset(rect, 1.0, 1.0)
        let roundedPath = UIBezierPath(roundedRect: contentRect, cornerRadius: cornerRadius)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetShadowWithColor(context, CGSize(width: 0.5, height: 0.5), 2.0, UIColor.blackColor().colorWithAlphaComponent(0.3).CGColor)
        roundedPath.fill()
    }

}
