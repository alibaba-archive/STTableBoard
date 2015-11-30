//
//  STBoardCell.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/26.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

class STBoardCell: UITableViewCell {
    
    var snapshot: UIView {
        get {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0);
            self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            let snapshot = UIImageView(image: image)
            let layer = snapshot.layer
            layer.masksToBounds = false;
            layer.cornerRadius = 0.0;
            layer.shadowOffset = CGSizeMake(-5.0, 0.0);
            layer.shadowRadius = 5.0;
            layer.shadowOpacity = 0.4;
            return snapshot;
        }
    }
    
    var moving: Bool = false {
        didSet {
            let alpha: CGFloat = moving ? 0.0 : 1.0
            self.contentView.alpha = alpha
            self.alpha = alpha
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
