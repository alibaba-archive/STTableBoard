//
//  ViewController.swift
//  STTableBoard
//
//  Created by DangGu on 15/10/25.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.edgesForExtendedLayout = UIRectEdge.None
        
        let table = STTableBoard()
        table.registerClasses(classAndIdentifier: [(UITableViewCell.self,"DefaultCell")])
        table.dataSource = self
        self.addChildViewController(table)
        view.addSubview(table.view)
        table.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ViewController: STTableBoardDataSource {
    func numberOfBoardsInTableBoard(tableBoard: STTableBoard) -> Int {
        return 5
    }
    
    func tableBoard(tableBoard tableBoard: STTableBoard, numberOfRowsInBoard board: Int) -> Int {
        return board + 2
    }
    
    func tableBoard(tableBoard tableBoard: STTableBoard, cellForRowAtIndexPath indexPath: STIndexPath) -> UITableViewCell {
        let cell = tableBoard.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)
        cell.textLabel?.text = "最后的战役"
        cell.backgroundColor = UIColor.果灰()
        return cell
    }
}

