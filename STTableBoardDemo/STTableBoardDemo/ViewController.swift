//
//  ViewController.swift
//  STTableBoardDemo
//
//  Created by DangGu on 15/12/14.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit
import STTableBoard

class ViewController: UIViewController {
    
    var dataArray: [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.edgesForExtendedLayout = UIRectEdge.None
        
        //        dataArray = [
        //            ["最后的战役1","最后的战役2","最后的战役3"],
        //            ["晴天1","晴天2","晴天3","晴天4","晴天5"]
        //        ]
        
        dataArray = [
            ["七里香1","七里香2","七里香3","七里香4","最后的战役1","最后的战役2","最后的战役3","晴天1","晴天2","晴天3","晴天4","晴天5","爱情悬崖1","爱情悬崖2","爱情悬崖3","爱情悬崖4","彩虹1","彩虹2","彩虹3","彩虹4"],
            ["最后的战役1","最后的战役2","最后的战役3"],
            ["晴天1","晴天2","晴天3","晴天4","晴天5"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
            ["星晴1","星晴2","星晴3"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6"],
        ]
        
        let table = STTableBoard()
        table.registerClasses(classAndIdentifier: [(STBoardCell.self,"DefaultCell")])
        table.delegate = self
        table.dataSource = self
        self.addChildViewController(table)
        view.addSubview(table.view)
        table.didMoveToParentViewController(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ViewController: STTableBoardDelegate {
    func tableBoard(tableBoard tableBoard: STTableBoard, heightForRowAtIndexPath indexPath: STIndexPath) -> CGFloat {
        return 44.0
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
        let cell = tableBoard.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath) as! STBoardCell
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
    
    func tableBoard(tableBoard tableBoard: STTableBoard, moveBoardAtIndex sourceIndex: Int, toIndex destinationIndex: Int) {
        let sourceData = dataArray[sourceIndex]
        let destinationData = dataArray[destinationIndex]
        dataArray[sourceIndex] = destinationData
        dataArray[destinationIndex] = sourceData
    }
}

