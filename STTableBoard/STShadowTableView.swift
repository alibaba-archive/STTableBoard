//
//  STShadowTableView.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/25.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

class STShadowTableView: UITableView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var index: Int!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.separatorStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
