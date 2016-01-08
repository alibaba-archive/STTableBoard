//
//  BoardMenu.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/7.
//  Copyright © 2016年 StormXX. All rights reserved.
//

protocol BoardMenuDelegate: class {
    func didSelectRowAtIndexPath(indexPath: NSIndexPath)
}

import UIKit

class BoardMenu: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var boardIndex: Int!
    weak var delegate: BoardMenuDelegate?

    lazy var boardMenuTableViewController: BoardMenuTableViewController = {
        let controller = BoardMenuTableViewController(style: .Grouped)
        return controller
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let controller = BoardMenuTableViewController(style: .Grouped)
        let navigationController: UINavigationController = UINavigationController(rootViewController: controller)
        navigationController.view.frame = CGRect(origin: CGPointZero, size: bounds.size)
        controller.view.frame = CGRect(origin: CGPointZero, size: bounds.size)
        addSubview(controller.view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showBoardMenu() {
        
    }
    
    func hiddenBoardMenu() {
    
    }

}
