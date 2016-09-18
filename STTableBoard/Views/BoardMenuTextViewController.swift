//
//  BoardMenuTextViewController.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/14.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

let textFieldPaddingX: CGFloat = 15.0
let textFieldPaddingY: CGFloat = 20.0

class BoardMenuTextViewController: UIViewController {
    
    var boardTitle: String? {
        didSet {
            textField.text = boardTitle
        }
    }
    
    var textField: UITextField = {
        let textField = UITextField(frame: CGRect.zero)
        textField.returnKeyType = .done
        let indentView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        textField.leftView = indentView
        textField.leftViewMode = .always
        let layer = textField.layer
        layer.masksToBounds = true
        layer.cornerRadius = 4.0
        layer.borderWidth = 1.0
        layer.borderColor = boardMenuTextFieldBorderColor.cgColor
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localizedString["STTableBoard.BoardMenuTextViewController.Title"]
        self.view.backgroundColor = boardMenuTextViewControllerBackgroundColor
        textField.backgroundColor = UIColor.white
        
        textField.delegate = self
        view.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let metrics = ["leading": textFieldPaddingX, "trailling": textFieldPaddingX, "top": textFieldPaddingY, "bottom": textFieldPaddingY]
        let views = ["textField": textField]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leading-[textField]-trailling-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[textField]-bottom-|", options: [], metrics: metrics, views: views)
        let topConstraints = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: textFieldPaddingY)
        
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints + [topConstraints])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BoardMenuTextViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = textField.text else { return false }
        if text != boardTitle && text.characters.count > 0{
            guard let boardMenu = self.navigationController as? BoardMenu else { return true }
            boardMenu.boardMenuDelegate?.boardMenu(boardMenu, boardMenuHandleType: BoardMenuHandleType.boardTitleChanged, userInfo: [newBoardTitleKey: text])
        }
        _ = navigationController?.popViewController(animated: true)
        return true
    }
}
