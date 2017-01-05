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
    public func reloadData(_ resetPage: Bool = true, resetMode: Bool = false) {
        resetContentSize()
        
        if boards.count != 0 {
            boards.forEach({ (board) -> () in
                board.removeFromSuperview()
            })
            boards.removeAll(keepingCapacity: true)
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
        boardViewForVisibleTextComposeView = nil
        isAddBoardTextComposeViewVisible = false

        if showAddBoardButton {
            let newBoardButtonViewFrame = CGRect(x: leading + CGFloat(numberOfPage - 1) * (boardWidth + pageSpacing), y: top, width: boardWidth, height: newBoardButtonViewHeight)
            newBoardButtonView.frame = newBoardButtonViewFrame
            textComposeView.frame = newBoardButtonViewFrame
            containerView.addSubview(newBoardButtonView)
            containerView.addSubview(textComposeView)
        }

        if resetMode && currentDevice == .phone && tableBoardMode == .scroll && currentOrientation == .portrait {
            switchMode()
        }
    }

    
    func reloadBoardAtIndex(_ index: Int, animated: Bool) {
        guard index < boards.count else { fatalError("index is not exist!!") }
        let board = boards[index]
        board.tableView.reloadData()
        autoAdjustTableBoardHeight(board, animated: animated)
    }
    
    func reloadBoardTitleAtIndex(_ index: Int) {
        guard index < boards.count else { fatalError("index is not exist!!") }
        let board = boards[index]
        board.title = dataSource?.tableBoard(self, titleForBoardAt: index)
    }

    func reloadBoardNumberAtIndex(_ index: Int) {
        guard index < boards.count else { fatalError("index is not exist!!") }
        let board = boards[index]
        board.number = dataSource?.tableBoard(self, numberForBoardAt: index) ?? 0
    }
    
    func removeBoardAtIndex(_ index: Int) {
        guard index < boards.count else { fatalError("index is not exist!!") }
        let board = boards[index]
        if let boardViewForVisibleTextComposeView = boardViewForVisibleTextComposeView, boardViewForVisibleTextComposeView.index == index {
            boardViewForVisibleTextComposeView.hideTextComposeView()
        }
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            board.alpha = 0.0
            }, completion: { [weak self](finished) -> Void in
                if let weakSelf = self {
                    board.removeFromSuperview()
                    weakSelf.boards.remove(at: index)
                    weakSelf.reloadData(false)
                }
        }) 
        pageControl.numberOfPages = numberOfPage
    }

    
    func insertBoardAtIndex(_ index: Int, withAnimation animation: Bool) {
        insertBoardAtIndex(index, animation: animation)
    }
    
    func exchangeBoardAtIndex(_ originIndex: Int, destinationIndex: Int, animation: Bool) {
        guard originIndex != destinationIndex && originIndex < boards.count && destinationIndex < boards.count else { return }
        let x1 = leading + CGFloat(originIndex) * (boardWidth + pageSpacing)
        let x2 = leading + CGFloat(destinationIndex) * (boardWidth + pageSpacing)
        let originBoard = boards[originIndex]
        let destinationBoard = boards[destinationIndex]
        if animation {
            UIView.animate(withDuration: 0.5, animations: {
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
    
    func insertRowsAtIndexPaths(_ indexPaths: [STIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
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
            let indexPaths: [IndexPath] = keyAndValue.1.map({ (indexPath) -> IndexPath in
                return indexPath.ConvertToIndexPath()
            })
            let board = self.boards[Int(boardIndex)!]
            guard let tableView = board.tableView else { return }
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: animation)
            tableView.endUpdates()
            self.autoAdjustTableBoardHeight(board, animated: true)
        }
    }

    func deleteRowsAtIndexPaths(_ indexPaths: [STIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
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
            let indexPaths: [IndexPath] = keyAndValue.1.map({ (indexPath) -> IndexPath in
                return indexPath.ConvertToIndexPath()
            })
            let board = self.boards[Int(boardIndex)!]
            guard let tableView = board.tableView else { return }
            
            var deleteIndexPaths = [IndexPath]()
            for indexPath in indexPaths {
                if let _ = tableView.cellForRow(at: indexPath) {
                    deleteIndexPaths.append(indexPath)
                }
            }

            tableView.beginUpdates()
            tableView.deleteRows(at: deleteIndexPaths, with: animation)
            tableView.endUpdates()
            self.autoAdjustTableBoardHeight(board, animated: true)
        }
    }
    
    func insertRowAtIndexPath(_ indexPath: STIndexPath, withRowAnimation animation: UITableViewRowAnimation, atScrollPosition scrollPosition: UITableViewScrollPosition) {
        let board = boards[indexPath.board]
        let showLoadingView = board.tableView.refreshFooter?.isShowLoadingView ?? false
        if showLoadingView {
            board.tableView.refreshFooter?.isShowLoadingView = false
        }
        guard let tableView = board.tableView else { return }
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath.ConvertToIndexPath()], with: animation)
        tableView.endUpdates()
        autoAdjustTableBoardHeight(board, animated: true)
        tableView.scrollToRow(at: indexPath.ConvertToIndexPath(), at: scrollPosition, animated: true)
        if showLoadingView {
            board.tableView.refreshFooter?.isShowLoadingView = true
            board.tableView.refreshFooter?.endRefreshing()
        }
    }

    func reloadRowAtIndexPath(_ indexPaths: [STIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
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
            let indexPaths: [IndexPath] = keyAndValue.1.map({ (indexPath) -> IndexPath in
                return indexPath.ConvertToIndexPath()
            })
            let board = self.boards[Int(boardIndex)!]
            guard let tableView = board.tableView else { return }
            tableView.beginUpdates()
            tableView.reloadRows(at: indexPaths, with: animation)
            tableView.endUpdates()
            self.autoAdjustTableBoardHeight(board, animated: true)
        }
    }
    
    func cellForRowAtIndexPath(_ indexPath: STIndexPath) -> STBoardCell? {
        let board = boards[indexPath.board]
        guard let tableView = board.tableView else { return nil }
        return tableView.cellForRow(at: indexPath.ConvertToIndexPath()) as? STBoardCell
    }

    func isEmpty(_ board: Int) -> Bool {
        return boards[board].tableView.height == 0
    }

    func endRefreshing(_ board: Int) {
        guard board < boards.count else { return }
        let boardView = boards[board]
        boardView.tableView.refreshFooter?.endRefreshing()
    }

    func showRefreshFooter(_ board: Int, showRefreshFooter: Bool) {
        guard board < boards.count else { return }
        let boardView = boards[board]
        boardView.tableView.refreshFooter?.isShowLoadingView = showRefreshFooter
    }

    func stopMovingCell() {
        guard let recognizer = currentLongPressGestureForCell else { return }
        recognizer.isEnabled = false
    }

    func stopMovingBoard() {
        guard let recognizer = currentLongPressGestureForBoard else { return }
        recognizer.isEnabled = false
    }
}
