//
//  STTableBoard+Implement.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/10.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

//MARK: - UIGestureRecognizerDelegate
extension STTableBoard: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return false }
        if touchedView == containerView {
            return true
        } else {
            return false
        }
    }
}

//MARK: - UIScrollViewDelegate
extension STTableBoard: UIScrollViewDelegate {
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard tableBoardMode == .Page && scrollView == self.scrollView else { return }
        if !decelerate {
            scrollToActualPage(scrollView, offsetX: scrollView.contentOffset.x)
        }
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard tableBoardMode == .Page && scrollView == self.scrollView else { return }
        if velocity.x != 0 {
            if velocity.x < 0 && currentPage > 0{
                scrollToPage(scrollView, page: currentPage - 1, targetContentOffset: targetContentOffset)
            } else if velocity.x > 0 && currentPage < numberOfPage - 1{
                scrollToPage(scrollView, page: currentPage + 1, targetContentOffset: targetContentOffset)
            }
        }
    }
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    public func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        switch tableBoardMode {
        case .Scroll:
            originContentOffset = scrollView.contentOffset
            originContentSize = scrollView.contentSize
        case .Page:
            scaledContentOffset = scrollView.contentOffset
        }
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        switch tableBoardMode {
        case .Scroll:
            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: view.height)
            if scrollView.contentSize.width < originContentOffset.x * currentScale + scrollView.width {
                scrollView.contentOffset = CGPoint(x: scrollView.contentSize.width - scrollView.width, y: 0)
            } else {
                scrollView.contentOffset = CGPoint(x: originContentOffset.x * currentScale, y: 0)
            }
        case .Page:
            scrollView.contentSize = originContentSize
            scrollView.contentOffset = CGPoint(x: scaledContentOffset.x / scaleForScroll, y: 0)
            if !isMoveBoardFromPageMode {
                scrollToPage(scrollView, page: pageAtPoint(tapPosition) - 1, targetContentOffset: nil)
            }
        }
        containerView.frame = CGRect(origin: CGPointZero, size: scrollView.contentSize)
        boards.forEach { (board) -> () in
            autoAdjustTableBoardHeight(board, animated: true)
        }
    }
}

//MARK: - UITableViewDelegate
extension STTableBoard: UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let board = (tableView as! STShadowTableView).index,
            heightForRow = delegate?.tableBoard(tableBoard: self, heightForRowAtIndexPath: STIndexPath(forRow: indexPath.row, inBoard: board)) else { return 44.0 }
        return heightForRow
    }
}

//MARK: - UITableViewDataSource
extension STTableBoard: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let board = (tableView as! STShadowTableView).index,
            numberOfRows = dataSource?.tableBoard(tableBoard: self, numberOfRowsInBoard: board) else { return 0 }
        return numberOfRows
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let board = (tableView as! STShadowTableView).index,
            cell = dataSource?.tableBoard(tableBoard: self, cellForRowAtIndexPath: STIndexPath(forRow: indexPath.row, inBoard: board)) as? STBoardCell else { fatalError("board or cell can not be nill") }
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.moving = false
        return cell
    }
}

//MARK: - NewBoardButtonDelegate
extension STTableBoard: NewBoardButtonDelegate {
    func newBoardButtonDidBeClicked(newBoardButton button: NewBoardButton) {
        showTextComposeView()
    }
}

//MARK: - TextComposeViewDelegate
extension STTableBoard: TextComposeViewDelegate {
    func textComposeView(textComposeView view: TextComposeView, didClickDoneButton button: UIButton, withText text: String) {
        hiddenTextComposeView()
        guard let delegate = delegate, dataSource = dataSource else { return }
        delegate.tableBoard(tableBoard: self, willAddNewBoardAtIndex: numberOfPage - 1, withBoardTitle: text)
        resetContentSize()
        
        let index = numberOfPage - 2
        let x = leading + CGFloat(index) * (boardWidth + pageSpacing)
        let y = top
        let boardViewFrame = CGRect(x: x, y: y, width: boardWidth, height: maxBoardHeight)
        
        let boardView: STBoardView = STBoardView(frame: boardViewFrame)
        boardView.headerView.addGestureRecognizer(self.longPressGestureForBoard)
        boardView.tableView.addGestureRecognizer(self.longPressGestureForCell)
        boardView.index = index
        boardView.tableView.delegate = self
        boardView.tableView.dataSource = self
        registerCellClasses.forEach({ (classAndIdentifier) -> () in
            boardView.tableView.registerClass(classAndIdentifier.0, forCellReuseIdentifier: classAndIdentifier.1)
        })
        autoAdjustTableBoardHeight(boardView, animated: false)
        boards.append(boardView)
        containerView.addSubview(boardView)
        
        guard let boardTitle = dataSource.tableBoard(tableBoard: self, titleForBoardInBoard: index) else { return }
        boardView.title = boardTitle
        boardView.alpha = 0.0
        
        let newFrame = CGRect(x: leading + CGFloat(numberOfPage - 1) * (boardWidth + pageSpacing), y: newBoardButtonView.minY, width: newBoardButtonView.width, height: newBoardButtonView.height)
        textComposeView.frame = newFrame
        UIView.animateWithDuration(0.5) { () -> Void in
            boardView.alpha = 1.0
            self.newBoardButtonView.frame = newFrame
        }
    }
    
    func textComposeView(textComposeView view: TextComposeView, didClickCancelButton button: UIButton) {
        hiddenTextComposeView()
    }
}

//MARK: - STBoardViewDelegate
extension STTableBoard: STBoardViewDelegate {
    func boardView(boardView: STBoardView, didClickBoardMenuButton button: UIButton) {
        if boardMenuVisible {
            hiddenBoardMenu()
        } else {
            showBoardMenu(button, boardIndex: boardView.index, boardTitle: boardView.title)
        }
    }
    
    func boardView(boardView: STBoardView, didClickDoneButtonForAddNewRow button: UIButton, withRowTitle title: String) {
        dataSource?.tableBoard(tableBoard: self, didAddRowAtBoard: boardView.index, withRowTitle: title)
        let tableView = boardView.tableView
        let numberOfRows = tableView.numberOfRowsInSection(0)
        let insertedIndexPath = NSIndexPath(forRow: numberOfRows - 1, inSection: 0)
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([insertedIndexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
        autoAdjustTableBoardHeight(boardView, animated: false)
        tableView.scrollToRowAtIndexPath(insertedIndexPath, atScrollPosition: .Top, animated: true)
    }
    
    func boardFootViewDidBeClicked() {
        
    }
}

extension STTableBoard: BoardMenuDelegate {
    func boardMenu(boardMenu: BoardMenu, boardMenuHandleType type: BoardMenuHandleType, userInfo: [String : AnyObject?]?) {
        switch type {
        case .BoardTitleChanged:
            if let userInfo = userInfo, let newTitle = userInfo[newBoardTitleKey] as? String {
                delegate?.tableBoard(tableBoard: self, boardTitleBeChangedTo: newTitle, inBoard: boardMenu.boardIndex)
                reloadBoardTitleAtIndex(boardMenu.boardIndex)
                hiddenBoardMenu()
            }
        case .BoardDeleted:
            let index = boardMenu.boardIndex
            removeBoardAtIndex(index)
        }
    }
}

