//
//  STTableBoard+Public.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/10.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

//MARK: - public method
public extension STTableBoard {
    public func reloadData(resetPage: Bool = true) {
        resetContentSize()
        
        if boards.count != 0 {
            boards.forEach({ (board) -> () in
                board.removeFromSuperview()
            })
            boards.removeAll(keepCapacity: true)
        }
        newBoardButtonView.removeFromSuperview()
        
        for i in 0..<numberOfPage - (showAddBoardButton ? 1 : 0) {
            insertBoardAtIndex(i, animation: false)
        }

        if resetPage {
            currentPage = 0
        }
        pageControl.currentPage = currentPage
        pageControl.numberOfPages = numberOfPage

        if showAddBoardButton {
            let newBoardButtonViewFrame = CGRect(x: leading + CGFloat(numberOfPage - 1) * (boardWidth + pageSpacing), y: top, width: boardWidth, height: newBoardButtonViewHeight)
            newBoardButtonView.frame = newBoardButtonViewFrame
            textComposeView.frame = newBoardButtonViewFrame
            containerView.addSubview(newBoardButtonView)
            containerView.addSubview(textComposeView)
        }
    }

    
    func reloadBoardAtIndex(index: Int, animated: Bool) {
        guard index < boards.count else { fatalError("index is not exist!!") }
        let board = boards[index]
        board.tableView.reloadData()
        autoAdjustTableBoardHeight(board, animated: animated)
    }
    
    func reloadBoardTitleAtIndex(index: Int) {
        guard index < boards.count else { fatalError("index is not exist!!") }
        let board = boards[index]
        board.title = dataSource?.tableBoard(self, titleForBoardInBoard: index)
    }

    func reloadBoardNumberAtIndex(index: Int) {
        guard index < boards.count else { fatalError("index is not exist!!") }
        let board = boards[index]
        board.number = dataSource?.tableBoard(self, numberForBoardInBoard: index) ?? 0
    }
    
    func removeBoardAtIndex(index: Int) {
        guard index < boards.count else { fatalError("index is not exist!!") }
        let board = boards[index]
        if let boardViewForVisibleTextComposeView = boardViewForVisibleTextComposeView where boardViewForVisibleTextComposeView.index == index {
            boardViewForVisibleTextComposeView.hideTextComposeView()
        }
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            board.alpha = 0.0
            }) { [weak self](finished) -> Void in
                if let weakSelf = self {
                    board.removeFromSuperview()
                    weakSelf.boards.removeAtIndex(index)
                    weakSelf.reloadData(false)
                }
        }
        pageControl.numberOfPages = numberOfPage
    }

    
    func insertBoardAtIndex(index: Int, withAnimation animation: Bool) {
        insertBoardAtIndex(index, animation: animation)
    }
    
    func exchangeBoardAtIndex(originIndex: Int, destinationIndex: Int, animation: Bool) {
        guard originIndex != destinationIndex && originIndex < boards.count && destinationIndex < boards.count else { return }
        let x1 = leading + CGFloat(originIndex) * (boardWidth + pageSpacing)
        let x2 = leading + CGFloat(destinationIndex) * (boardWidth + pageSpacing)
        let originBoard = boards[originIndex]
        let destinationBoard = boards[destinationIndex]
        if animation {
            UIView.animateWithDuration(0.5, animations: {
                originBoard.frame.origin.x = x2
                destinationBoard.frame.origin.x = x1
            })
        } else {
            originBoard.frame.origin.x = x2
            destinationBoard.frame.origin.x = x1
        }
        originBoard.index = destinationIndex
        destinationBoard.index = originIndex
        (boards[originIndex], boards[destinationIndex]) = (boards[destinationIndex], boards[originIndex])
    }
    
    func insertRowsAtIndexPaths(indexPaths: [STIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        var indexPathsDic: [String: [STIndexPath]] = [:]
        indexPaths.forEach { (indexPath) -> () in
            if var indexPathsInBoard = indexPathsDic[String(indexPath.board)] {
                indexPathsInBoard.append(indexPath)
                indexPathsDic[String(indexPath.board)] = indexPathsInBoard
            } else {
                indexPathsDic[String(indexPath.board)] = [indexPath]
            }
        }
        
        indexPathsDic.forEach { (keyAndValue) -> () in
            let boardIndex = keyAndValue.0
            let indexPaths: [NSIndexPath] = keyAndValue.1.map({ (indexPath) -> NSIndexPath in
                return indexPath.convertToNSIndexPath()
            })
            let board = self.boards[Int(boardIndex)!]
            guard let tableView = board.tableView else { return }
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
            tableView.endUpdates()
            self.autoAdjustTableBoardHeight(board, animated: true)
        }
    }

    func deleteRowsAtIndexPaths(indexPaths: [STIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        var indexPathsDic: [String: [STIndexPath]] = [:]
        indexPaths.forEach { (indexPath) -> () in
            if var indexPathsInBoard = indexPathsDic[String(indexPath.board)] {
                indexPathsInBoard.append(indexPath)
                indexPathsDic[String(indexPath.board)] = indexPathsInBoard
            } else {
                indexPathsDic[String(indexPath.board)] = [indexPath]
            }
        }
        
        indexPathsDic.forEach { (keyAndValue) -> () in
            let boardIndex = keyAndValue.0
            let indexPaths: [NSIndexPath] = keyAndValue.1.map({ (indexPath) -> NSIndexPath in
                return indexPath.convertToNSIndexPath()
            })
            let board = self.boards[Int(boardIndex)!]
            guard let tableView = board.tableView else { return }
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
            tableView.endUpdates()
            self.autoAdjustTableBoardHeight(board, animated: true)
        }
    }
    
    func insertRowAtIndexPath(indexPath: STIndexPath, withRowAnimation animation: UITableViewRowAnimation, atScrollPosition scrollPosition: UITableViewScrollPosition) {
        let board = boards[indexPath.board]
        let showLoadingView = board.tableView.refreshFooter?.showLoadingView ?? false
        if showLoadingView {
            board.tableView.refreshFooter?.showLoadingView = false
        }
        guard let tableView = board.tableView else { return }
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPath.convertToNSIndexPath()], withRowAnimation: animation)
        tableView.endUpdates()
        autoAdjustTableBoardHeight(board, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath.convertToNSIndexPath(), atScrollPosition: scrollPosition, animated: true)
        if showLoadingView {
            board.tableView.refreshFooter?.showLoadingView = true
            board.tableView.refreshFooter?.endRefreshing()
        }
    }

    func reloadRowAtIndexPath(indexPaths: [STIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        var indexPathsDic: [String: [STIndexPath]] = [:]
        indexPaths.forEach { (indexPath) -> () in
            if var indexPathsInBoard = indexPathsDic[String(indexPath.board)] {
                indexPathsInBoard.append(indexPath)
                indexPathsDic[String(indexPath.board)] = indexPathsInBoard
            } else {
                indexPathsDic[String(indexPath.board)] = [indexPath]
            }
        }
        
        indexPathsDic.forEach { (keyAndValue) -> () in
            let boardIndex = keyAndValue.0
            let indexPaths: [NSIndexPath] = keyAndValue.1.map({ (indexPath) -> NSIndexPath in
                return indexPath.convertToNSIndexPath()
            })
            let board = self.boards[Int(boardIndex)!]
            guard let tableView = board.tableView else { return }
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
            tableView.endUpdates()
            self.autoAdjustTableBoardHeight(board, animated: true)
        }
    }
    
    func cellForRowAtIndexPath(indexPath: STIndexPath) -> STBoardCell? {
        let board = boards[indexPath.board]
        guard let tableView = board.tableView else { return nil }
        return tableView.cellForRowAtIndexPath(indexPath.convertToNSIndexPath()) as? STBoardCell
    }

    func isEmpty(board: Int) -> Bool {
        return boards[board].tableView.height == 0
    }

    func endRefreshing(board: Int) {
        guard board < boards.count else { return }
        let boardView = boards[board]
        boardView.tableView.refreshFooter?.endRefreshing()
    }

    func showRefreshFooter(board: Int, showRefreshFooter: Bool) {
        guard board < boards.count else { return }
        let boardView = boards[board]
        boardView.tableView.refreshFooter?.showLoadingView = showRefreshFooter
    }

    func stopMovingCell() {
        guard let recognizer = currentLongPressGestureForCell else { return }
        recognizer.enabled = false
    }

    func stopMovingBoard() {
        guard let recognizer = currentLongPressGestureForBoard else { return }
        recognizer.enabled = false
    }
}
