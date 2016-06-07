//
//  STBoardHeaderView.swift
//  STTableBoard
//
//  Created by DangGu on 15/12/16.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

class STBoardHeaderView: UIView {
    
    weak var boardView: STBoardView?
    
    var title: String? {
        didSet {
            titleLable.text = title
        }
    }
    private lazy var titleLable: UILabel = {
        let label = UILabel()
        label.textAlignment = .Left
        label.font = UIFont.systemFontOfSize(17.0)
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "boardHeaderButton", inBundle: currentBundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.addTarget(self, action: #selector(STBoardHeaderView.actionButtonBeClicked(_:)), forControlEvents: .TouchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperty()
    }
    
    func setupProperty() {
        addSubview(titleLable)
        addSubview(actionButton)
        
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        let leading: CGFloat = 20.0
        let spacing: CGFloat = 0.0
        let trailing: CGFloat = 0.0
        let horizontalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leading-[titleLabel]-spacing-[actionButton]-trailing-|", options: [], metrics: ["leading":leading, "trailing":trailing, "spacing":spacing], views: ["titleLabel":titleLable, "actionButton":actionButton])
        let titleLableVerticalConstrait = NSLayoutConstraint(item: titleLable,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0)
        
        let buttonWidth = NSLayoutConstraint(item: actionButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 49.0)
        let buttonCenterY = NSLayoutConstraint(item: actionButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0)
        let buttonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[actionButton]|", options: [], metrics: nil, views: ["titleLabel":titleLable, "actionButton":actionButton])
        
        NSLayoutConstraint.activateConstraints(horizontalConstraits + buttonVerticalConstraints + [titleLableVerticalConstrait, buttonWidth, buttonCenterY])
    }
    
    func actionButtonBeClicked(sender: UIButton) {
        if let boardView = boardView {
            boardView.delegate?.boardView(boardView, didClickBoardMenuButton: sender)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
