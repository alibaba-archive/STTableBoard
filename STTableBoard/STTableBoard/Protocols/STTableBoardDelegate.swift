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
}

extension STTableBoardDelegate {
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
}

extension STTableBoardDataSource {
    func numberOfBoardsInTableBoard(tableBoard: STTableBoard) -> Int {
        return 1
    }

    func tableBoard(tableBoard tableBoard:STTableBoard, moveRowAtIndexPath sourceIndexPath: STIndexPath, toIndexPath destinationIndexPath: STIndexPath) {
        return
    }
    
    func tableBoard(tableBoard tableBoard: STTableBoard, moveBoardAtIndex sourceIndex: Int, toIndex destinationIndex: Int) {
        return
    }
}
