//
//  BagdeView.swift
//  BadgeListView
//
//  Created by DangGu on 15/12/22.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

open class BadgeView: UIView {

    open var imageWidth: CGFloat = 10.0

    open var titlePaddingX: CGFloat = 5 {
        didSet {
            resizeTitleLabel()
        }
    }

    open var titlePaddingY: CGFloat = 2 {
        didSet {
            resizeTitleLabel()
        }
    }

    open var imagePaddingX: CGFloat = 5 {
        didSet {
            resizeImageView()
        }
    }

    open var textFont: UIFont = .systemFont(ofSize: 12.0) {
        didSet {
            titleLabel.font = textFont
        }
    }

    open var textColor: UIColor = .black {
        didSet {
            titleLabel.textColor = textColor
        }
    }

    open var text: String? {
        didSet {
            titleLabel.text = text
        }
    }

    open var image: UIImage? {
        didSet {
            imageView.image = image
            resizeImageView()
        }
    }

    open var backgroundImage: UIImage? {
        didSet {
            backgroundImageView.image = backgroundImage
        }
    }

    fileprivate lazy var imageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: .zero)
        return imageView
    }()

    fileprivate lazy var backgroundImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: self.bounds)
        return imageView
    }()

    fileprivate lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: .zero)
        label.textAlignment = .left
        label.font = self.textFont
        label.numberOfLines = 1
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        addSubview(backgroundImageView)
        addSubview(imageView)
        addSubview(titleLabel)
        self.frame.size = intrinsicContentSize
    }

    override open var intrinsicContentSize: CGSize {
        var size = titleLabel.text?.size(withAttributes: [.font: textFont]) ?? CGSize.zero

        size.height += 2 * titlePaddingY
        if image != nil {
            size.width += imagePaddingX + imageWidth + 2 * titlePaddingX
        } else {
            size.width += 2 * titlePaddingX
        }

        return size
    }

    func resizeTitleLabel() {
        if image != nil {
            titleLabel.frame = CGRect(x: imagePaddingX + imageWidth + titlePaddingX, y: titlePaddingY, width: 0, height: 0)
        } else {
            titleLabel.frame = CGRect(x: titlePaddingX, y: titlePaddingY, width: 0, height: 0)
        }
        titleLabel.sizeToFit()
    }

    func resizeBackgroundImageView() {
        backgroundImageView.frame = self.bounds
    }

    func resizeImageView() {
        if image != nil {
            imageView.frame = CGRect(x: imagePaddingX, y: titleLabel.center.y - imageWidth/2, width: imageWidth, height: imageWidth)
        } else {
             imageView.frame = CGRect(x: imagePaddingX, y: titleLabel.center.y - imageWidth/2, width: 0, height: 0)
        }
    }

    open override func sizeToFit() {
        super.sizeToFit()
        resizeTitleLabel()
        resizeImageView()
        self.frame.size = intrinsicContentSize
        resizeBackgroundImageView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
