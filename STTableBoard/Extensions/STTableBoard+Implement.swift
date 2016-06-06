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
        containerView.frame = CGRect(origin: CGPoint.zero, size: scrollView.contentSize)
        boards.forEach { (board) -> () in
            autoAdjustTableBoardHeight(board, animated: true)
        }
    }
}

//MARK: - UITableViewDelegate
extension STTableBoard: UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let board = (tableView as! STShadowTableView).index,
            heightForRow = delegate?.tableBoard(self, heightForRowAtIndexPath: STIndexPath(forRow: indexPath.row, inBoard: board)) else { return 44.0 }
        return heightForRow
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let board = (tableView as! STShadowTableView).index else { return }
        delegate?.tableBoard(self, didSelectRowAtIndexPath: indexPath.convertToSTIndexPath(board))
    }
}

//MARK: - UITableViewDataSource
extension STTableBoard: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let board = (tableView as! STShadowTableView).index,
            numberOfRows = dataSource?.tableBoard(self, numberOfRowsInBoard: board) else { return 0 }
        return numberOfRows
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let board = (tableView as! STShadowTableView).index,
            cell = dataSource?.tableBoard(self, cellForRowAtIndexPath: STIndexPath(forRow: indexPath.row, inBoard: board)) as? STBoardCell else { fatalError("board or cell can not be nill") }
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
        guard let boardView = boardViewForVisibleTextComposeView else { return }
        boardView.hideTextComposeView()
        boardViewForVisibleTextComposeView = nil
        isAddBoardTextComposeViewVisible = true
    }
}

//MARK: - TextComposeViewDelegate
extension STTableBoard: TextComposeViewDelegate {
    func textComposeView(textComposeView view: TextComposeView, didClickDoneButton button: UIButton, withText text: String) {
        view.textField.resignFirstResponder()
        hiddenTextComposeView()
        guard let delegate = delegate else { return }
        delegate.tableBoard(self, willAddNewBoardAtIndex: numberOfPage - 1, withBoardTitle: text)
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
        dataSource?.tableBoard(self, didAddRowAtBoard: boardView.index, withRowTitle: title)
    }
}

extension STTableBoard: BoardMenuDelegate {
    func boardMenu(boardMenu: BoardMenu, boardMenuHandleType type: BoardMenuHandleType, userInfo: [String : AnyObject?]?) {
        switch type {
        case .BoardTitleChanged:
            if let userInfo = userInfo, let newTitle = userInfo[newBoardTitleKey] as? String {
                delegate?.tableBoard(self, boardTitleBeChangedTo: newTitle, inBoard: boardMenu.boardIndex)
                reloadBoardTitleAtIndex(boardMenu.boardIndex)
                hiddenBoardMenu()
            }
        case .BoardDeleted:
            let alertControllerStyle: UIAlertControllerStyle = (currentDevice == .Pad ? .Alert : .ActionSheet)
            let alertController = UIAlertController(title: nil, message: localizedString["STTableBoard.DeleteBoard.Alert.Message"], preferredStyle: alertControllerStyle)
            let deleteAction = UIAlertAction(title: localizedString["STTableBoard.Delete"], style: .Destructive, handler: { [unowned self](action) -> Void in
                let index = boardMenu.boardIndex
                self.removeBoardAtIndex(index)
            })
            let cancelAction = UIAlertAction(title: localizedString["STTableBoard.Cancel"], style: .Cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

