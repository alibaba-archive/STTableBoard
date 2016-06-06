//
//  STBoardFooterView.swift
//  STTableBoard
//
//  Created by DangGu on 15/12/17.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

class STBoardFooterView: UIView {
    
    var boardView: STBoardView!

    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.setTitle(localizedString["STTableBoard.AddRow"], forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        button.setTitleColor(boardFooterButtonTitleColor, forState: .Normal)
        button.contentHorizontalAlignment = .Left
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        button.addTarget(self, action: #selector(STBoardFooterView.addButtonTapped(_:)), forControlEvents: .TouchUpInside)
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
        let titleButtonHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleButton]-|", options: [], metrics: nil, views: views)
        let titleButtonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleButton]-|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activateConstraints(titleButtonHorizontalConstraints + titleButtonVerticalConstraints)
    }
    
    func addButtonTapped(sender: UIButton) {
        boardView.footerViewHeightConstant = newCellComposeViewHeight
        textComposeView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.width, height: newCellComposeViewHeight))
        showTextComposeView()
        if boardView.tableBoard.isAddBoardTextComposeViewVisible {
            boardView.tableBoard.hiddenTextComposeView()
            boardView.tableBoard.isAddBoardTextComposeViewVisible = false
        } else if let boardViewForVisibleTextComposeView = boardView.tableBoard.boardViewForVisibleTextComposeView {
            if boardViewForVisibleTextComposeView != boardView {
                boardViewForVisibleTextComposeView.hideTextComposeView()
            }
        }
        boardView.tableBoard.boardViewForVisibleTextComposeView = boardView
//        let tableView = boardView.tableView
//        let indexPath = NSIndexPath(forRow: tableView.numberOfRowsInSection(0) - 1, inSection: 0)
//        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    func showTextComposeView() {
        titleButton.hidden = true
        addSubview(textComposeView)
        textComposeView.frame.size.height = newCellComposeViewHeight
        textComposeView.layoutIfNeeded()
        textComposeView.textField.becomeFirstResponder()
    }
    
    func hideTextComposeView() {
        titleButton.hidden = false
        textComposeView.textField.resignFirstResponder()
        textComposeView.removeFromSuperview()
        textComposeView.textField.text = nil
        boardView.footerViewHeightConstant = footerViewHeight
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension STBoardFooterView: TextComposeViewDelegate {
    func textComposeView(textComposeView view: TextComposeView, didClickDoneButton button: UIButton, withText text: String) {
        textComposeView.textField.text = nil
        boardView.delegate?.boardView(boardView, didClickDoneButtonForAddNewRow: button, withRowTitle: text)
    }
    
    func textComposeView(textComposeView view: TextComposeView, didClickCancelButton button: UIButton) {
        hideTextComposeView()
    }
}

