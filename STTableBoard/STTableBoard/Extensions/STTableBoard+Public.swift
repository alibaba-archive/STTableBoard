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
    public func reloadData() {
        resetContentSize()
        
        if boards.count != 0 {
            boards.forEach({ (board) -> () in
                board.removeFromSuperview()
            })
            boards.removeAll(keepCapacity: true)
        }
        newBoardButtonView.removeFromSuperview()
        
        for i in 0..<numberOfPage - 1 {
            let x = leading + CGFloat(i) * (boardWidth + pageSpacing)
            let y = top
            let boardViewFrame = CGRect(x: x, y: y, width: boardWidth, height: maxBoardHeight)
            
            let boardView: STBoardView = STBoardView(frame: boardViewFrame)
            boardView.headerView.addGestureRecognizer(self.longPressGestureForBoard)
            boardView.tableView.addGestureRecognizer(self.longPressGestureForCell)
            boardView.index = i
            boardView.tableView.delegate = self
            boardView.tableView.dataSource = self
            boardView.delegate = self
            registerCellClasses.forEach({ (classAndIdentifier) -> () in
                boardView.tableView.registerClass(classAndIdentifier.0, forCellReuseIdentifier: classAndIdentifier.1)
            })
            autoAdjustTableBoardHeight(boardView, animated: false)
            boards.append(boardView)
            
            guard let dataSource = dataSource, let boardTitle = dataSource.tableBoard(tableBoard: self, titleForBoardInBoard: i) else { return }
            boardView.title = boardTitle
        }
        
        boards.forEach { (cardView) -> () in
            containerView.addSubview(cardView)
        }
        
        let newBoardButtonViewFrame = CGRect(x: leading + CGFloat(numberOfPage - 1) * (boardWidth + pageSpacing), y: top, width: boardWidth, height: newBoardButtonViewHeight)
        newBoardButtonView.frame = newBoardButtonViewFrame
        newBoardComposeView.frame = newBoardButtonViewFrame
        containerView.addSubview(newBoardButtonView)
        containerView.addSubview(newBoardComposeView)
    }
    
    func reloadBoardAtIndex(index: Int) {
        guard index < boards.count else { fatalError("index is not exist!!") }
        let board = boards[index]
        board.tableView.reloadData()
        autoAdjustTableBoardHeight(board, animated: true)
    }
    
    func reloadBoardTitleAtIndex(index: Int) {
        guard index < boards.count else { fatalError("index is not exist!!") }
        let board = boards[index]
        board.title = dataSource?.tableBoard(tableBoard: self, titleForBoardInBoard: index)
    }
    
    func removeBoardAtIndex(index: Int) {
        hiddenBoardMenu()
        guard index < boards.count else { fatalError("index is not exist!!") }
        guard let delegate = delegate else { return }
        delegate.tableBoard(tableBoard: self, willRemoveBoardAtIndex: index)
        let board = boards[index]
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            board.alpha = 0.0
            }) { [unowned self](finished) -> Void in
                self.boards.removeAtIndex(index)
                self.reloadData()
        }
    }
}