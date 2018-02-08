//
//  STTableBoard+Implement.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/10.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

// swiftlint:disable force_cast
// MARK: - UIGestureRecognizerDelegate
extension STTableBoard: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return false }
        if touchedView == containerView {
            return true
        } else {
            return false
        }
    }
}

// MARK: - UIScrollViewDelegate
extension STTableBoard: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            hiddenKeyBoard()
        }
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard tableBoardMode == .page && scrollView == self.scrollView else { return }
        if !decelerate {
            scrollToActualPage(scrollView, offsetX: scrollView.contentOffset.x)
        }
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard tableBoardMode == .page && scrollView == self.scrollView else { return }
        if velocity.x != 0 {
            if velocity.x < 0 && currentPage > 0 {
                scrollToPage(scrollView, page: currentPage - 1, targetContentOffset: targetContentOffset)
            } else if velocity.x > 0 && currentPage < numberOfPage - 1 {
                scrollToPage(scrollView, page: currentPage + 1, targetContentOffset: targetContentOffset)
            }
        }
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return containerView
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        switch tableBoardMode {
        case .scroll:
            originContentOffset = scrollView.contentOffset
            originContentSize = scrollView.contentSize
        case .page:
            scaledContentOffset = scrollView.contentOffset
        }
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        switch tableBoardMode {
        case .scroll:
            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: view.height)
            if scrollView.contentSize.width < originContentOffset.x * currentScale + scrollView.width {
                scrollView.contentOffset = CGPoint(x: scrollView.contentSize.width - scrollView.width, y: 0)
            } else {
                scrollView.contentOffset = CGPoint(x: originContentOffset.x * currentScale, y: 0)
            }
        case .page:
            scrollView.contentSize = originContentSize
            scrollView.contentOffset = CGPoint(x: scaledContentOffset.x / scaleForScroll, y: 0)
            if !isMoveBoardFromPageMode {
                scrollToPage(scrollView, page: pageAtPoint(tapPosition) - 1, targetContentOffset: nil)
            }
        }
        containerView.frame = CGRect(origin: .zero, size: scrollView.contentSize)
        boards.forEach { (board) -> Void in
            autoAdjustTableBoardHeight(board, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate
extension STTableBoard: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let board = (tableView as! STShadowTableView).index,
            let heightForRow = delegate?.tableBoard(self, heightForRowAt: STIndexPath(forRow: indexPath.row, inBoard: board)) else { return 44.0 }
        return heightForRow
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let board = (tableView as! STShadowTableView).index else { return }
        delegate?.tableBoard(self, didSelectRowAt: indexPath.toSTIndexPath(board: board))
    }
}

// MARK: - UITableViewDataSource
extension STTableBoard: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let board = (tableView as! STShadowTableView).index,
            let numberOfRows = dataSource?.tableBoard(self, numberOfRowsAt: board) else { return 0 }
        return numberOfRows
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let board = (tableView as! STShadowTableView).index,
            let cell = dataSource?.tableBoard(self, cellForRowAt: STIndexPath(forRow: indexPath.row, inBoard: board)) as? STBoardCell else { fatalError("board or cell can not be nill") }
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.moving = false
        return cell
    }
}

// MARK: - NewBoardButtonDelegate
extension STTableBoard: NewBoardButtonDelegate {
    func newBoardButtonDidBeClicked(newBoardButton button: NewBoardButton) {
        showTextComposeView()
        isAddBoardTextComposeViewVisible = true
        guard let boardView = boardViewForVisibleTextComposeView else { return }
        boardView.hideTextComposeView()
        boardViewForVisibleTextComposeView = nil
    }
}

// MARK: - TextComposeViewDelegate
extension STTableBoard: TextComposeViewDelegate {
    func textComposeView(textComposeView view: TextComposeView, didClickDoneButton button: UIButton, withText text: String) {
        view.textField.resignFirstResponder()
        hiddenTextComposeView()
        guard let delegate = delegate else { return }
        delegate.tableBoard(self, willAddNewBoardAt: numberOfPage - 1, with: text)
    }

    func textComposeView(textComposeView view: TextComposeView, didClickCancelButton button: UIButton) {
        hiddenTextComposeView()
    }
}

// MARK: - STBoardViewDelegate
extension STTableBoard: STBoardViewDelegate {
    func boardView(_ boardView: STBoardView, didClickBoardMenuButton button: UIButton) {
        delegate?.tableBoard(self, didTapMoreButtonAt: boardView.index, stageTitle: boardView.title, button: button)
    }

    func boardView(_ boardView: STBoardView, didClickDoneButtonForAddNewRow button: UIButton, withRowTitle title: String) {
        dataSource?.tableBoard(self, didAddRowAt: boardView.index, with: title)
    }

    func boardViewDidBeginEditingAtBottomRow(boardView view: STBoardView) {
        dataSource?.tableBoard(self, willBeginAddingRowAt: view.index)
    }

    func boardViewDidClickCancelButtonForAddNewRow(_ boardView: STBoardView) {
        dataSource?.tableBoard(self, didCancelAddRowAt: boardView.index)
    }

    func customAddRowAction(for boardView: STBoardView) -> (() -> Void)? {
        return dataSource?.customAddRowAction(for: self, at: boardView.index)
    }
}
