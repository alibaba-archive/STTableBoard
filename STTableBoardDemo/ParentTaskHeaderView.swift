//
//  ParentTaskHeaderView.swift
//  STTableBoardDemo
//
//  Created by 洪鑫 on 2018/2/8.
//  Copyright © 2018年 StormXX. All rights reserved.
//

import UIKit

class ParentTaskHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = String(describing: self)

    fileprivate(set) lazy var configurationIconImageView: UIImageView = self.makeConfigurationIconImageView()
    fileprivate(set) lazy var titleLabel = self.makeTitleLabel()
    fileprivate(set) lazy var workflowStatusView = self.makeWorkflowStatusView()
    fileprivate(set) lazy var workflowStatusLabel = self.makeWorkflowStatusLabel()

    // MARK: - Life cycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - Helpers
    fileprivate func commonInit() {
        configurationIconImageView.removeFromSuperview()
        titleLabel.removeFromSuperview()
        workflowStatusView.removeFromSuperview()

        contentView.backgroundColor = UIColor(white: 245 / 255, alpha: 1)
        workflowStatusView.layer.cornerRadius = 4

        contentView.addSubview(configurationIconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(workflowStatusView)

        contentView.addConstraint(NSLayoutConstraint(item: configurationIconImageView, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: configurationIconImageView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 20))

        contentView.addConstraint(NSLayoutConstraint(item: configurationIconImageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -5))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: configurationIconImageView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: workflowStatusView, attribute: .centerY, relatedBy: .equal, toItem: configurationIconImageView, attribute: .centerY, multiplier: 1, constant: 0))

        workflowStatusView.addSubview(workflowStatusLabel)
        workflowStatusView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[workflowStatusLabel]-12-|", options: [], metrics: nil, views: ["workflowStatusLabel": workflowStatusLabel]))
        workflowStatusView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[workflowStatusLabel]-4-|", options: [], metrics: nil, views: ["workflowStatusLabel": workflowStatusLabel]))

        let visualFormat = "H:|-8-[configurationIconImageView]-4-[titleLabel]-8-[workflowStatusView]"
        let views: [String: Any] = ["configurationIconImageView": configurationIconImageView, "titleLabel": titleLabel, "workflowStatusView": workflowStatusView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: visualFormat, options: [], metrics: nil, views: views))
    }

    // MARK: - Make functions
    fileprivate func makeConfigurationIconImageView() -> UIImageView {
        let configurationIconImageView = UIImageView()
        configurationIconImageView.translatesAutoresizingMaskIntoConstraints = false
        return configurationIconImageView
    }

    fileprivate func makeTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .clear
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(white: 0.5, alpha: 1)
        return titleLabel
    }

    fileprivate func makeWorkflowStatusView() -> UIView {
        let workflowStatusView = UIView()
        workflowStatusView.translatesAutoresizingMaskIntoConstraints = false
        return workflowStatusView
    }

    fileprivate func makeWorkflowStatusLabel() -> UILabel {
        let workflowStatusLabel = UILabel()
        workflowStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        workflowStatusLabel.backgroundColor = .clear
        workflowStatusLabel.textAlignment = .center
        workflowStatusLabel.font = .systemFont(ofSize: 12)
        workflowStatusLabel.textColor = UIColor(white: 56 / 255, alpha: 1)
        return workflowStatusLabel
    }
}
