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
    func tableBoard(_ tableBoard: STTableBoard, viewForHeaderInSection section: Int, atBoard boardIndex: Int) -> UIView?
    func tableBoard(_ tableBoard: STTableBoard, heightForHeaderInSection section: Int, atBoard boardIndex: Int) -> CGFloat
    func tableBoard(_ tableBoard: STTableBoard, viewForFooterInSection section: Int, atBoard boardIndex: Int) -> UIView?
    func tableBoard(_ tableBoard: STTableBoard, heightForFooterInSection section: Int, atBoard boardIndex: Int) -> CGFloat
    func tableBoard(_ tableBoard: STTableBoard, didSelectRowAt indexPath: STIndexPath)
    func tableBoard(_ tableBoard: STTableBoard, willAddNewBoardAt index: Int, with boardTitle: String)
    func tableBoard(_ tableBoard: STTableBoard, willRemoveBoardAt index: Int) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, canEditBoardTitleAt boardIndex: Int) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, boardTitleDidChangeTo title: String, at boardIndex: Int)
    func tableBoard(_ tableBoard: STTableBoard, handlePinchGesture recognizer: UIPinchGestureRecognizer)
    func dropMode(for tableBoard: STTableBoard, whenMovingRowAt indexPath: STIndexPath) -> STTableBoardDropMode

    func tableBoard(_ tableBoard: STTableBoard, didTapMoreButtonAt index: Int, boardTitle: String?, button: UIButton)
}

public extension STTableBoardDelegate {
    func tableBoard(_ tableBoard: STTableBoard, heightForRowAt indexPath: STIndexPath) -> CGFloat {
        return 44.0
    }

    func tableBoard(_ tableBoard: STTableBoard, viewForHeaderInSection section: Int, atBoard boardIndex: Int) -> UIView? {
        return nil
    }

    func tableBoard(_ tableBoard: STTableBoard, heightForHeaderInSection section: Int, atBoard boardIndex: Int) -> CGFloat {
        return 0
    }

    func tableBoard(_ tableBoard: STTableBoard, viewForFooterInSection section: Int, atBoard boardIndex: Int) -> UIView? {
        return nil
    }

    func tableBoard(_ tableBoard: STTableBoard, heightForFooterInSection section: Int, atBoard boardIndex: Int) -> CGFloat {
        return 0
    }

    func tableBoard(_ tableBoard: STTableBoard, didSelectRowAt indexPath: STIndexPath) {

    }

    func tableBoard(_ tableBoard: STTableBoard, canEditBoardTitleAt boardIndex: Int) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, boardTitleDidChangeTo title: String, at boardIndex: Int) {

    }

    func tableBoard(_ tableBoard: STTableBoard, handlePinchGesture recognizer: UIPinchGestureRecognizer) {

    }

    func dropMode(for tableBoard: STTableBoard, whenMovingRowAt indexPath: STIndexPath) -> STTableBoardDropMode {
        return .row
    }
}

public protocol STTableBoardDataSource: class {
    func numberOfBoards(in tableBoard: STTableBoard) -> Int
    func tableBoard(_ tableBoard: STTableBoard, numberOfSectionsAt boardIndex: Int) -> Int
    func tableBoard(_ tableBoard: STTableBoard, numberOfRowsInSection section: Int, atBoard boardIndex: Int) -> Int
    func tableBoard(_ tableBoard: STTableBoard, cellForRowAt indexPath: STIndexPath) -> UITableViewCell
    func tableBoard(_ tableBoard: STTableBoard, titleForBoardAt boardIndex: Int) -> String?
    func tableBoard(_ tableBoard: STTableBoard, numberForBoardAt boardIndex: Int) -> Int

    // add row
    func tableBoard(_ tableBoard: STTableBoard, willBeginAddingRowAt boardIndex: Int)
    func tableBoard(_ tableBoard: STTableBoard, didAddRowAt boardIndex: Int, with rowTitle: String)
    func tableBoard(_ tableBoard: STTableBoard, didCancelAddRowAt boardIndex: Int)
    func tableBoard(_ tableBoard: STTableBoard, shouldShowActionButtonAt boardIndex: Int) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, shouldEnableAddRowAt boardIndex: Int) -> Bool
    func customAddRowAction(for tableBoard: STTableBoard, at boardIndex: Int) -> (() -> Void)?

    // move row
    func tableBoard(_ tableBoard: STTableBoard, canMoveRowAt indexPath: STIndexPath) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, shouldMoveRowAt sourceIndexPath: STIndexPath, originIndexPath: STIndexPath, toDestinationIndexPath destinationIndexPath: STIndexPath) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, shouldMoveRowAt sourceIndexPath: STIndexPath, originIndexPath: STIndexPath, toDestinationBoard boardIndex: Int) -> Bool
    func tableBoard(_ tableBoard: STTableBoard, moveRowAt sourceIndexPath: STIndexPath, toDestinationIndexPath destinationIndexPath: inout STIndexPath)
    func tableBoard(_ tableBoard: STTableBoard, moveRowAt sourceIndexPath: STIndexPath, toDestinationBoard boardIndex: Int)
    func tableBoard(_ tableBoard: STTableBoard, didEndMoveRowAt originIndexPath: STIndexPath, toDestinationIndexPath destinationIndexPath: STIndexPath)
    func tableBoard(_ tableBoard: STTableBoard, didEndMoveRowAt originIndexPath: STIndexPath, toDestinationBoard boardIndex: Int)
    func tableBoard(_ tableBoard: STTableBoard, dropReleaseTextForBoardAt boardIndex: Int) -> String?

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
    func tableBoard(_ tableBoard: STTableBoard, numberOfSectionsAt boardIndex: Int) -> Int {
        return 1
    }

    func tableBoard(_ tableBoard: STTableBoard, titleForBoardAt boardIndex: Int) -> String? {
        return nil
    }

    func tableBoard(_ tableBoard: STTableBoard, numberForBoardAt boardIndex: Int) -> Int {
        return 0
    }

    // Add row
    func tableBoard(_ tableBoard: STTableBoard, willBeginAddingRowAt boardIndex: Int) {

    }

    func tableBoard(_ tableBoard: STTableBoard, didCancelAddRowAt boardIndex: Int) {

    }

    func tableBoard(_ tableBoard: STTableBoard, shouldShowActionButtonAt boardIndex: Int) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldEnableAddRowAt boardIndex: Int) -> Bool {
        return true
    }

    func customAddRowAction(for tableBoard: STTableBoard, at boardIndex: Int) -> (() -> Void)? {
        return nil
    }

    // move row
    func tableBoard(_ tableBoard: STTableBoard, canMoveRowAt indexPath: STIndexPath) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldMoveRowAt sourceIndexPath: STIndexPath, originIndexPath: STIndexPath, toDestinationIndexPath destinationIndexPath: STIndexPath) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldMoveRowAt sourceIndexPath: STIndexPath, originIndexPath: STIndexPath, toDestinationBoard boardIndex: Int) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, moveRowAt sourceIndexPath: STIndexPath, toDestinationIndexPath destinationIndexPath: inout STIndexPath) {

    }

    func tableBoard(_ tableBoard: STTableBoard, moveRowAt sourceIndexPath: STIndexPath, toDestinationBoard boardIndex: Int) {

    }

    func tableBoard(_ tableBoard: STTableBoard, didEndMoveRowAt originIndexPath: STIndexPath, toDestinationIndexPath destinationIndexPath: STIndexPath) {

    }

    func tableBoard(_ tableBoard: STTableBoard, didEndMoveRowAt originIndexPath: STIndexPath, toDestinationBoard boardIndex: Int) {

    }

    func tableBoard(_ tableBoard: STTableBoard, dropReleaseTextForBoardAt boardIndex: Int) -> String? {
        return nil
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

    }

    // footer refresh handle
    func tableBoard(_ tableBoard: STTableBoard, showRefreshFooterAt boardIndex: Int) -> Bool {
        return false
    }

    func tableBoard(_ tableBoard: STTableBoard, footerRefreshingAt boardIndex: Int) {

    }
}
