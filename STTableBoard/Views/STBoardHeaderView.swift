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
        label.font = TableBoardCommonConstant.labelFont
        label.textColor = UIColor.darkGrayTextColor
        label.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        return label
    }()

    fileprivate lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = TableBoardCommonConstant.labelFont
        label.textColor = UIColor.darkGrayTextColor
        label.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        return label
    }()
    
    fileprivate lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "boardHeaderMoreButton", in: currentBundle, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(self.actionButtonBeClicked(_:)), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
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
        
        let leading: CGFloat = BoardHeaderViewConstant.labelLeading
        let spacing: CGFloat = 0.0
        let trailing: CGFloat = 0.0
        let horizontalConstraits = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leading-[titleLabel]-spacing@500-[numberLabel]-spacing-[actionButton]-trailing-|", options: [], metrics: ["leading":leading, "trailing":trailing, "spacing":spacing], views: ["titleLabel":titleLabel, "numberLabel":numberLabel, "actionButton":actionButton])
        let titleLabelVerticalConstrait = NSLayoutConstraint(item: titleLabel,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: BoardHeaderViewConstant.labelTop)
        let numberLabelConstraits = NSLayoutConstraint(item: numberLabel,
                                                       attribute: .centerY,
                                                       relatedBy: .equal,
                                                       toItem: titleLabel,
                                                       attribute: .centerY,
                                                       multiplier: 1.0,
                                                       constant: 0)
        
        let buttonWidth = NSLayoutConstraint(item: actionButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 49.0)
//        let buttonCenterY = NSLayoutConstraint(item: actionButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        let buttonVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[actionButton]|", options: [], metrics: nil, views: ["actionButton":actionButton])
        
        NSLayoutConstraint.activate(horizontalConstraits + buttonVerticalConstraints + [titleLabelVerticalConstrait, numberLabelConstraits, buttonWidth])
        
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
