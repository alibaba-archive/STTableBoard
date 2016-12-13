//
//  STTableBoardDelegate.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/24.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

public protocol STTableBoardDelegate: class {
    func tableBoard(_ tableBoard: STTableBoard, heightForRowAt indexPath: STIndexPath) -> CGFloat
    func tableBoard(_ tableBoard: STTableBoard, didSelectRowAt indexPath: STIndexPath)
    func tableBoard(_ tableBoard: STTableBoard, willAddNewBoardAt index: Int, with boardTitle: String)
    func tableBoard(_ tableBoard: STTableBoard, willRemoveBoardAt index: Int) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, canEditBoardTitleAt boardIndex: Int) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, boardTitleBeChangedTo title: String, at boardIndex: Int)
    func tableBoard(_ tableBoard: STTableBoard, handlePinchGesture recognizer: UIPinchGestureRecognizer)
}

public extension STTableBoardDelegate {
    func tableBoard(_ tableBoard:STTableBoard, heightForRowAt indexPath: STIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableBoard(_ tableBoard: STTableBoard, didSelectRowAt indexPath: STIndexPath) {
        return
    }

    func tableBoard(_ tableBoard: STTableBoard, canEditBoardTitleAt boardIndex: Int) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, boardTitleBeChangedTo title: String, at boardIndex: Int) {
        return
    }

    func tableBoard(_ tableBoard: STTableBoard, handlePinchGesture recognizer: UIPinchGestureRecognizer) {
        return
    }
}

public protocol STTableBoardDataSource: class {
    func numberOfBoards(in tableBoard: STTableBoard) -> Int
    func tableBoard(_ tableBoard: STTableBoard, numberOfRowsAt boardIndex: Int) -> Int
    func tableBoard(_ tableBoard: STTableBoard, cellForRowAt indexPath: STIndexPath) -> UITableViewCell
    func tableBoard(_ tableBoard: STTableBoard, titleForBoardAt boardIndex: Int) -> String?
    func tableBoard(_ tableBoard: STTableBoard, numberForBoardAt boardIndex: Int) -> Int
    
    // add row
    func tableBoard(_ tableBoard: STTableBoard, willBeginAddingRowAt boardIndex: Int)
    func tableBoard(_ tableBoard: STTableBoard, didAddRowAt boardIndex: Int, with rowTitle: String)

    // move row
    func tableBoard(_ tableBoard: STTableBoard, canMoveRowAt indexPath: STIndexPath) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, shouldMoveRowAt sourceIndexPath: STIndexPath, to destinationIndexPath: STIndexPath) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, moveRowAt sourceIndexPath: STIndexPath, to destinationIndexPath: inout STIndexPath)
    func tableBoard(_ tableBoard: STTableBoard, didEndMoveRowAt originIndexPath: STIndexPath, to destinationIndexPath: STIndexPath)
    
    // move board
    func tableBoard(_ tableBoard: STTableBoard, canMoveBoardAt boardIndex: Int) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, shouldMoveBoardAt sourceIndex: Int, to destinationIndex: Int) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, moveBoardAt sourceIndex: Int, to destinationIndex: Int)
    func tableBoard(_ tableBoard: STTableBoard, didEndMoveBoardAt originIndex: Int, to destinationIndex: Int)

    // scale table board
    func tableBoard(_ tableBoard: STTableBoard, scaleTableBoard isScaled: Bool)

    // footer refresh handle
    func tableBoard(_ tableBoard: STTableBoard, showRefreshFooterAt boardIndex: Int) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, footerRefreshingAt boardIndex: Int)
}

public extension STTableBoardDataSource {
    func tableBoard(_ tableBoard: STTableBoard, titleForBoardAt boardIndex: Int) -> String? {
        return nil
    }

    func tableBoard(_ tableBoard: STTableBoard, numberForBoardAt boardIndex: Int) -> Int {
        return 0
    }
    
    // Add row
    func tableBoard(_ tableBoard: STTableBoard, willBeginAddingRowAt boardIndex: Int) {
        return
    }

    // move row
    func tableBoard(_ tableBoard: STTableBoard, canMoveRowAt indexPath: STIndexPath) -> Bool {
        return true
    }
    
    func tableBoard(_ tableBoard: STTableBoard, shouldMoveRowAt sourceIndexPath: STIndexPath, to destinationIndexPath: STIndexPath) -> Bool {
        return true
    }
    
    // move board
    func tableBoard(_ tableBoard: STTableBoard, canMoveBoardAt boardIndex: Int) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldMoveBoardAt sourceIndex: Int, to destinationIndex: Int) -> Bool {
        return true
    }

    // scale table board
    func tableBoard(_ tableBoard: STTableBoard, scaleTableBoard isScaled: Bool) {
        return
    }

    // footer refresh handle
    func tableBoard(_ tableBoard: STTableBoard, showRefreshFooterAt boardIndex: Int) -> Bool {
        return false
    }

    func tableBoard(_ tableBoard: STTableBoard, footerRefreshingAt boardIndex: Int) {
        return
    }
}
