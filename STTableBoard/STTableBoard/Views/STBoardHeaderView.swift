//
//  STBoardHeaderView.swift
//  STTableBoard
//
//  Created by DangGu on 15/12/16.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

class STBoardHeaderView: UIView {
    
    var title: String? {
        didSet {
            titleLable.text = title
        }
    }
    private var titleLable: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperty()
    }
    
    func setupProperty() {
        titleLable = UILabel(frame: CGRectZero)
        titleLable.textAlignment = .Left
        titleLable.font = UIFont.systemFontOfSize(17.0)
        addSubview(titleLable)
        
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        let leading: CGFloat = 20.0
        let trailing: CGFloat = 20.0
        let horizontalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leading-[titleLabel]-trailing-|", options: [], metrics: ["leading":leading, "trailing":trailing], views: ["titleLabel":titleLable])
        let verticalConstrait = NSLayoutConstraint(item: titleLable,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0)
        NSLayoutConstraint.activateConstraints(horizontalConstraits + [verticalConstrait])
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
