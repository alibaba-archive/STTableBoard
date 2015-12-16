//
//  STCardCell.swift
//  STTableBoardDemo
//
//  Created by DangGu on 15/12/16.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit
import STTableBoard

let cornerRadius = 4.0
class STCardCell: STBoardCell {
    
    lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    lazy var topLeftCorner: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "TopLeftCorner"))
        imageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: cornerRadius, height: cornerRadius))
        return imageView
    }()
    
    lazy var topRightCorner: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "TopRightCorner"))
        imageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: cornerRadius, height: cornerRadius))
        return imageView
    }()
    
    lazy var bottomLeftCorner: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BottomLeftCorner"))
        imageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: cornerRadius, height: cornerRadius))
        return imageView
    }()
    
    lazy var bottomRightCorner: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BottomRightCorner"))
        imageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: cornerRadius, height: cornerRadius))
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupProperty()
    }
    
    func setupProperty() {
        contentView.addSubview(cardView)
        cardView.addSubview(topLeftCorner)
        cardView.addSubview(topRightCorner)
        cardView.addSubview(bottomLeftCorner)
        cardView.addSubview(bottomRightCorner)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        topLeftCorner.translatesAutoresizingMaskIntoConstraints = false
        topRightCorner.translatesAutoresizingMaskIntoConstraints = false
        bottomLeftCorner.translatesAutoresizingMaskIntoConstraints = false
        bottomRightCorner.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = 10, trailing = 10
        let top = 5, bottom = 5
        let cardViewHorizontalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leading-[cardView]-trailing-|", options: [], metrics: ["leading":leading, "trailing":trailing], views: ["cardView":cardView])
        let cardViewVerticalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("V:|-top-[cardView]-bottom-|", options: [], metrics: ["top":top, "bottom":bottom], views: ["cardView":cardView])
        
        let topLeftHorizontalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("H:|[topLeftCorner]", options: [], metrics: nil, views: ["topLeftCorner":topLeftCorner])
        let topRightHorizontalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("H:[topRightCorner]|", options: [], metrics: nil, views: ["topRightCorner":topRightCorner])
        let bottomLeftHorizontalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottomLeftCorner]", options: [], metrics: nil, views: ["bottomLeftCorner":bottomLeftCorner])
        let bottomRightHorizontalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("H:[bottomRightCorner]|", options: [], metrics: nil, views: ["bottomRightCorner":bottomRightCorner])
        
        let topLeftVerticalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("V:|[topLeftCorner]", options: [], metrics: nil, views: ["topLeftCorner":topLeftCorner])
        let topRightVerticalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("V:|[topRightCorner]", options: [], metrics: nil, views: ["topRightCorner":topRightCorner])
        let bottomLeftVerticalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomLeftCorner]|", options: [], metrics: nil, views: ["bottomLeftCorner":bottomLeftCorner])
        let bottomRightVerticalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomRightCorner]|", options: [], metrics: nil, views: ["bottomRightCorner":bottomRightCorner])
        
        let cornerHorizontalConstraits = topLeftHorizontalConstraits + topRightHorizontalConstraits + bottomLeftHorizontalConstraits + bottomRightHorizontalConstraits
        let cornerVerticalConstraits = topLeftVerticalConstraits + topRightVerticalConstraits + bottomLeftVerticalConstraits + bottomRightVerticalConstraits
        
        NSLayoutConstraint.activateConstraints(cardViewHorizontalConstraits + cardViewVerticalConstraits + cornerHorizontalConstraits + cornerVerticalConstraits)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
