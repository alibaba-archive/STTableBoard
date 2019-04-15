//
//  STBoardView.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/25.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit
import RefreshView

protocol STBoardViewDelegate: class {
    func boardViewDidBeginEditingAtBottomRow(boardView view: STBoardView)
    func boardView(_ boardView: STBoardView, didClickBoardMenuButton button: UIButton)
    func boardView(_ boardView: STBoardView, didClickDoneButtonForAddNewRow button: UIButton, withRowTitle title: String)
    func boardViewDidClickCancelButtonForAddNewRow(_ boardView: STBoardView)
    func customAddRowAction(for boardView: STBoardView) -> (() -> Void)?
}

extension STBoardViewDelegate {
    func boardViewDidBeginEditingAtBottomRow(boardView view: STBoardView) {

    }
}

class STBoardView: UIView {
    var headerView: STBoardHeaderView!
    var footerView: STBoardFooterView!
    var tableView: STShadowTableView!
    var dropMessageLabel: UILabel!
    var dropMaskView: UIView!

    weak var tableBoard: STTableBoard!

    weak var delegate: STBoardViewDelegate?
    var shouldEnableAddRow = true
    var shouldShowActionButton = true {
        didSet {
            headerView.shouldShowActionButton = shouldShowActionButton
        }
    }
    var footerViewHeightConstant: CGFloat = footerViewNormalHeight {
        didSet {
            footerViewHeightConstraint.constant = footerViewHeightConstant
            UIView.animate(withDuration: 0.33, animations: {
                self.layoutIfNeeded()
            }, completion: { [weak self](_) in
                if let weakSelf = self {
                    weakSelf.tableBoard.autoAdjustTableBoardHeight(weakSelf, animated: true)
                }
            })
        }
    }

    lazy var footerViewHeightConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: footerView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: shouldEnableAddRow ? footerViewNormalHeight : footerViewDisabledHeight)
        return constraint
    }()

    var snapshot: UIView {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let snapshot = UIImageView(image: image)
        let layer = snapshot.layer
        layer.masksToBounds = false
        layer.cornerRadius = 0.0
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        return snapshot
    }

    var moving: Bool = false {
        didSet {
            let alpha: CGFloat = moving ? 0.0 : 1.0
            self.alpha = alpha
        }
    }

    var index: Int {
        get {
            return self.tableView.index
        }
        set {
            self.tableView.index = newValue
        }
    }

    var title: String? {
        get {
            return self.headerView.title
        }
        set {
            self.headerView.title = newValue
        }
    }

    var number: Int {
        get {
            return self.headerView.number
        }
        set {
            self.headerView.number = newValue
        }
    }

    init(frame: CGRect, shouldShowActionButton: Bool, showRefreshFooter: Bool, shouldEnableAddRow: Bool) {
        super.init(frame: frame)
        setupProperty(shouldShowActionButton: shouldShowActionButton, showRefreshFooter: showRefreshFooter, shouldEnableAddRow: shouldEnableAddRow)
    }

    func setupProperty(shouldShowActionButton: Bool, showRefreshFooter: Bool, shouldEnableAddRow: Bool) {
        backgroundColor = boardBackgroundColor
        let layer = self.layer
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderColor = boardBorderColor.cgColor
        layer.borderWidth = 0.5

        headerView = STBoardHeaderView(frame: .zero)
        footerView = STBoardFooterView(frame: .zero)
        tableView = STShadowTableView(frame: .zero, style: .plain)
        headerView.shouldShowActionButton = shouldShowActionButton
        headerView.backgroundColor = boardBackgroundColor
        footerView.backgroundColor = boardBackgroundColor
        tableView.backgroundColor = boardBackgroundColor

        self.shouldShowActionButton = shouldShowActionButton
        self.shouldEnableAddRow = shouldEnableAddRow
        footerViewHeightConstant = shouldEnableAddRow ? footerViewNormalHeight : footerViewDisabledHeight
        footerView.isHidden = !shouldEnableAddRow

        headerView.boardView = self
        footerView.boardView = self

        addSubview(headerView)
        addSubview(footerView)
        addSubview(tableView)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let headerViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[headerView]|", options: [], metrics: nil, views: ["headerView": headerView!])
        let tableViewHorizontalConstraints  = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: ["tableView": tableView!])
        let footerViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[footerView]|", options: [], metrics: nil, views: ["footerView": footerView!])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[headerView(==headerViewHeight)][tableView][footerView]|", options: [], metrics: ["headerViewHeight": headerViewHeight], views: ["headerView": headerView!, "tableView": tableView!, "footerView": footerView!])

        let horizontalConstraints = headerViewHorizontalConstraints + tableViewHorizontalConstraints + footerViewHorizontalConstraints
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints + [footerViewHeightConstraint])

        dropMessageLabel = UILabel()
        dropMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        dropMessageLabel.textColor = .darkGrayTextColor
        if #available(iOS 8.2, *) {
            dropMessageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        } else {
            dropMessageLabel.font = .boldSystemFont(ofSize: 16)
        }
        dropMessageLabel.textAlignment = .left
        dropMaskView = UIView()
        dropMaskView.translatesAutoresizingMaskIntoConstraints = false
        dropMaskView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        dropMaskView.layer.cornerRadius = 5
        dropMaskView.layer.borderWidth = 2
        dropMaskView.layer.borderColor = UIColor.primaryBlueColor.cgColor

        dropMaskView.addSubview(dropMessageLabel)
        dropMaskView.addConstraint(NSLayoutConstraint(item: dropMessageLabel!, attribute: .leading, relatedBy: .equal, toItem: dropMaskView, attribute: .leading, multiplier: 1, constant: 10))
        dropMaskView.addConstraint(NSLayoutConstraint(item: dropMaskView!, attribute: .trailing, relatedBy: .equal, toItem: dropMessageLabel, attribute: .trailing, multiplier: 1, constant: 10))
        dropMaskView.addConstraint(NSLayoutConstraint(item: dropMessageLabel!, attribute: .top, relatedBy: .equal, toItem: dropMaskView, attribute: .top, multiplier: 1, constant: 10))
        addSubview(dropMaskView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dropMaskView]|", options: [], metrics: nil, views: ["dropMaskView": dropMaskView!]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dropMaskView]|", options: [], metrics: nil, views: ["dropMaskView": dropMaskView!]))

        bringSubviewToFront(dropMaskView)
        deactivateDropMask()

        // refresh footer
        guard showRefreshFooter else {
            return
        }
        tableView.refreshFooter = CustomRefreshFooterView.footerWithLoadingText(localizedString["STTableBoard.RefreshFooter.text"] ?? "Loading...", startLoading: { [weak self] in
            if let weakSelf = self, let dataSource = weakSelf.tableBoard.dataSource {
                dataSource.tableBoard(weakSelf.tableBoard, footerRefreshingAt: weakSelf.index)
            }
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hideTextComposeView() {
        footerView.hideTextComposeView()
    }

    func footerViewBeginEditing() {
        delegate?.boardViewDidBeginEditingAtBottomRow(boardView: self)
    }

    func activateDropMask() {
        dropMaskView.alpha = 1
    }

    func deactivateDropMask() {
        dropMaskView.alpha = 0
    }
}
