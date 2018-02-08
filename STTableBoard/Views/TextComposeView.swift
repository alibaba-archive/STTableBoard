//
//  TextComposeView.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/4.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

protocol TextComposeViewDelegate: class {
    func textComposeViewDidBeginEditing(textComposeView view: TextComposeView)
    func textComposeView(textComposeView view: TextComposeView, didClickDoneButton button: UIButton, withText text: String)
    func textComposeView(textComposeView view: TextComposeView, didClickCancelButton button: UIButton)
}

extension TextComposeViewDelegate {
    func textComposeViewDidBeginEditing(textComposeView view: TextComposeView) {}
}

class TextComposeView: UIView {
    weak var delegate: TextComposeViewDelegate?
    var textFieldHeight: CGFloat = 56.0

    lazy var textField: UITextField = {
        let field = UITextField(frame: .zero)
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 15.0)
        field.textColor = UIColor(red: 56.0 / 255.0, green: 56.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)
        field.delegate = self
        field.returnKeyType = .done
        return field
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle(localizedString["STTableBoard.Cancel"], for: .normal)
        button.setTitleColor(cancelButtonTextColor, for: .normal)
        button.backgroundColor = .clear
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(cancelButtonClicked(_:)), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 15.0)
        return button
    }()

    lazy var doneButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle(localizedString["STTableBoard.Create"], for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.setBackgroundImage(UIImage(named: "doneButton_background", in: currentBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(doneButtonClicked(_:)), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 15.0)
        return button
    }()

    init(frame: CGRect, textFieldHeight: CGFloat, cornerRadius: CGFloat) {
        super.init(frame: frame)

        layer.borderColor = boardBorderColor.cgColor
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

        let views: [String: Any] = ["textField": textField, "cancelButton": cancelButton, "doneButton": doneButton]
        let fieldHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textField]-10-|", options: [], metrics: nil, views: views)
        let fieldVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[textField(==textFieldHeight)]-10-[doneButton(==36)]", options: [], metrics: ["textFieldHeight": textFieldHeight], views: views)
        let buttonHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelButton(==64)]-5-[doneButton(==64)]-10-|", options: [.alignAllCenterY], metrics: nil, views: views)
        let buttonEqualHeight = NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: doneButton, attribute: .height, multiplier: 1.0, constant: 0.0)

        let vflConstraints = fieldHorizontalConstraints + fieldVerticalConstraints + buttonHorizontalConstraints
        let constraints = [buttonEqualHeight]
        NSLayoutConstraint.activate(vflConstraints + constraints)
    }

    convenience override init(frame: CGRect) {
        self.init(frame: frame, textFieldHeight: 56.0, cornerRadius: 4.0)
    }

    @objc func cancelButtonClicked(_ sender: UIButton) {
        textField.resignFirstResponder()
        delegate?.textComposeView(textComposeView: self, didClickCancelButton: sender)
    }

    @objc func doneButtonClicked(_ sender: UIButton) {
        if let text = textField.text {
            let trimedText = text.trim()
            if !trimedText.isEmpty {
                delegate?.textComposeView(textComposeView: self, didClickDoneButton: doneButton, withText: trimedText)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextComposeView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            let trimedText = text.trim()
            if !trimedText.isEmpty {
                delegate?.textComposeView(textComposeView: self, didClickDoneButton: doneButton, withText: trimedText)
            } else {
                return false
            }
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textComposeViewDidBeginEditing(textComposeView: self)
    }
}
