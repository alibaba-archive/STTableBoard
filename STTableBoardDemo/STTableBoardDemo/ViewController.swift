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
    var titleArray: [String] = []
    let tableBoard: STTableBoard! = STTableBoard()
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        self.title = "Teambition"
        addAddButton()
        dataArray = [
            ["七里香1","七里香2","七里香3","七里香4","最后的战役1","最后的战役2","最后的战役3","晴天1","晴天2","晴天3","晴天4","晴天5","爱情悬崖1","爱情悬崖2","爱情悬崖3","爱情悬崖4","彩虹1","彩虹2","彩虹3","彩虹4"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3"],
            []
        ]
        
        titleArray = ["七里香", "星晴", "彩虹", "彩虹", "彩虹", "Empty"]
        
        tableBoard.contentInset = UIEdgeInsets(top: 64.0, left: 0, bottom: 0, right: 0)
        tableBoard.sizeOffset = CGSize(width: 80.0, height: 0)
        tableBoard.registerClasses(classAndIdentifier: [(BoardCardCell.self,"DefaultCell")])
        tableBoard.delegate = self
        tableBoard.dataSource = self
        tableBoard.showAddBoardButton = true
        view.frame.size.height -= 64.0
        tableBoard.view.frame.size = view.frame.size
        self.addChildViewController(tableBoard)
        view.addSubview(tableBoard.view)
        tableBoard.didMoveToParentViewController(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("isEmpty \(tableBoard.isEmpty(0))")
    }
    
    func addAddButton() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ViewController.doneButtonClick))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func doneButtonClick() {
        let indexPath1 = STIndexPath(forRow: dataArray[1].count, inBoard: 1)
        dataArray[1].append("wtf")
        tableBoard.insertRowAtIndexPath(indexPath1, withRowAnimation: .Fade, atScrollPosition: .Bottom)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ViewController: STTableBoardDelegate {
    func tableBoard(tableBoard: STTableBoard, heightForRowAtIndexPath indexPath: STIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableBoard(tableBoard: STTableBoard, willRemoveBoardAtIndex index: Int) {
        dataArray.removeAtIndex(index)
        titleArray.removeAtIndex(index)
    }
    
    func tableBoard(tableBoard: STTableBoard, willAddNewBoardAtIndex index: Int, withBoardTitle title: String) {
        dataArray.append([])
        titleArray.append(title)
        tableBoard.insertBoardAtIndex(index, withAnimation: true)
    }
    
    func tableBoard(tableBoard: STTableBoard, didSelectRowAtIndexPath indexPath: STIndexPath) {
        print("board \(indexPath.board) row \(indexPath.row)")
        if let cell = tableBoard.cellForRowAtIndexPath(indexPath) as? BoardCardCell {
            print("cell's title \(cell.titleText)")
        }
    }
}

extension ViewController: STTableBoardDataSource {
    func tableBoard(tableBoard: STTableBoard, titleForBoardInBoard board: Int) -> String? {
        return titleArray[board]
    }
    
    func numberOfBoardsInTableBoard(tableBoard: STTableBoard) -> Int {
        return dataArray.count
    }
    
    func tableBoard(tableBoard: STTableBoard, numberOfRowsInBoard board: Int) -> Int {
        return dataArray[board].count
    }
    
    func tableBoard(tableBoard: STTableBoard, cellForRowAtIndexPath indexPath: STIndexPath) -> UITableViewCell {
        let cell = tableBoard.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath) as! BoardCardCell
        cell.titleText = dataArray[indexPath.board][indexPath.row]
        return cell
    }

    func tableBoard(tableBoard: STTableBoard, boardTitleBeChangedTo title: String, inBoard board: Int) {
        titleArray[board] = title
    }
    
    func tableBoard(tableBoard: STTableBoard, didAddRowAtBoard board: Int, withRowTitle title: String) {
        let indexPath = STIndexPath(forRow: dataArray[board].count, inBoard: board)
        dataArray[board].append(title)
        tableBoard.insertRowAtIndexPath(indexPath, withRowAnimation: .Fade, atScrollPosition: .Bottom)
    }
    
    // move row
    func tableBoard(tableBoard: STTableBoard, moveRowAtIndexPath sourceIndexPath: STIndexPath, inout toIndexPath destinationIndexPath: STIndexPath) {
        destinationIndexPath = STIndexPath(forRow: 0, inBoard: destinationIndexPath.board)
        let data = dataArray[sourceIndexPath.board][sourceIndexPath.row]
        dataArray[sourceIndexPath.board].removeAtIndex(sourceIndexPath.row)
        dataArray[destinationIndexPath.board].insert(data, atIndex: destinationIndexPath.row)
    }
    
    func tableBoard(tableBoard: STTableBoard, shouldMoveRowAtIndexPath sourceIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath) -> Bool {
        if destinationIndexPath.board == 1 && destinationIndexPath.row == 1 {
            return false
        }
        return true
    }
    
    func tableBoard(tableBoard: STTableBoard, canMoveRowAtIndexPath indexPath: STIndexPath) -> Bool {
        if indexPath.board == 0 && indexPath.row == 2 {
            return false
        }
        return true
    }
    
    func tableBoard(tableBoard: STTableBoard, didEndMoveRowAtOriginIndexPath originIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath) {
        print("originIndexPath \(originIndexPath), destinationIndexPath \(destinationIndexPath)")
    }
    
    // move board
    func tableBoard(tableBoard: STTableBoard, moveBoardAtIndex sourceIndex: Int, toIndex destinationIndex: Int) {
        let sourceData = dataArray[sourceIndex]
        let destinationData = dataArray[destinationIndex]
        dataArray[sourceIndex] = destinationData
        dataArray[destinationIndex] = sourceData
    }
    
    func tableBoard(tableBoard: STTableBoard, canMoveBoardAtIndex index: Int) -> Bool {
        if index == 0 {
            return false
        }
        return true
    }

    func tableBoard(tableBoard: STTableBoard, shouldMoveBoardAtIndex sourceIndex: Int, toIndex destinationIndex: Int) -> Bool {
        if destinationIndex == dataArray.count - 1 {
            return false
        }
        return true
    }
    
    func tableBoard(tableBoard: STTableBoard, didEndMoveBoardAtOriginIndex originIndex: Int, toIndex destinationIndex: Int) {
        print("originIndex \(originIndex), destinationIndex \(destinationIndex)")
    }
}
