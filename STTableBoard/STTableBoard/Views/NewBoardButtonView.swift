//
//  NewBoardButtonView.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/4.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

class NewBoardButtonView: UIView {
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRectZero)
        view.contentMode = .ScaleAspectFill
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.numberOfLines = 1
        label.textColor = newBoardButtonTextColor
        label.font = UIFont.systemFontOfSize(17.0)
        return label
    }()
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let roundedPath = UIBezierPath(roundedRect: rect, cornerRadius: 4.0)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        newBoardButtonBackgroundColor.setFill()
        roundedPath.fill()
        
        let roundedRect = CGRectInset(rect, 1.0, 1.0)
        let dashedPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: 4.0)
        let pattern: [CGFloat] = [6,6]
        dashedPath.setLineDash(pattern, count: 2, phase: 0.0)
        dashedLineColor.setStroke()
        dashedPath.stroke()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(titleLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String:UIView] = ["imageView":imageView, "titleLabel":titleLabel]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(15)-[imageView(==18)]-(10)-[titleLabel]-(10)-|", options: .AlignAllCenterY, metrics: nil, views: views)
        let imageViewHeight = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 18.0)
        let imageViewCenterY = NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activateConstraints(horizontalConstraints + [imageViewHeight, imageViewCenterY])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
