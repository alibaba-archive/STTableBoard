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

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let contentRect = rect.insetBy(dx: 1.0, dy: 2.0)
        let roundedPath = UIBezierPath(roundedRect: contentRect, cornerRadius: cornerRadius)
        context?.setFillColor(UIColor.white.cgColor)
        context?.setShadow(offset: CGSize(width: 0.0, height: 0.8), blur: 2.0, color: UIColor.black.withAlphaComponent(0.15).cgColor)
        roundedPath.fill()
    }

}
