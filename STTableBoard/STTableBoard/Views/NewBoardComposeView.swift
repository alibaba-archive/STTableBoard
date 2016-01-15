//
//  NewBoardComposeView.swift
//  UITestProject
//
//  Created by DangGu on 16/1/4.
//  Copyright © 2016年 StormXX. All rights reserved.
//

protocol NewBoardComposeViewDelegate: class {
    func newBoardComposeView(newBoardComposeView view: NewBoardComposeView, didClickDoneButton button: UIButton, withBoardTitle title: String)
    func newBoardComposeView(newBoardComposeView view: NewBoardComposeView, didClickCancelButton button: UIButton)
}

import UIKit

class NewBoardComposeView: UIView {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    weak var delegate: NewBoardComposeViewDelegate?
    
    lazy var textField: UITextField = {
        let field = UITextField(frame: CGRectZero)
        field.borderStyle = .RoundedRect
        field.font = UIFont.systemFontOfSize(15.0)
        field.textColor = UIColor(red: 56/255.0, green: 56/255.0, blue: 56/255.0, alpha: 1.0)
        field.delegate = self
        field.returnKeyType = .Done
        return field
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(frame: CGRectZero)
        button.setTitle("取消", forState: .Normal)
        button.setTitleColor(cancelButtonTextColor, forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.clipsToBounds = true
        button.addTarget(self, action: "cancelButtonClicked:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(frame: CGRectZero)
        button.setTitle("确定", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.setBackgroundImage(UIImage(named: "doneButton_background", inBundle: currentBundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.clipsToBounds = true
        button.addTarget(self, action: "doneButtonClicked:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = boardBorderColor.CGColor
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        layer.cornerRadius = 4.0
        backgroundColor = boardBackgroundColor
        
        clipsToBounds = true
        addSubview(textField)
        addSubview(cancelButton)
        addSubview(doneButton)

        textField.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        let views = ["textField":textField, "cancelButton":cancelButton, "doneButton":doneButton]
        let fieldHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[textField]-10-|", options: [], metrics: nil, views: views)
        let fieldVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[textField(==56)]-10-[doneButton(==36)]", options: [], metrics: nil, views: views)
        let buttonHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[cancelButton(==64)]-5-[doneButton(==64)]-10-|", options: [.AlignAllCenterY], metrics: nil, views: views)
        let buttonEqualHeight = NSLayoutConstraint(item: cancelButton, attribute: .Height, relatedBy: .Equal, toItem: doneButton, attribute: .Height, multiplier: 1.0, constant: 0.0)
        
        let vflConstraints = fieldHorizontalConstraints + fieldVerticalConstraints + buttonHorizontalConstraints
        let constraints = [buttonEqualHeight]
        NSLayoutConstraint.activateConstraints(vflConstraints + constraints)
    }
    
    func cancelButtonClicked(sender: UIButton) {
        delegate?.newBoardComposeView(newBoardComposeView: self, didClickCancelButton: sender)
    }
    
    func doneButtonClicked(sender: UIButton) {
        if let text = textField.text {
            let trimedText = text.trim()
            if trimedText.characters.count > 0 {
                delegate?.newBoardComposeView(newBoardComposeView: self, didClickDoneButton: sender, withBoardTitle: trimedText)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewBoardComposeView: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = textField.text {
            let trimedText = text.trim()
            if trimedText.characters.count > 0 {
                delegate?.newBoardComposeView(newBoardComposeView: self, didClickDoneButton: doneButton, withBoardTitle: trimedText)
            } else {
                return false
            }
        }
        textField.resignFirstResponder()
        return true
    }
}
