//
//  ViewController+STTableBoard.swift
//  STTableBoardDemo
//
//  Created by DangGu on 16/12/13.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit
import STTableBoard

// MARK: - STTableBoardDelegate
extension ViewController: STTableBoardDelegate {
    func tableBoard(_ tableBoard: STTableBoard, didTapMoreButtonAt index: Int, stageTitle: String?, button: UIButton) {
        print("More button tapped")
    }

    func tableBoard(_ tableBoard: STTableBoard, heightForRowAt indexPath: STIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableBoard(_ tableBoard: STTableBoard, willRemoveBoardAt index: Int) -> Bool {
        guard index != 0 else { return false }
        dataArray.remove(at: index)
        titleArray.remove(at: index)
        return true
    }
    
    func tableBoard(_ tableBoard: STTableBoard, willAddNewBoardAt index: Int, with boardTitle: String) {
        dataArray.append([])
        titleArray.append(boardTitle)
        tableBoard.insertBoardAtIndex(index, withAnimation: true)
    }

    func customAddRowAction(for tableBoard: STTableBoard, at boardIndex: Int) -> (() -> Void)? {
        if boardIndex == 0 || boardIndex == 3 {
            return {
                let alert = UIAlertController(title: "Custom Add Row Action", message: "boardIndex: \(boardIndex)", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        return nil
    }

    func tableBoard(_ tableBoard: STTableBoard, didSelectRowAt indexPath: STIndexPath) {
        print("board \(indexPath.board) row \(indexPath.row)")
        if let cell = tableBoard.cellForRowAtIndexPath(indexPath) as? BoardCardCell {
            print("cell's title \(cell.titleText)")
        }
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.white
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableBoard(_ tableBoard: STTableBoard, canEditBoardTitleAt boardIndex: Int) -> Bool {
        return true
    }
    
    func tableBoard(_ tableBoard: STTableBoard, boardTitleBeChangedTo title: String, at boardIndex: Int) {
        titleArray[boardIndex] = title
    }
    
    func tableBoard(_ tableBoard: STTableBoard, handlePinchGesture recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            guard let _ = navigationController, !isAnimatingForFullScreen else {
                break
            }
            animateTopBar(with: recognizer.velocity)
        default:
            break
        }
    }
}

// MARK: - STTableBoardDataSource
extension ViewController: STTableBoardDataSource {
    func numberOfBoards(in tableBoard: STTableBoard) -> Int {
        return dataArray.count
    }
    
    func tableBoard(_ tableBoard: STTableBoard, numberOfRowsAt boardIndex: Int) -> Int {
        return dataArray[boardIndex].count
    }
    
    func tableBoard(_ tableBoard: STTableBoard, cellForRowAt indexPath: STIndexPath) -> UITableViewCell {
        let cell = tableBoard.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath) as! BoardCardCell
        cell.titleText = dataArray[indexPath.board][indexPath.row]
        return cell
    }
    
    func tableBoard(_ tableBoard: STTableBoard, titleForBoardAt boardIndex: Int) -> String? {
        return titleArray[boardIndex]
    }
    
    func tableBoard(_ tableBoard: STTableBoard, numberForBoardAt boardIndex: Int) -> Int {
        return dataArray[boardIndex].count
    }
    
    func tableBoard(_ tableBoard: STTableBoard, didAddRowAt boardIndex: Int, with rowTitle: String) {
        let indexPath = STIndexPath(forRow: dataArray[boardIndex].count, inBoard: boardIndex)
        dataArray[boardIndex].append(rowTitle)
        tableBoard.insertRowAtIndexPath(indexPath, withRowAnimation: .fade, atScrollPosition: .bottom)
    }

    func tableBoard(_ tableBoard: STTableBoard, didCancelAddRowAt boardIndex: Int) {
        print("didCancelAddRowAt \(boardIndex)")
    }
    
    // move row
    func tableBoard(_ tableBoard: STTableBoard, canMoveRowAt indexPath: STIndexPath) -> Bool {
        if indexPath.board == 0 && indexPath.row == 2 {
            return false
        }
        return true
    }
    
    func tableBoard(_ tableBoard: STTableBoard, shouldMoveRowAt sourceIndexPath: STIndexPath, to destinationIndexPath: STIndexPath) -> Bool {
        if destinationIndexPath.board == 1 && destinationIndexPath.row == 1 {
            return false
        }
        return true
    }
    
    func tableBoard(_ tableBoard: STTableBoard, moveRowAt sourceIndexPath: STIndexPath, to destinationIndexPath: inout STIndexPath) {
        //        destinationIndexPath = STIndexPath(forRow: 0, inBoard: destinationIndexPath.board)
        let data = dataArray[sourceIndexPath.board][sourceIndexPath.row]
        dataArray[sourceIndexPath.board].remove(at: sourceIndexPath.row)
        dataArray[destinationIndexPath.board].insert(data, at: destinationIndexPath.row)
    }
    
    func tableBoard(_ tableBoard: STTableBoard, didEndMoveRowAt originIndexPath: STIndexPath, to destinationIndexPath: STIndexPath) {
        print("originIndexPath \(originIndexPath), destinationIndexPath \(destinationIndexPath)")
    }
    
    // move board
    func tableBoard(_ tableBoard: STTableBoard, canMoveBoardAt boardIndex: Int) -> Bool {
        return true
    }
    
    func tableBoard(_ tableBoard: STTableBoard, shouldMoveBoardAt sourceIndex: Int, to destinationIndex: Int) -> Bool {
        if destinationIndex == dataArray.count - 1 {
            return false
        }
        return true
    }
    
    func tableBoard(_ tableBoard: STTableBoard, moveBoardAt sourceIndex: Int, to destinationIndex: Int) {
        let sourceData = dataArray[sourceIndex]
        let destinationData = dataArray[destinationIndex]
        dataArray[sourceIndex] = destinationData
        dataArray[destinationIndex] = sourceData
    }
    
    func tableBoard(_ tableBoard: STTableBoard, didEndMoveBoardAt originIndex: Int, to destinationIndex: Int) {
        print("originIndex \(originIndex), destinationIndex \(destinationIndex)")
    }
    
    // scale table board
    func tableBoard(_ tableBoard: STTableBoard, scaleTableBoard isScaled: Bool) {
        print("isScaled : \(isScaled)")
    }
    
    // footer refresh handle
    func tableBoard(_ tableBoard: STTableBoard, showRefreshFooterAt boardIndex: Int) -> Bool {
        //        if boardIndex == dataArray.count - 1 {
        //            return true
        //        }
        //        return false
        return true
    }
    
    func tableBoard(_ tableBoard: STTableBoard, footerRefreshingAt boardIndex: Int) {
        //        tableBoard.endRefreshing(boardIndex)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            tableBoard.endRefreshing(boardIndex)
            tableBoard.showRefreshFooter(boardIndex, showRefreshFooter: false)
        });
        print("1")
    }
}
