//
//  STBoardView.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/25.
//  Copyright © 2015年 StormXX. All rights reserved.
//

protocol STBoardViewDelegate: class {
    func boardViewDidBeginEditingAtBottomRow(boardView view: STBoardView)
    func boardView(boardView: STBoardView, didClickBoardMenuButton button: UIButton)
    func boardView(boardView: STBoardView, didClickDoneButtonForAddNewRow button: UIButton, withRowTitle title: String)
}

extension STBoardViewDelegate {
    func boardViewDidBeginEditingAtBottomRow(boardView view: STBoardView) {}
}

import UIKit
import RefreshView

class STBoardView: UIView {
    
    var headerView: STBoardHeaderView!
    var footerView: STBoardFooterView!
    var tableView: STShadowTableView!
    var topShadowBar: UIImageView!
    var bottomShadowBar: UIImageView!
    weak var tableBoard: STTableBoard!
    
    weak var delegate: STBoardViewDelegate?
    var footerViewHeightConstant: CGFloat = footerViewHeight {
        didSet {
            footerViewHeightConstraint.constant = footerViewHeightConstant
            UIView.animateWithDuration(0.33, animations: {
                self.layoutIfNeeded()
            }) { [unowned self](finished) in
                self.tableBoard.autoAdjustTableBoardHeight(self, animated: true)
            }
        }
    }
    
    lazy var footerViewHeightConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self.footerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: footerViewHeight)
        return constraint
    }()
    
    var snapshot: UIView {
        get {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0);
            self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            let snapshot = UIImageView(image: image)
            let layer = snapshot.layer
            layer.masksToBounds = false;
            layer.cornerRadius = 0.0;
            layer.shadowOffset = CGSizeMake(-5.0, 0.0);
            layer.shadowRadius = 5.0;
            layer.shadowOpacity = 0.15;
            return snapshot;
        }
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
    
     init(frame: CGRect, showRefreshFooter: Bool) {
        super.init(frame: frame)
        setupProperty(showRefreshFooter)
        tableView.addObserver(self, forKeyPath: "contentOffset", options: [.New, .Old], context: nil)
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    func setupProperty(showRefreshFooter: Bool) {
        backgroundColor = boardBackgroundColor
        let layer = self.layer
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderColor = boardBorderColor.CGColor
        layer.borderWidth = 0.5
        
        headerView = STBoardHeaderView(frame: CGRect.zero)
        footerView = STBoardFooterView(frame: CGRect.zero)
        tableView = STShadowTableView(frame: CGRect.zero, style: .Plain)
        headerView.backgroundColor = boardBackgroundColor
        footerView.backgroundColor = boardBackgroundColor
        tableView.backgroundColor = boardBackgroundColor
        
        headerView.boardView = self
        footerView.boardView = self
        
        addSubview(headerView)
        addSubview(footerView)
        addSubview(tableView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let headerViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[headerView]|", options: [], metrics: nil, views: ["headerView":headerView])
        let tableViewHorizontalConstraints  = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: [], metrics: nil, views: ["tableView":tableView])
        let footerViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[footerView]|", options: [], metrics: nil, views: ["footerView":footerView])
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[headerView(==headerViewHeight)][tableView][footerView]|", options: [], metrics: ["headerViewHeight":headerViewHeight], views: ["headerView":headerView, "tableView":tableView, "footerView":footerView])
        
        let horizontalConstraints = headerViewHorizontalConstraints + tableViewHorizontalConstraints + footerViewHorizontalConstraints
        NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints + [footerViewHeightConstraint])
        
        //shadowView
        let topShadowBarImage = UIImage(named: "topShadow", inBundle: currentBundle, compatibleWithTraitCollection: nil)
        let bottomShadowBarImage = UIImage(named: "bottomShadow", inBundle: currentBundle, compatibleWithTraitCollection: nil)
        topShadowBar = UIImageView(image: topShadowBarImage)
        bottomShadowBar = UIImageView(image: bottomShadowBarImage)
        
        addSubview(topShadowBar)
        addSubview(bottomShadowBar)
        
        topShadowBar.translatesAutoresizingMaskIntoConstraints = false
        bottomShadowBar.translatesAutoresizingMaskIntoConstraints = false
        
        let topShadowBarHeight: CGFloat = 5.0, bottomShadowBarHeight: CGFloat = 5.0
        
        let topShadowBarHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[topShadowBar]|", options: [], metrics: nil, views: ["topShadowBar":topShadowBar])
        let bottomShadowBarHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottomShadowBar]|", options: [], metrics: nil, views: ["bottomShadowBar":bottomShadowBar])
        let topShadowBarTopConstraint = NSLayoutConstraint(item: topShadowBar,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: headerView,
            attribute: .Bottom,
            multiplier: 1.0, constant: 0.0)
        let topShadowBarHeightConstraint = NSLayoutConstraint(item: topShadowBar,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0, constant: topShadowBarHeight)
        let bottomShadowBarBottomConstraint = NSLayoutConstraint(item: bottomShadowBar,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: footerView,
            attribute: .Top,
            multiplier: 1.0, constant: 0.0)
        let bottomShadowBarHeightConstraint = NSLayoutConstraint(item: bottomShadowBar,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0, constant: bottomShadowBarHeight)
        
        NSLayoutConstraint.activateConstraints(topShadowBarHorizontalConstraints + bottomShadowBarHorizontalConstraints + [topShadowBarTopConstraint, topShadowBarHeightConstraint, bottomShadowBarBottomConstraint, bottomShadowBarHeightConstraint])

        // refresh footer
        guard showRefreshFooter else { return }
        tableView.refreshFooter = CustomRefreshFooterView.footerWithRefreshingBlock({ [weak self] in
            if let weakSelf = self, dataSource = weakSelf.tableBoard.dataSource {
                dataSource.tableBoard(weakSelf.tableBoard, boardIndexForFooterRefreshing: weakSelf.index)
            }
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let change = change where keyPath == "contentOffset" else { return }
        let offsetY = (change["new"] as! NSValue).CGPointValue().y
        topShadowBar.hidden = (offsetY <= 0)
        bottomShadowBar.hidden = (offsetY == 0 && tableView.height == tableView.contentSize.height) || (offsetY + tableView.height >= tableView.contentSize.height)
    }

    func hideTextComposeView() {
        footerView.hideTextComposeView()
    }
    
    func footerViewBeginEditing() {
        delegate?.boardViewDidBeginEditingAtBottomRow(boardView: self)
    }
}
