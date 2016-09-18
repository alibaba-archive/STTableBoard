//
//  CheckBoxView.swift
//  STTableBoardDemo
//
//  Created by DangGu on 15/12/23.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

class CheckBoxView: UIImageView{
    
    fileprivate let uncheckedImageName = "checkbox"
    fileprivate let checkedImageName = "checkbox"
    
    var checked: Bool = false {
        didSet {
            self.image = checked ? UIImage(named: checkedImageName) : UIImage(named: uncheckedImageName)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        checked = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
