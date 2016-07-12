//
//  BoardMenuNavigationController.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/9.
//  Copyright © 2016年 StormXX. All rights reserved.
//
protocol BoardMenuDelegate: class {
    func boardMenu(boardMenu: BoardMenu, boardMenuHandleType type: BoardMenuHandleType, userInfo: [String: AnyObject?]?)
}

import UIKit

class BoardMenu: UINavigationController {

    private var boardMenuTableViewController: BoardMenuTableViewController!
    
    weak var boardMenuDelegate: BoardMenuDelegate?
    weak var tableBoard: STTableBoard?
    var boardIndex: Int = 0
    var boardMenuTitle: String? {
        didSet{
            self.boardMenuTableViewController.title = boardMenuTitle
        }
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    convenience init() {
        let rootViewController = BoardMenuTableViewController(style: .Plain)
        self.init(rootViewController: rootViewController)
        self.boardMenuTableViewController = rootViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = view.layer
        layer.masksToBounds = true
        layer.cornerRadius = 6.0
//        layer.borderColor = boardBorderColor.CGColor
//        layer.borderWidth = 1.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
