//
//  STTableBoardDelegate.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/24.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

public protocol STTableBoardDelegate: class {
    func tableBoard(tableBoard tableBoard:STTableBoard, heightForRowAtIndexPath indexPath: STIndexPath) -> CGFloat
    func tableBoard(tableBoard tableBoard: STTableBoard, willAddNewBoardAtIndex index: Int, withBoardTitle title: String)
    func tableBoard(tableBoard tableBoard: STTableBoard, willRemoveBoardAtIndex index: Int)
    func tableBoard(tableBoard tableBoard: STTableBoard, boardTitleBeChangedTo title: String, inBoard board: Int)
}

public extension STTableBoardDelegate {
    func tableBoard(tableBoard tableBoard:STTableBoard, heightForRowAtIndexPath indexPath: STIndexPath) -> CGFloat {
        return 44.0
    }
}

public protocol STTableBoardDataSource: class {
    func numberOfBoardsInTableBoard(tableBoard: STTableBoard) -> Int
    func tableBoard(tableBoard tableBoard: STTableBoard, numberOfRowsInBoard board: Int) -> Int
    func tableBoard(tableBoard tableBoard: STTableBoard, cellForRowAtIndexPath indexPath: STIndexPath) -> UITableViewCell
    func tableBoard(tableBoard tableBoard: STTableBoard, moveRowAtIndexPath sourceIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath)
    func tableBoard(tableBoard tableBoard: STTableBoard, moveBoardAtIndex sourceIndex: Int, toIndex destinationIndex: Int)
    func tableBoard(tableBoard tableBoard: STTableBoard, titleForBoardInBoard board: Int) -> String?
    func tableBoard(tableBoard tableBoard: STTableBoard, didAddRowAtBoard board: Int, withRowTitle title: String)
}

public extension STTableBoardDataSource {
    func numberOfBoardsInTableBoard(tableBoard: STTableBoard) -> Int {
        return 1
    }

    func tableBoard(tableBoard tableBoard:STTableBoard, moveRowAtIndexPath sourceIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath) {
        return
    }
    
    func tableBoard(tableBoard tableBoard: STTableBoard, moveBoardAtIndex sourceIndex: Int, toIndex destinationIndex: Int) {
        return
    }
    
    func tableBoard(tableBoard tableBoard: STTableBoard, titleForBoardInBoard board: Int) -> String? {
        return nil
    }
}
