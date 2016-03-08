//
//  BoardCardCell.swift
//  STTableBoardDemo
//
//  Created by DangGu on 15/12/21.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit
import STTableBoard

class BoardCardCell: STBoardCell {
    private lazy var cardView: CardView = {
        let view = CardView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 2
        label.textAlignment = .Left
        label.font = UIFont.systemFontOfSize(15.0)
        label.lineBreakMode = .ByTruncatingTail
        label.textColor = UIColor(red: 56/255.0, green: 56/255.0, blue: 56/255.0, alpha: 1.0)
        return label
    }()
    
    private lazy var checkBoxView: CheckBoxView = {
        let view = CheckBoxView(frame: CGRect.zero)
        view.checked = false
        return view
    }()
    
    private lazy var avatarView: RoundAvatarImageView = {
        let view = RoundAvatarImageView(frame: CGRect.zero)
        return view
    }()
    
    private lazy var badgeListView: BadgeListView = {
        let view = BadgeListView()
        return view
    }()
    
    
    
    private var hasLoadTag: Bool = false
    
    var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupProperty()
    }
    
    func setupProperty() {
//        backgroundView = backgroundImageView
        contentView.addSubview(cardView)
        cardView.addSubview(checkBoxView)
        cardView.addSubview(avatarView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(badgeListView)
        avatarView.image = UIImage(named: "avatar")
        setupConstrains()
    }
    
    func setupConstrains() {
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        checkBoxView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeListView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["checkBoxView":checkBoxView, "avatarView":avatarView, "titleLabel":titleLabel]
        
        let leading = 8, trailing = 8, top = 2, bottom = 2
        let cardViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leading-[cardView]-trailing-|", options: [], metrics: ["leading":leading, "trailing":trailing], views: ["cardView":cardView])
        let cardViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-top-[cardView]-bottom-|", options: [], metrics: ["top":top, "bottom":bottom], views: ["cardView":cardView])
        NSLayoutConstraint.activateConstraints(cardViewHorizontalConstraints + cardViewVerticalConstraints)
        
        let checkBoxWidth: CGFloat = 16.0, avatarWidth: CGFloat = 24.0
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-12-[checkBoxView(==checkBoxWidth)]-8-[avatarView(==avatarWidth)]-8-[titleLabel]-10-|", options: [], metrics: ["checkBoxWidth":checkBoxWidth, "avatarWidth":avatarWidth], views: views)
        let checkboxHeightConstraint = NSLayoutConstraint(item: checkBoxView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: checkBoxWidth)
        let avatarHeightConstraints = NSLayoutConstraint(item: avatarView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: avatarWidth)
        let checkboxTopConstraint = NSLayoutConstraint(item: checkBoxView, attribute: .Top, relatedBy: .Equal, toItem: cardView, attribute: .Top, multiplier: 1.0, constant: 13.0)
        let avatarTopConstraint = NSLayoutConstraint(item: avatarView, attribute: .Top, relatedBy: .Equal, toItem: cardView, attribute: .Top, multiplier: 1.0, constant: 10.0)
        let titleLabelTopConstraint = NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: cardView, attribute: .Top, multiplier: 1.0, constant: 14.0)
        let badgeListViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-36-[badgeListView]-8-|", options: [], metrics: nil, views: ["badgeListView":badgeListView])
        let badgeListViewTopConstraint = NSLayoutConstraint(item: badgeListView, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1.0, constant: 12.0)
        
        NSLayoutConstraint.activateConstraints(horizontalConstraints + [checkboxHeightConstraint, checkboxTopConstraint, avatarHeightConstraints, avatarTopConstraint, titleLabelTopConstraint, badgeListViewTopConstraint] + badgeListViewHorizontalConstraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasLoadTag {
            cardView.layoutIfNeeded()
            let badge: BadgeView = BadgeView(frame: CGRect.zero)
            badge.image = UIImage(named: "dueDate_icon")
            badge.backgroundImage = UIImage(named: "dueDate_background")
            badge.text = "16 Oct"
            badge.textColor = UIColor.whiteColor()
            badge.imageWidth = 8.0
            badge.sizeToFit()
            badge.textFont = UIFont.systemFontOfSize(10.0)
            
            let bbadge: BadgeView = BadgeView(frame: CGRect.zero)
            bbadge.image = UIImage(named: "tag_icon")
            bbadge.backgroundImage = UIImage(named: "tag_background")
            bbadge.text = "交互设计"
            bbadge.textColor = UIColor.grayColor()
            bbadge.imageWidth = 4.0
            bbadge.sizeToFit()
            bbadge.textFont = UIFont.systemFontOfSize(10.0)
            
            let cbadge: BadgeView = BadgeView(frame: CGRect.zero)
            cbadge.image = UIImage(named: "subtask_icon")
            cbadge.imageWidth = 9.0
            cbadge.text = "2/3"
            cbadge.textColor = UIColor.grayColor()
            cbadge.sizeToFit()
            cbadge.textFont = UIFont.systemFontOfSize(10.0)
            
            badgeListView.addBadge(badge)
            badgeListView.addBadge(bbadge)
            badgeListView.addBadge(cbadge)
            
            hasLoadTag = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
