//
//  RoundAvatarImageView.swift
//  STTableBoardDemo
//
//  Created by DangGu on 15/12/21.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

class RoundAvatarImageView: UIView {
    
    private lazy var avatarImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .ScaleToFill
        return imageView
    }()
    
    private lazy var maskImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: self.bounds)
        imageView.backgroundColor = UIColor.clearColor()
        imageView.image = UIImage(named: "avatarMask")
        imageView.contentMode = .ScaleToFill
        return imageView
    }()
    
    var image: UIImage? {
        didSet {
            self.avatarImageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(avatarImageView)
        addSubview(maskImageView)
    }
    
    override func layoutSubviews() {
        avatarImageView.frame = self.bounds
        maskImageView.frame = self.bounds
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
}
