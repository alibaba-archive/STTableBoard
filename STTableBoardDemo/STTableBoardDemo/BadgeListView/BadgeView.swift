//
//  BagdeView.swift
//  BadgeListView
//
//  Created by DangGu on 15/12/22.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

public class BadgeView: UIView {
    
    public var imageWidth: CGFloat = 10.0
    
    public var titlePaddingX: CGFloat = 5 {
        didSet{
            resizeTitleLabel()
        }
    }
    
    public var titlePaddingY: CGFloat = 2 {
        didSet{
            resizeTitleLabel()
        }
    }
    
    public var imagePaddingX: CGFloat = 5 {
        didSet{
            resizeImageView()
        }
    }
    
    public var textFont: UIFont = UIFont.systemFontOfSize(12.0) {
        didSet {
            titleLabel.font = textFont
        }
    }
    
    public var textColor: UIColor = UIColor.blackColor() {
        didSet {
            titleLabel.textColor = textColor
        }
    }
    
    public var text: String? {
        didSet {
            titleLabel.text = text
        }
    }
    
    public var image: UIImage? {
        didSet {
            imageView.image = image
            resizeImageView()
        }
    }
    
    public var backgroundImage: UIImage? {
        didSet {
            backgroundImageView.image = backgroundImage
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRectZero)
        return imageView
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: self.bounds)
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRectZero)
        label.textAlignment = .Left
        label.font = self.textFont
        label.numberOfLines = 1
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        addSubview(backgroundImageView)
        addSubview(imageView)
        addSubview(titleLabel)
        self.frame.size = intrinsicContentSize()
    }

    override public func intrinsicContentSize() -> CGSize {
        var size = titleLabel.text?.sizeWithAttributes([NSFontAttributeName: textFont]) ?? CGSizeZero
        
        size.height += 2 * titlePaddingY
        if let _ = image {
            size.width += imagePaddingX + imageWidth + 2 * titlePaddingX
        } else {
            size.width += 2 * titlePaddingX
        }
        
        return size
    }
    
    func resizeTitleLabel() {
        if let _ = image {
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
        if let _ = image {
            imageView.frame = CGRect(x: imagePaddingX, y: titleLabel.center.y - imageWidth/2, width: imageWidth, height: imageWidth)
        } else {
             imageView.frame = CGRect(x: imagePaddingX, y: titleLabel.center.y - imageWidth/2, width: 0, height: 0)
        }
    }
    
    public override func sizeToFit() {
        super.sizeToFit()
        resizeTitleLabel()
        resizeImageView()
        self.frame.size = intrinsicContentSize()
        resizeBackgroundImageView()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
