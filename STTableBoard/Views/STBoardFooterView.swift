//
//  STBoardFooterView.swift
//  STTableBoard
//
//  Created by DangGu on 15/12/17.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

class STBoardFooterView: UIView {
    
    weak var boardView: STBoardView?

    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.setTitle(localizedString["STTableBoard.AddRow"], for: .normal)
        button.titleLabel?.font = TableBoardCommonConstant.labelFont
        button.setTitleColor(UIColor.grayTextColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        button.addTarget(self, action: #selector(STBoardFooterView.addButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var textComposeView: TextComposeView = {
        let view = TextComposeView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height), textFieldHeight: newCellComposeViewTextFieldHeight, cornerRadius: 0.0)
        view.delegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperty()
    }
    
    func setupProperty() {
        addSubview(titleButton)
        titleButton.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["titleButton": titleButton]
        let titleButtonHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleButton]-|", options: [], metrics: nil, views: views)
        let titleButtonVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleButton]-|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(titleButtonHorizontalConstraints + titleButtonVerticalConstraints)
    }
    
    func addButtonTapped(_ sender: UIButton?) {
        boardView?.footerViewHeightConstant = newCellComposeViewHeight
        textComposeView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.width, height: newCellComposeViewHeight))
        showTextComposeView()
        if boardView?.tableBoard.isAddBoardTextComposeViewVisible ?? false {
            boardView?.tableBoard.hiddenTextComposeView()
            boardView?.tableBoard.isAddBoardTextComposeViewVisible = false
        } else if let boardViewForVisibleTextComposeView = boardView?.tableBoard.boardViewForVisibleTextComposeView {
            if boardViewForVisibleTextComposeView != boardView {
                boardViewForVisibleTextComposeView.hideTextComposeView()
            }
        }
        
        boardView?.tableBoard.boardViewForVisibleTextComposeView = boardView
//        let tableView = boardView.tableView
//        let indexPath = NSIndexPath(forRow: tableView.numberOfRowsInSection(0) - 1, inSection: 0)
//        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    func showTextComposeView() {
        titleButton.isHidden = true
        addSubview(textComposeView)
        textComposeView.frame.size.height = newCellComposeViewHeight
        textComposeView.layoutIfNeeded()
        textComposeView.textField.becomeFirstResponder()
    }
    
    func hideTextComposeView() {
        titleButton.isHidden = false
        textComposeView.textField.resignFirstResponder()
        textComposeView.removeFromSuperview()
        textComposeView.textField.text = nil
        boardView?.footerViewHeightConstant = footerViewHeight
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension STBoardFooterView: TextComposeViewDelegate {
    func textComposeView(textComposeView view: TextComposeView, didClickDoneButton button: UIButton, withText text: String) {
        textComposeView.textField.text = nil
        
        if let boardView = boardView {
            boardView.delegate?.boardView(boardView, didClickDoneButtonForAddNewRow: button, withRowTitle: text)
        }
    }
    
    func textComposeView(textComposeView view: TextComposeView, didClickCancelButton button: UIButton) {
        hideTextComposeView()
        if let boardView = boardView {
            boardView.delegate?.boardViewDidClickCancelButtonForAddNewRow(boardView)
        }
    }
    
    func textComposeViewDidBeginEditing(textComposeView view: TextComposeView) {
        boardView?.footerViewBeginEditing()
    }
}

