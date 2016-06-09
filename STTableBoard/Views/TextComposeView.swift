//
//  TextComposeView.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/4.
//  Copyright © 2016年 StormXX. All rights reserved.
//

protocol TextComposeViewDelegate: class {
    func textComposeViewDidBeginEditing(textComposeView view: TextComposeView)
    func textComposeView(textComposeView view: TextComposeView, didClickDoneButton button: UIButton, withText text: String)
    func textComposeView(textComposeView view: TextComposeView, didClickCancelButton button: UIButton)
}

extension TextComposeViewDelegate {
    func textComposeViewDidBeginEditing(textComposeView view: TextComposeView) {}
}

import UIKit

class TextComposeView: UIView {
    
    weak var delegate: TextComposeViewDelegate?
    var textFieldHeight: CGFloat = 56.0
    
    lazy var textField: UITextField = {
        let field = UITextField(frame: CGRect.zero)
        field.borderStyle = .RoundedRect
        field.font = UIFont.systemFontOfSize(15.0)
        field.textColor = UIColor(red: 56/255.0, green: 56/255.0, blue: 56/255.0, alpha: 1.0)
        field.delegate = self
        field.returnKeyType = .Done
        return field
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.setTitle(localizedString["STTableBoard.Cancel"], forState: .Normal)
        button.setTitleColor(cancelButtonTextColor, forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(TextComposeView.cancelButtonClicked(_:)), forControlEvents: .TouchUpInside)
        button.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        return button
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.setTitle(localizedString["STTableBoard.Create"], forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.setBackgroundImage(UIImage(named: "doneButton_background", inBundle: currentBundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(TextComposeView.doneButtonClicked(_:)), forControlEvents: .TouchUpInside)
        button.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        return button
    }()
    
    
    init(frame: CGRect, textFieldHeight: CGFloat, cornerRadius: CGFloat) {
        super.init(frame: frame)
        
        layer.borderColor = boardBorderColor.CGColor
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
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
        let fieldVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[textField(==textFieldHeight)]-10-[doneButton(==36)]", options: [], metrics: ["textFieldHeight": textFieldHeight], views: views)
        let buttonHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[cancelButton(==64)]-5-[doneButton(==64)]-10-|", options: [.AlignAllCenterY], metrics: nil, views: views)
        let buttonEqualHeight = NSLayoutConstraint(item: cancelButton, attribute: .Height, relatedBy: .Equal, toItem: doneButton, attribute: .Height, multiplier: 1.0, constant: 0.0)
        
        let vflConstraints = fieldHorizontalConstraints + fieldVerticalConstraints + buttonHorizontalConstraints
        let constraints = [buttonEqualHeight]
        NSLayoutConstraint.activateConstraints(vflConstraints + constraints)
    }
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame, textFieldHeight: 56.0, cornerRadius: 4.0)
    }
    
    func cancelButtonClicked(sender: UIButton) {
        textField.resignFirstResponder()
        delegate?.textComposeView(textComposeView: self, didClickCancelButton: sender)
    }
    
    func doneButtonClicked(sender: UIButton) {
        if let text = textField.text {
            let trimedText = text.trim()
            if trimedText.characters.count > 0 {
                delegate?.textComposeView(textComposeView: self, didClickDoneButton: doneButton, withText: trimedText)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextComposeView: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = textField.text {
            let trimedText = text.trim()
            if trimedText.characters.count > 0 {
                delegate?.textComposeView(textComposeView: self, didClickDoneButton: doneButton, withText: trimedText)
            } else {
                return false
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.textComposeViewDidBeginEditing(textComposeView: self)
    }
}
