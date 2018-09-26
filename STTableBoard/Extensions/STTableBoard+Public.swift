//
//  STTableBoard+Public.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/10.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

// MARK: - Public methods
// swiftlint:disable identifier_name
public extension STTableBoard {
    public func reloadData(_ resetPage: Bool = true, resetMode: Bool = false) {
        resetContentSize()

        if boards.count != 0 {
            boards.forEach { $0.removeFromSuperview() }
            boards.removeAll(keepingCapacity: true)
        }
        newBoardButtonView.removeFromSuperview()

        for index in 0..<numberOfPage - (showAddBoardButton ? 1 : 0) {
            insertBoardAtIndex(index, animation: false)
        }

        if resetPage {
            currentPage = 0
        }
        if isAddBoardTextComposeViewVisible {
            hiddenTextComposeView()
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

    public func reloadBoard(at index: Int, animated: Bool) {
        guard index < boards.count else {
            fatalError("index is not exist!!")
        }
        let board = boards[index]
        board.tableView.reloadData()
        autoAdjustTableBoardHeight(board, animated: animated)
    }

    public func reloadBoardTitle(at index: Int) {
        guard index < boards.count else {
            fatalError("index is not exist!!")
        }
        let board = boards[index]
        board.title = dataSource?.tableBoard(self, titleForBoardAt: index)
    }

    public func reloadBoardNumber(at index: Int) {
        guard index < boards.count else {
            fatalError("index is not exist!!")
        }
        let board = boards[index]
        board.number = dataSource?.tableBoard(self, numberForBoardAt: index) ?? 0
    }

    public func reloadBoardActionButton(at index: Int) {
        guard index < boards.count else {
            fatalError("index is not exist!!")
        }
        let board = boards[index]
        board.shouldShowActionButton = dataSource?.tableBoard(self, shouldShowActionButtonAt: index) ?? true
    }

    public func removeBoard(at index: Int) {
        guard index < boards.count else {
            fatalError("index is not exist!!")
        }
        let board = boards[index]
        if let boardViewForVisibleTextComposeView = boardViewForVisibleTextComposeView, boardViewForVisibleTextComposeView.index == index {
            boardViewForVisibleTextComposeView.hideTextComposeView()
        }
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            board.alpha = 0.0
            }, completion: { [weak self](_) -> Void in
                if let weakSelf = self {
                    board.removeFromSuperview()
                    weakSelf.boards.remove(at: index)
                    weakSelf.reloadData(false)
                }
        })
        pageControl.numberOfPages = numberOfPage
    }

    public func insertBoard(at index: Int, animated: Bool) {
        insertBoardAtIndex(index, animation: animated)
    }

    public func exchangeBoard(originIndex: Int, destinationIndex: Int, animated: Bool) {
        guard originIndex != destinationIndex && originIndex < boards.count && destinationIndex < boards.count else {
            return
        }
        let x1 = leading + CGFloat(originIndex) * (boardWidth + pageSpacing)
        let x2 = leading + CGFloat(destinationIndex) * (boardWidth + pageSpacing)
        let originBoard = boards[originIndex]
        let destinationBoard = boards[destinationIndex]
        if animated {
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
}

public extension STTableBoard {
    public func insertRows(at indexPaths: [STIndexPath], with animation: UITableView.RowAnimation) {
        var indexPathsDic = [String: [STIndexPath]]()
        indexPaths.forEach { (indexPath) -> Void in
            if var indexPathsInBoard = indexPathsDic[String(indexPath.board)] {
                indexPathsInBoard.append(indexPath)
                indexPathsDic[String(indexPath.board)] = indexPathsInBoard
            } else {
                indexPathsDic[String(indexPath.board)] = [indexPath]
            }
        }

        indexPathsDic.forEach { (keyAndValue) -> Void in
            let boardIndex = keyAndValue.0
            let indexPaths: [IndexPath] = keyAndValue.1.map({ (indexPath) -> IndexPath in
                return indexPath.toIndexPath()
            })
            let board = self.boards[Int(boardIndex)!]
            guard let tableView = board.tableView else {
                return
            }
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: animation)
            tableView.endUpdates()
            self.autoAdjustTableBoardHeight(board, animated: true)
        }
    }

    public func insertSections(_ sections: IndexSet, atBoard boardIndex: Int, with animation: UITableView.RowAnimation) {
        let board = boards[boardIndex]
        guard let tableView = board.tableView else {
            return
        }
        let showLoadingView = board.tableView.refreshFooter?.isShowLoadingView ?? false
        if showLoadingView {
            board.tableView.refreshFooter?.isShowLoadingView = false
        }
        tableView.beginUpdates()
        tableView.insertSections(sections, with: animation)
        tableView.endUpdates()
        autoAdjustTableBoardHeight(board, animated: true)
        if showLoadingView {
            board.tableView.refreshFooter?.isShowLoadingView = true
            board.tableView.refreshFooter?.endRefreshing()
        }
    }

    public func deleteRows(at indexPaths: [STIndexPath], with animation: UITableView.RowAnimation) {
        var indexPathsDic = [String: [STIndexPath]]()
        indexPaths.forEach { (indexPath) -> Void in
            if var indexPathsInBoard = indexPathsDic[String(indexPath.board)] {
                indexPathsInBoard.append(indexPath)
                indexPathsDic[String(indexPath.board)] = indexPathsInBoard
            } else {
                indexPathsDic[String(indexPath.board)] = [indexPath]
            }
        }

        indexPathsDic.forEach { (keyAndValue) -> Void in
            let boardIndex = keyAndValue.0
            let indexPaths: [IndexPath] = keyAndValue.1.map({ (indexPath) -> IndexPath in
                return indexPath.toIndexPath()
            })
            let board = self.boards[Int(boardIndex)!]
            guard let tableView = board.tableView else {
                return
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: indexPaths, with: animation)
            tableView.endUpdates()
            self.autoAdjustTableBoardHeight(board, animated: true)
        }
    }

    public func deleteSections(_ sections: IndexSet, atBoard boardIndex: Int, with animation: UITableView.RowAnimation) {
        let board = boards[boardIndex]
        guard let tableView = board.tableView else {
            return
        }
        tableView.beginUpdates()
        tableView.deleteSections(sections, with: animation)
        tableView.endUpdates()
        autoAdjustTableBoardHeight(board, animated: true)
    }

    public func moveRowWithinBoard(at indexPath: STIndexPath, to newIndexPath: STIndexPath, reloadAfterMoving: Bool = false, with animation: UITableView.RowAnimation = .none) {
        guard indexPath.board == newIndexPath.board else {
            return
        }
        let boardIndex = indexPath.board
        let board = self.boards[Int(boardIndex)]
        guard let tableView = board.tableView else {
            return
        }
        tableView.beginUpdates()
        tableView.moveRow(at: indexPath.toIndexPath(), to: newIndexPath.toIndexPath())
        tableView.endUpdates()
        if reloadAfterMoving {
            tableView.beginUpdates()
            tableView.reloadRows(at: [newIndexPath.toIndexPath()], with: animation)
            tableView.endUpdates()
        }
        self.autoAdjustTableBoardHeight(board, animated: true)
    }

    public func insertRow(at indexPath: STIndexPath, withRowAnimation animation: UITableView.RowAnimation, atScrollPosition scrollPosition: UITableView.ScrollPosition) {
        let board = boards[indexPath.board]
        guard let tableView = board.tableView else {
            return
        }
        let showLoadingView = board.tableView.refreshFooter?.isShowLoadingView ?? false
        if showLoadingView {
            board.tableView.refreshFooter?.isShowLoadingView = false
        }
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath.toIndexPath()], with: animation)
        tableView.endUpdates()
        autoAdjustTableBoardHeight(board, animated: true)
        tableView.scrollToRow(at: indexPath.toIndexPath(), at: scrollPosition, animated: true)
        if showLoadingView {
            board.tableView.refreshFooter?.isShowLoadingView = true
            board.tableView.refreshFooter?.endRefreshing()
        }
    }

    public func reloadRows(at indexPaths: [STIndexPath], with animation: UITableView.RowAnimation) {
        var indexPathsDic = [String: [STIndexPath]]()
        indexPaths.forEach { (indexPath) -> Void in
            if var indexPathsInBoard = indexPathsDic[String(indexPath.board)] {
                indexPathsInBoard.append(indexPath)
                indexPathsDic[String(indexPath.board)] = indexPathsInBoard
            } else {
                indexPathsDic[String(indexPath.board)] = [indexPath]
            }
        }

        indexPathsDic.forEach { (keyAndValue) -> Void in
            let boardIndex = keyAndValue.0
            let indexPaths: [IndexPath] = keyAndValue.1.map({ (indexPath) -> IndexPath in
                return indexPath.toIndexPath()
            })
            let board = self.boards[Int(boardIndex)!]
            guard let tableView = board.tableView else {
                return
            }
            tableView.beginUpdates()
            tableView.reloadRows(at: indexPaths, with: animation)
            tableView.endUpdates()
            self.autoAdjustTableBoardHeight(board, animated: true)
        }
    }

    public func reloadSections(_ sections: IndexSet, atBoard boardIndex: Int, with animation: UITableView.RowAnimation) {
        let board = boards[boardIndex]
        guard let tableView = board.tableView else {
            return
        }
        tableView.beginUpdates()
        tableView.reloadSections(sections, with: animation)
        tableView.endUpdates()
        autoAdjustTableBoardHeight(board, animated: true)
    }

    public func cellForRow(at indexPath: STIndexPath) -> STBoardCell? {
        let board = boards[indexPath.board]
        guard let tableView = board.tableView else {
            return nil
        }
        return tableView.cellForRow(at: indexPath.toIndexPath()) as? STBoardCell
    }

    public func scrollToRow(at indexPath: STIndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        let board = boards[indexPath.board]
        guard let tableView = board.tableView else {
            return
        }
        let showLoadingView = board.tableView.refreshFooter?.isShowLoadingView ?? false
        if showLoadingView {
            board.tableView.refreshFooter?.isShowLoadingView = false
        }
        tableView.scrollToRow(at: indexPath.toIndexPath(), at: scrollPosition, animated: animated)
        if showLoadingView {
            board.tableView.refreshFooter?.isShowLoadingView = true
            board.tableView.refreshFooter?.endRefreshing()
        }
    }
}

public extension STTableBoard {
    func isEmpty(_ board: Int) -> Bool {
        return boards[board].tableView.height == 0
    }

    func endRefreshing(_ board: Int) {
        guard board < boards.count else {
            return
        }
        let boardView = boards[board]
        boardView.tableView.refreshFooter?.endRefreshing()
    }

    func showRefreshFooter(_ board: Int, showRefreshFooter: Bool) {
        guard board < boards.count else {
            return
        }
        let boardView = boards[board]
        boardView.tableView.refreshFooter?.isShowLoadingView = showRefreshFooter
    }

    func stopMovingCell() {
        guard let recognizer = currentLongPressGestureForCell else {
            return
        }
        recognizer.isEnabled = false
    }

    func stopMovingBoard() {
        guard let recognizer = currentLongPressGestureForBoard else {
            return
        }
        recognizer.isEnabled = false
    }

    func boardFooterRect(at boardIndex: Int) -> CGRect {
        guard 0..<boards.count ~= boardIndex else {
            return .zero
        }
        let board = boards[boardIndex]
        guard let boardFooter = board.footerView else {
            return .zero
        }
        board.layoutIfNeeded()
        return view.convert(boardFooter.frame, from: board)
    }

    func toggleBoardFooter(at boardIndex: Int) {
        guard 0..<boards.count ~= boardIndex else {
            return
        }
        let board = boards[boardIndex]
        guard let boardFooter = board.footerView else {
            return
        }
        boardFooter.addButtonTapped(nil)
    }
}
