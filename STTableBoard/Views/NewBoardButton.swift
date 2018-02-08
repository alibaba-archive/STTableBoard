//
//  NewBoardButton.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/4.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

protocol NewBoardButtonDelegate: class {
    func newBoardButtonDidBeClicked(newBoardButton button: NewBoardButton)
}

class NewBoardButton: UIView {
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    weak var delegate: NewBoardButtonDelegate?

    fileprivate lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        return view
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewDidBeClicked))
        return gesture
    }()

    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.textColor = .grayTextColor
        label.font = .systemFont(ofSize: 17.0)
        return label
    }()

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let roundedPath = UIBezierPath(roundedRect: rect, cornerRadius: 4.0)
        context?.setFillColor(UIColor.white.cgColor)
        newBoardButtonBackgroundColor.setFill()
        roundedPath.fill()

        let roundedRect = rect.insetBy(dx: 1.0, dy: 1.0)
        let dashedPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: 4.0)
        let pattern: [CGFloat] = [6, 6]
        dashedPath.setLineDash(pattern, count: 2, phase: 0.0)
        dashedLineColor.setStroke()
        dashedPath.stroke()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(titleLabel)
        backgroundColor = .clear

        addGestureRecognizer(tapGesture)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let views: [String: UIView] = ["imageView": imageView, "titleLabel": titleLabel]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(15)-[imageView(==18)]-(10)-[titleLabel]-(10)-|", options: .alignAllCenterY, metrics: nil, views: views)
        let imageViewHeight = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 18.0)
        let imageViewCenterY = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate(horizontalConstraints + [imageViewHeight, imageViewCenterY])
    }

    @objc func viewDidBeClicked() {
        delegate?.newBoardButtonDidBeClicked(newBoardButton: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
