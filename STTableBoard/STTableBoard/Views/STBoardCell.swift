//
//  STBoardCell.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/26.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

public class STBoardCell: UITableViewCell {
    
    var snapshot: UIView {
        get {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
            self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let snapshot = UIImageView(image: image)
            let layer = snapshot.layer
            layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
            layer.shadowRadius = 5.0
            layer.shadowOpacity = 0.4
            return snapshot
        }
    }
    
    var moving: Bool = false {
        didSet {
            let alpha: CGFloat = moving ? 0.0 : 1.0
            self.contentView.alpha = alpha
            self.alpha = alpha
            self.backgroundView?.alpha = alpha
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        // Initialization code
    }
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
