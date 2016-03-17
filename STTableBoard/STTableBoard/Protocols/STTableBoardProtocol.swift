//
//  STTableBoardDelegate.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/24.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

public protocol STTableBoardDelegate: class {
    func tableBoard(tableBoard:STTableBoard, heightForRowAtIndexPath indexPath: STIndexPath) -> CGFloat
    func tableBoard(tableBoard: STTableBoard, willAddNewBoardAtIndex index: Int, withBoardTitle title: String)
    func tableBoard(tableBoard: STTableBoard, willRemoveBoardAtIndex index: Int)
    func tableBoard(tableBoard: STTableBoard, boardTitleBeChangedTo title: String, inBoard board: Int)
}

public extension STTableBoardDelegate {
    func tableBoard(tableBoard:STTableBoard, heightForRowAtIndexPath indexPath: STIndexPath) -> CGFloat {
        return 44.0
    }
}

public protocol STTableBoardDataSource: class {
    func numberOfBoardsInTableBoard(tableBoard: STTableBoard) -> Int
    func tableBoard(tableBoard: STTableBoard, numberOfRowsInBoard board: Int) -> Int
    func tableBoard(tableBoard: STTableBoard, cellForRowAtIndexPath indexPath: STIndexPath) -> UITableViewCell
    func tableBoard(tableBoard: STTableBoard, titleForBoardInBoard board: Int) -> String?
    func tableBoard(tableBoard: STTableBoard, didAddRowAtBoard board: Int, withRowTitle title: String)

    // move row
    func tableBoard(tableBoard: STTableBoard, canMoveRowAtIndexPath indexPath: STIndexPath) -> Bool
    func tableBoard(tableBoard: STTableBoard, shouldMoveRowAtIndexPath sourceIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath) -> Bool
    func tableBoard(tableBoard: STTableBoard, moveRowAtIndexPath sourceIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath)
    func tableBoard(tableBoard: STTableBoard, didEndMoveRowAtOriginIndexPath originIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath)
    
    // move board
    func tableBoard(tableBoard: STTableBoard, canMoveBoardAtIndex index: Int) -> Bool
    func tableBoard(tableBoard: STTableBoard, moveBoardAtIndex sourceIndex: Int, toIndex destinationIndex: Int)
    func tableBoard(tableBoard: STTableBoard, didEndMoveBoardAtOriginIndex originIndex: Int, toIndex destinationIndex: Int)
}

public extension STTableBoardDataSource {
    func numberOfBoardsInTableBoard(tableBoard: STTableBoard) -> Int {
        return 1
    }

    func tableBoard(tableBoard: STTableBoard, titleForBoardInBoard board: Int) -> String? {
        return nil
    }

    // move row
    func tableBoard(tableBoard: STTableBoard, canMoveRowAtIndexPath indexPath: STIndexPath) -> Bool {
        return true
    }
    
    func tableBoard(tableBoard: STTableBoard, shouldMoveRowAtIndexPath sourceIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath) -> Bool {
        return true
    }

    func tableBoard(tableBoard:STTableBoard, moveRowAtIndexPath sourceIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath) {
        return
    }

    func tableBoard(tableBoard: STTableBoard, didEndMoveRowAtOriginIndexPath originIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath) {
        return
    }
    
    // move board
    func tableBoard(tableBoard: STTableBoard, canMoveBoardAtIndex index: Int) -> Bool {
        return true
    }

    func tableBoard(tableBoard: STTableBoard, moveBoardAtIndex sourceIndex: Int, toIndex destinationIndex: Int) {
        return
    }
    
    func tableBoard(tableBoard: STTableBoard, didEndMoveBoardAtOriginIndex originIndex: Int, toIndex destinationIndex: Int) {
        return
    }
}
