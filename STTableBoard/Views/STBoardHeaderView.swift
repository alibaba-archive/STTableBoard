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
            titleLabel.text = title
        }
    }

    var number: Int = 0 {
        didSet {
            numberLabel.text = " · \(number)"
        }
    }

    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        return label
    }()

    fileprivate lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        return label
    }()
    
    fileprivate lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "boardHeaderButton", in: currentBundle, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(STBoardHeaderView.actionButtonBeClicked(_:)), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperty()
    }
    
    func setupProperty() {
        addSubview(titleLabel)
        addSubview(numberLabel)
        addSubview(actionButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        let leading: CGFloat = 20.0
        let spacing: CGFloat = 0.0
        let trailing: CGFloat = 0.0
        let horizontalConstraits = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leading-[titleLabel]-spacing@500-[numberLabel]-spacing-[actionButton]-trailing-|", options: [], metrics: ["leading":leading, "trailing":trailing, "spacing":spacing], views: ["titleLabel":titleLabel, "numberLabel":numberLabel, "actionButton":actionButton])
        let titleLabelVerticalConstrait = NSLayoutConstraint(item: titleLabel,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0)
        let numberLabelConstraits = NSLayoutConstraint(item: numberLabel,
                                                       attribute: .centerY,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .centerY,
                                                       multiplier: 1.0,
                                                       constant: 0)
        
        let buttonWidth = NSLayoutConstraint(item: actionButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 49.0)
        let buttonCenterY = NSLayoutConstraint(item: actionButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        let buttonVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[actionButton]|", options: [], metrics: nil, views: ["actionButton":actionButton])
        
        NSLayoutConstraint.activate(horizontalConstraits + buttonVerticalConstraints + [titleLabelVerticalConstrait, numberLabelConstraits, buttonWidth, buttonCenterY])
        
    }
    
    func actionButtonBeClicked(_ sender: UIButton) {
        if let boardView = boardView {
            boardView.delegate?.boardView(boardView, didClickBoardMenuButton: sender)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
