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
        button.setTitleColor(.grayTextColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupProperty() {
        addSubview(titleButton)
        titleButton.translatesAutoresizingMaskIntoConstraints = false

        let views = ["titleButton": titleButton]
        let titleButtonHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[titleButton]-8-|", options: [], metrics: nil, views: views)
        let titleButtonVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[titleButton]-8-|", options: [], metrics: nil, views: views)

        NSLayoutConstraint.activate(titleButtonHorizontalConstraints + titleButtonVerticalConstraints)
    }

    @objc func addButtonTapped(_ sender: UIButton?) {
        if let boardView = boardView, let customAction = boardView.delegate?.customAddRowAction(for: boardView) {
            customAction()
            return
        }
        boardView?.footerViewHeightConstant = newCellComposeViewHeight
        textComposeView.frame = CGRect(origin: .zero, size: CGSize(width: self.width, height: newCellComposeViewHeight))
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
        let shouldEnableAddRow = boardView?.shouldEnableAddRow ?? true
        boardView?.footerViewHeightConstant = shouldEnableAddRow ? footerViewNormalHeight : footerViewDisabledHeight
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
