//
//  STBoardView.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/25.
//  Copyright © 2015年 StormXX. All rights reserved.
//

protocol STBoardViewDelegate: class {
    func boardViewDidBeginEditingAtBottomRow(boardView view: STBoardView)
    func boardView(_ boardView: STBoardView, didClickBoardMenuButton button: UIButton)
    func boardView(_ boardView: STBoardView, didClickDoneButtonForAddNewRow button: UIButton, withRowTitle title: String)
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
            UIView.animate(withDuration: 0.33, animations: {
                self.layoutIfNeeded()
            }, completion: { [weak self](finished) in
                if let weakSelf = self {
                    weakSelf.tableBoard.autoAdjustTableBoardHeight(weakSelf, animated: true)
                }
            }) 
        }
    }
    
    lazy var footerViewHeightConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self.footerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: footerViewHeight)
        return constraint
    }()
    
    var snapshot: UIView {
        get {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0);
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            let snapshot = UIImageView(image: image)
            let layer = snapshot.layer
            layer.masksToBounds = false;
            layer.cornerRadius = 0.0;
            layer.shadowOffset = CGSize(width: -5.0, height: 0.0);
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

    var number: Int {
        get {
            return self.headerView.number
        }
        set {
            self.headerView.number = newValue
        }
    }
    
     init(frame: CGRect, showRefreshFooter: Bool) {
        super.init(frame: frame)
        setupProperty(showRefreshFooter)
        tableView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    func setupProperty(_ showRefreshFooter: Bool) {
        backgroundColor = boardBackgroundColor
        let layer = self.layer
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderColor = boardBorderColor.cgColor
        layer.borderWidth = 0.5
        
        headerView = STBoardHeaderView(frame: CGRect.zero)
        footerView = STBoardFooterView(frame: CGRect.zero)
        tableView = STShadowTableView(frame: CGRect.zero, style: .plain)
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
        let headerViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[headerView]|", options: [], metrics: nil, views: ["headerView":headerView])
        let tableViewHorizontalConstraints  = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: ["tableView":tableView])
        let footerViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[footerView]|", options: [], metrics: nil, views: ["footerView":footerView])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[headerView(==headerViewHeight)][tableView][footerView]|", options: [], metrics: ["headerViewHeight":headerViewHeight], views: ["headerView":headerView, "tableView":tableView, "footerView":footerView])
        
        let horizontalConstraints = headerViewHorizontalConstraints + tableViewHorizontalConstraints + footerViewHorizontalConstraints
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints + [footerViewHeightConstraint])
        
        //shadowView
        let topShadowBarImage = UIImage(named: "topShadow", in: currentBundle, compatibleWith: nil)
        let bottomShadowBarImage = UIImage(named: "bottomShadow", in: currentBundle, compatibleWith: nil)
        topShadowBar = UIImageView(image: topShadowBarImage)
        bottomShadowBar = UIImageView(image: bottomShadowBarImage)
        
        addSubview(topShadowBar)
        addSubview(bottomShadowBar)
        
        topShadowBar.translatesAutoresizingMaskIntoConstraints = false
        bottomShadowBar.translatesAutoresizingMaskIntoConstraints = false
        
        let topShadowBarHeight: CGFloat = 5.0, bottomShadowBarHeight: CGFloat = 5.0
        
        let topShadowBarHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[topShadowBar]|", options: [], metrics: nil, views: ["topShadowBar":topShadowBar])
        let bottomShadowBarHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomShadowBar]|", options: [], metrics: nil, views: ["bottomShadowBar":bottomShadowBar])
        let topShadowBarTopConstraint = NSLayoutConstraint(item: topShadowBar,
            attribute: .top,
            relatedBy: .equal,
            toItem: headerView,
            attribute: .bottom,
            multiplier: 1.0, constant: 0.0)
        let topShadowBarHeightConstraint = NSLayoutConstraint(item: topShadowBar,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0, constant: topShadowBarHeight)
        let bottomShadowBarBottomConstraint = NSLayoutConstraint(item: bottomShadowBar,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: footerView,
            attribute: .top,
            multiplier: 1.0, constant: 0.0)
        let bottomShadowBarHeightConstraint = NSLayoutConstraint(item: bottomShadowBar,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0, constant: bottomShadowBarHeight)
        
        NSLayoutConstraint.activate(topShadowBarHorizontalConstraints + bottomShadowBarHorizontalConstraints + [topShadowBarTopConstraint, topShadowBarHeightConstraint, bottomShadowBarBottomConstraint, bottomShadowBarHeightConstraint])

        // refresh footer
        guard showRefreshFooter else { return }
        tableView.refreshFooter = CustomRefreshFooterView.footerWithLoadingText(localizedString["STTableBoard.RefreshFooter.text"] ?? "Loading...", startLoading: { [weak self] in
            if let weakSelf = self, let dataSource = weakSelf.tableBoard.dataSource {
                dataSource.tableBoard(weakSelf.tableBoard, footerRefreshingAt: weakSelf.index)
            }
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change , keyPath == "contentOffset" else { return }
        let offsetY = (change[.newKey] as! NSValue).cgPointValue.y
        topShadowBar.isHidden = (offsetY <= 0)
        bottomShadowBar.isHidden = (offsetY == 0 && tableView.height == tableView.contentSize.height) || (offsetY + tableView.height >= tableView.contentSize.height)
    }

    func hideTextComposeView() {
        footerView.hideTextComposeView()
    }
    
    func footerViewBeginEditing() {
        delegate?.boardViewDidBeginEditingAtBottomRow(boardView: self)
    }
}
