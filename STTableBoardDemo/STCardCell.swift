//
//  STCardCell.swift
//  STTableBoardDemo
//
//  Created by DangGu on 15/12/16.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit
import STTableBoard

class STCardCell: STBoardCell {
    
    lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    fileprivate var checkBox: UIImageView!
    fileprivate var avatar: UIImageView!
    fileprivate var subtaskIcon: UIImageView!
    fileprivate var commentIcon: UIImageView!
    fileprivate var attachmentIcon: UIImageView!
    
    fileprivate var titleLabel: UILabel!
    fileprivate var subtaskLabel: UILabel!
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupProperty()
        setupUI()
    }
    
    func setupProperty() {
        
        let backgroundImageView = UIImageView(image: UIImage(named: "Shadow"))
        backgroundImageView.contentMode = .scaleToFill
        self.backgroundView = backgroundImageView
        
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = 10, trailing = 10, top = 5, bottom = 5
        let cardViewHorizontalConstraits = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leading-[cardView]-trailing-|", options: [], metrics: ["leading":leading, "trailing":trailing], views: ["cardView":cardView])
        let cardViewVerticalConstraits = NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[cardView]-bottom-|", options: [], metrics: ["top":top, "bottom":bottom], views: ["cardView":cardView])
        NSLayoutConstraint.activate(cardViewHorizontalConstraits + cardViewVerticalConstraits)
        
    }
    
    func setupUI() {
        checkBox = UIImageView(image: UIImage(named: "cardcell-checkbox-uncheck"))
        avatar = UIImageView(image: UIImage(named: "avatar"))
        subtaskIcon = UIImageView(image: UIImage(named: "subtaskIcon"))
        commentIcon = UIImageView(image: UIImage(named: "commentIcon"))
        attachmentIcon = UIImageView(image: UIImage(named: "attachmentIcon"))
        cardView.addSubview(checkBox)
        cardView.addSubview(avatar)
        cardView.addSubview(subtaskIcon)
        cardView.addSubview(commentIcon)
        cardView.addSubview(attachmentIcon)
        
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        subtaskIcon.translatesAutoresizingMaskIntoConstraints = false
        commentIcon.translatesAutoresizingMaskIntoConstraints = false
        attachmentIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let checkBoxHorizontal = NSLayoutConstraint(item: checkBox, attribute: .leading, relatedBy: .equal, toItem: cardView, attribute: .leading, multiplier: 1.0, constant: 10.0)
        let checkBoxVertical = NSLayoutConstraint(item: checkBox, attribute: .top, relatedBy: .equal, toItem: cardView, attribute: .top, multiplier: 1.0, constant: 11.0)
        let checkBoxWidth = NSLayoutConstraint(item: checkBox, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 16.0)
        let checkBoxHeight = NSLayoutConstraint(item: checkBox, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 16.0)
        let avatarHorizontal = NSLayoutConstraint(item: avatar, attribute: .leading, relatedBy: .equal, toItem: checkBox, attribute: .trailing, multiplier: 1.0, constant: 8)
        let avatarVertical = NSLayoutConstraint(item: avatar, attribute: .top, relatedBy: .equal, toItem: cardView, attribute: .top, multiplier: 1.0, constant: 8.0)
        let avatarWidth = NSLayoutConstraint(item: avatar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0)
        let avatarHeight = NSLayoutConstraint(item: avatar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24.0)
        let subtaskIconHorizontal = NSLayoutConstraint(item: subtaskIcon, attribute: .leading, relatedBy: .equal, toItem: cardView, attribute: .leading, multiplier: 1.0, constant: 46.0)
        let subtaskIconVertical = NSLayoutConstraint(item: subtaskIcon, attribute: .bottom, relatedBy: .equal, toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: -16.0)
        let commentIconHorizontal = NSLayoutConstraint(item: commentIcon, attribute: .leading, relatedBy: .equal, toItem: subtaskIcon, attribute: .trailing, multiplier: 1.0, constant: 41.0)
        let commentIconVertical = NSLayoutConstraint(item: commentIcon, attribute: .bottom, relatedBy: .equal, toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: -13.0)
        let attachmentIconHorizontal = NSLayoutConstraint(item: attachmentIcon, attribute: .leading, relatedBy: .equal, toItem: commentIcon, attribute: .trailing, multiplier: 1.0, constant: 15.0)
        let attachmentIconVertical = NSLayoutConstraint(item: attachmentIcon, attribute: .bottom, relatedBy: .equal, toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: -15.0)
        
        NSLayoutConstraint.activate([checkBoxHorizontal, checkBoxVertical, checkBoxWidth, checkBoxHeight, avatarHorizontal, avatarVertical, avatarWidth, avatarHeight, subtaskIconHorizontal, subtaskIconVertical, commentIconHorizontal, commentIconVertical, attachmentIconHorizontal, attachmentIconVertical])
        
        subtaskLabel = UILabel()
        subtaskLabel.font = UIFont.systemFont(ofSize: 12.0)
        subtaskLabel.textColor = UIColor(red: 166.0/255.0, green: 166.0/255.0, blue: 166.0/255.0, alpha: 1.0)
        subtaskLabel.text = "2/3"
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15.0)
        titleLabel.textColor = UIColor(red: 56/255.0, green: 56/255.0, blue: 56/255.0, alpha: 1.0)
        titleLabel.text = "肇兴大帅逼！"
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        cardView.addSubview(subtaskLabel)
        cardView.addSubview(titleLabel)
        
        subtaskLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtaskLabelHorizontal = NSLayoutConstraint(item: subtaskLabel, attribute: .leading, relatedBy: .equal, toItem: subtaskIcon, attribute: .trailing, multiplier: 1.0, constant: 7.0)
        let subtaskLabelVertical = NSLayoutConstraint(item: subtaskLabel, attribute: .centerY, relatedBy: .equal, toItem: subtaskIcon, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let titleLabelLeading = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: avatar, attribute: .trailing, multiplier: 1.0, constant: 10.0)
        let titleLabelTrailing = NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: cardView, attribute: .trailing, multiplier: 1.0, constant: -16.0)
        let titleLabelTop = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: cardView, attribute: .top, multiplier: 1.0, constant: 11.0)
        
        NSLayoutConstraint.activate([subtaskLabelHorizontal, subtaskLabelVertical, titleLabelLeading, titleLabelTrailing, titleLabelTop])
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
