//
//  ViewController.swift
//  STTableBoard
//
//  Created by DangGu on 15/10/25.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var dataArray: [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.edgesForExtendedLayout = UIRectEdge.None
        
//        dataArray = [
//            ["最后的战役1","最后的战役2","最后的战役3"],
//            ["七里香1","七里香2","七里香3","七里香4","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3"],
//            ["晴天1","晴天2","晴天3","晴天4","晴天5"]
//        ]
        
//        dataArray = [
//            ["最后的战役1","最后的战役2","最后的战役3"],
//            ["晴天1","晴天2","晴天3","晴天4","晴天5"]
//        ]
        
        dataArray = [
            ["最后的战役1","最后的战役2","最后的战役3"],
            ["晴天1","晴天2","晴天3","晴天4","晴天5"],
            ["七里香1","七里香2","七里香3","七里香4","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3"]
        
        ]
        
        let table = STTableBoard()
        table.registerClasses(classAndIdentifier: [(STBoardCell.self,"DefaultCell")])
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
        return dataArray.count
    }
    
    func tableBoard(tableBoard tableBoard: STTableBoard, numberOfRowsInBoard board: Int) -> Int {
        return dataArray[board].count
    }
    
    func tableBoard(tableBoard tableBoard: STTableBoard, cellForRowAtIndexPath indexPath: STIndexPath) -> UITableViewCell {
        let cell = tableBoard.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)
        cell.textLabel?.text = dataArray[indexPath.board][indexPath.row]
        cell.contentView.backgroundColor = UIColor.果灰()
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableBoard(tableBoard tableBoard: STTableBoard, moveRowAtIndexPath sourceIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath) {
        let data = dataArray[sourceIndexPath.board][sourceIndexPath.row]
        dataArray[sourceIndexPath.board].removeAtIndex(sourceIndexPath.row)
        dataArray[destinationIndexPath.board].insert(data, atIndex: destinationIndexPath.row)
    }
}

