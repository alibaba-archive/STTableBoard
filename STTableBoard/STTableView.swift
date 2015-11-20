//
//  STTableView.swift
//  STTableBoard
//
//  Created by DangGu on 15/10/25.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

class STTableView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        let layer = self.layer
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
