//
//  STTableBoard+Extension.swift
//  STTableBoard
//
//  Created by DangGu on 15/12/4.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

// MARK: - double tap
// swiftlint:disable identifier_name
extension STTableBoard {
    @objc func handleDoubleTap(_ recognizer: UIGestureRecognizer) {
        tapPosition = recognizer.location(in: containerView)
        dataSource?.tableBoard(self, scaleTableBoard: tableBoardMode == .page)
        switchMode()
    }

    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        delegate?.tableBoard(self, handlePinchGesture: recognizer)
    }

    func switchMode() {
        let isLandscapeIniPhone = currentOrientation == .landscape && currentDevice == .phone
        var newMode: STTableBoardMode = tableBoardMode == .page ? .scroll : .page
        if isLandscapeIniPhone {
            newMode = .scroll
        }
        var newScale: CGFloat = 0.0
        switch newMode {
        case .page:
            newScale = scaleForPage
            tableBoardMode = .page
            currentScale = newScale
        case .scroll:
            if isLandscapeIniPhone && currentScale == scaleForScroll {
                newScale = scaleForPage
            } else {
                newScale = scaleForScroll
            }
            tableBoardMode = .scroll
            currentScale = newScale
        }
        scrollView.setZoomScale(newScale, animated: true)
    }
}

// MARK: - long press drag for board
extension STTableBoard {
    @objc func handleLongPressGestureForBoard(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startMovingBoard(recognizer)
        case .changed:
            guard snapshot != nil else {
                return
            }
            let positionInContainerView = recognizer.location(in: containerView)
            moveSnapshotToPosition(positionInContainerView)
            autoScrollInScrollView()
            moveBoardToPosition(positionInContainerView)
        case .cancelled:
            guard snapshot != nil else {
                return
            }
            endMovingBoard(false)
            recognizer.isEnabled = true
        default:
            guard snapshot != nil else {
                return
            }
            endMovingBoard()
        }

    }

    func startMovingBoard(_ recognizer: UIGestureRecognizer) {
        let positionInContainerView = recognizer.location(in: containerView)
        guard let board = boardAtPoint(positionInContainerView), let dataSource = self.dataSource, dataSource.tableBoard(self, canMoveBoardAt: board.index) else {
            return
        }
        if currentDevice == .phone && currentScale == scaleForPage {
            switchMode()
            isMoveBoardFromPageMode = true
        }
        hiddenKeyBoard()
        snapshot = board.snapshot
        snapshot.center = board.center
        containerView.addSubview(snapshot)
        updateSnapViewStatus(.origin)
        snapshotCenterOffset = caculatePointOffset(originViewCenter: board.center, position: positionInContainerView, fromView: containerView)

        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.updateSnapViewStatus(.moving)
            board.moving = true
            }, completion: nil)
        sourceIndex = board.index
        originIndex = board.index
        if let longPressRecognizer = recognizer as? UILongPressGestureRecognizer {
            currentLongPressGestureForBoard = longPressRecognizer
        }
    }

    func endMovingBoard(_ callDataSource: Bool = true) {
        guard sourceIndex != -1 else {
            return
        }

        if isScrolling {
            stopAnimation()
        }

        let board = boards[sourceIndex]

        func resetBoard() {
            if isMoveBoardFromPageMode {
                switchMode()
                isMoveBoardFromPageMode = false
                scrollToPage(scrollView, page: sourceIndex, targetContentOffset: nil)
            } else {
                scrollToActualPage(scrollView, offsetX: scrollView.contentOffset.x)
            }
            if callDataSource {
                dataSource?.tableBoard(self, didEndMoveBoardAt: originIndex, to: sourceIndex)
            }
            sourceIndex = -1
            originIndex = -1
        }

        UIView.animate(withDuration: 0.33, animations: { () -> Void in
//            self.snapshot.frame = board.frame
            self.snapshot.center = board.center
            self.updateSnapViewStatus(.origin)
            }, completion: { (_) -> Void in
                board.moving = false
                self.snapshot.removeFromSuperview()
                self.snapshot = nil
                resetBoard()
        })
        if currentLongPressGestureForBoard != nil {
            currentLongPressGestureForBoard = nil
        }
    }

    func moveBoardToPosition(_ positionInContainerView: CGPoint) {
        let realPointX = isScrolling ? scrollView.presentContenOffset()!.x / currentScale + snapshotOffsetForLeftBounds + snapshotCenterOffset.x: positionInContainerView.x

        guard let destinationBoard = boardAtPointInBoardArea(CGPoint(x: realPointX, y: positionInContainerView.y)) else {
            return
        }

        if destinationBoard.index != sourceIndex, let dataSource = dataSource, dataSource.tableBoard(self, shouldMoveBoardAt: sourceIndex, to: destinationBoard.index) {
            FeedbackGenerator.impactOccurred()
        }
        tableBoard(self, moveBoardAtIndex: sourceIndex, toIndex: destinationBoard.index)
    }
}

// MARK: - long press drag for cell
extension STTableBoard {
    @objc func handleLongPressGestureForCell(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startMovingRow(recognizer)
        case .changed:
            guard snapshot != nil else {
                return
            }
            let positionInContainerView = recognizer.location(in: containerView)
            let realPointX = isScrolling ? scrollView.presentContenOffset()!.x / currentScale + snapshotOffsetForLeftBounds + snapshotCenterOffset.x: positionInContainerView.x
            let tableView = tableViewAtPoint(CGPoint(x: realPointX, y: positionInContainerView.y))
            moveSnapshotToPosition(positionInContainerView)
            autoScrollInScrollView()
            switch dropMode {
            case .row:
                autoScrollInTableView(tableView)
                moveRowToPosition(tableView, recognizer: recognizer)
            case .board:
                if tableView?.index == originIndexPath.board {
                    deactivateDropMaskForDestinationBoard()
                    destinationBoardIndex = nil
                    autoScrollInTableView(tableView)
                    moveRowToPosition(tableView, recognizer: recognizer)
                } else {
                    moveRowToBoard(tableView, recognizer: recognizer)
                }
            }
        case .cancelled:
            guard snapshot != nil else {
                return
            }
            endMovingRow(false)
            recognizer.isEnabled = true
        default:
            guard snapshot != nil else {
                return
            }
            endMovingRow()
        }
    }

    func startMovingRow(_ recognizer: UIGestureRecognizer) {
        guard let tableView = tableViewAtPoint(recognizer.location(in: containerView)) else {
            return
        }
        let positionInTableView = recognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: positionInTableView), let cell = tableView.cellForRow(at: indexPath) as? STBoardCell else {
            return
        }
        guard let dataSource = self.dataSource, dataSource.tableBoard(self, canMoveRowAt: indexPath.toSTIndexPath(board: tableView.index)) else {
            return
        }
        hiddenKeyBoard()
        snapshot = cell.snapshot
        updateSnapViewStatus(.origin)
        snapshot.center = containerView.convert(cell.center, from: tableView)
        containerView.addSubview(snapshot)
        snapshotCenterOffset = caculatePointOffset(originViewCenter: cell.center, position: positionInTableView, fromView: tableView)
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.updateSnapViewStatus(.moving)
            cell.moving = true
        }, completion: nil)
        sourceIndexPath = STIndexPath(forRow: indexPath.row, section: indexPath.section, inBoard: tableView.index)
        originIndexPath = STIndexPath(forRow: indexPath.row, section: indexPath.section, inBoard: tableView.index)
        if let longpressRecognizer = recognizer as? UILongPressGestureRecognizer {
            currentLongPressGestureForCell = longpressRecognizer
        }

        dropMode = delegate?.dropMode(for: self, whenMovingRowAt: originIndexPath) ?? .row
    }

    func endMovingRow(_ callDataSource: Bool = true) {
        let sourceTableView = boards[sourceIndexPath.board].tableView

        if dropMode == .board, let destinationBoardIndex = self.destinationBoardIndex {
            dataSource?.tableBoard(self, moveRowAt: sourceIndexPath, toDestinationBoard: destinationBoardIndex)
            rowDidBeRemovedFromTableView(sourceTableView!)
            UIView.animate(withDuration: 0.33, animations: {
                self.deactivateDropMaskForDestinationBoard()
                self.snapshot.transform = .identity
                self.snapshot.alpha = 0
                }, completion: { (_) in
                    self.snapshot.removeFromSuperview()
                    self.snapshot = nil
                    if callDataSource {
                        self.dataSource?.tableBoard(self, didEndMoveRowAt: self.originIndexPath, toDestinationBoard: destinationBoardIndex)
                    }
                    self.sourceIndexPath = nil
                    self.originIndexPath = nil
                    self.destinationBoardIndex = nil
                    self.dropMode = .row
            })
        } else {
            guard let cell = sourceTableView?.cellForRow(at: sourceIndexPath.toIndexPath()) as? STBoardCell else {
                return
            }
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                self.snapshot.center = self.containerView.convert(cell.center, from: sourceTableView)
                self.updateSnapViewStatus(.origin)
                }, completion: { (_) -> Void in
                    cell.moving = false
                    self.snapshot.removeFromSuperview()
                    self.snapshot = nil
                    if callDataSource {
                        self.dataSource?.tableBoard(self, didEndMoveRowAt: self.originIndexPath, toDestinationIndexPath: self.sourceIndexPath)
                    }
                    self.sourceIndexPath = nil
                    self.originIndexPath = nil
                    self.destinationBoardIndex = nil
                    self.dropMode = .row
            })
        }

        if isScrolling {
            stopAnimation()
        }
        if let timer = tableViewAutoScrollTimer {
            tableViewAutoScrollDistance = 0
            timer.invalidate()
            tableViewAutoScrollTimer = nil
        }
        scrollToActualPage(scrollView, offsetX: scrollView.contentOffset.x)
        lastMovingTime = nil
        if currentLongPressGestureForCell != nil {
            currentLongPressGestureForCell = nil
        }
    }

    func moveSnapshotToPosition(_ position: CGPoint) {
        snapshot.center = caculateSnapShot(position)
        snapshotOffsetForLeftBounds = snapshot.center.x - (tableBoardMode == .page ? scrollView.contentOffset.x : scrollView.contentOffset.x / currentScale)
    }

    func moveRowToBoard(_ tableView: STShadowTableView?, recognizer: UIGestureRecognizer) {
        guard let tableView = tableView, dataSource?.tableBoard(self, shouldMoveRowAt: sourceIndexPath, originIndexPath: originIndexPath, toDestinationBoard: tableView.index) == true else {
            deactivateDropMaskForDestinationBoard()
            destinationBoardIndex = originIndexPath.board
            return
        }
        if let lastMovingTime = lastMovingTime {
            guard Date().timeIntervalSince(lastMovingTime) > minimumMovingRowInterval else {
                return
            }
        }
        deactivateDropMaskForDestinationBoard()
        let newDestinationBoard = boards[tableView.index]
        newDestinationBoard.dropMessageLabel.text = dataSource?.tableBoard(self, dropReleaseTextForBoardAt: tableView.index)
        newDestinationBoard.activateDropMask()
        if newDestinationBoard.index != destinationBoardIndex {
            FeedbackGenerator.impactOccurred()
        }
        destinationBoardIndex = newDestinationBoard.index
        lastMovingTime = Date()
    }

    func moveRowToPosition(_ tableView: STShadowTableView?, recognizer: UIGestureRecognizer) {
        guard let tableView = tableView, dataSource != nil else {
            return
        }
        let positionInTableView = recognizer.location(in: tableView)

        if tableView.height == 0.0 {
            let indexPath = IndexPath(row: 0, section: 0)
            moveRowToIndexPath(indexPath, tableView: tableView)
        } else {
            var realPoint = positionInTableView
            switch (isScrolling, scrollDirection) {
            case (true, ScrollDirection.left):
                realPoint = CGPoint(x: positionInTableView.x + scrollView.presentContenOffset()!.x / currentScale, y: positionInTableView.y)
            case (true, ScrollDirection.right):
                realPoint = CGPoint(x: positionInTableView.x - (scrollView.contentOffset.x - scrollView.presentContenOffset()!.x) / currentScale, y: positionInTableView.y)
            default:
                break
            }

            if let indexPath = tableView.indexPathForRow(at: realPoint) {
                moveRowToIndexPath(indexPath, tableView: tableView)
            }
        }
    }

    fileprivate func moveRowToIndexPath(_ indexPath: IndexPath, tableView: STShadowTableView) {
        guard dataSource!.tableBoard(self, shouldMoveRowAt: sourceIndexPath, originIndexPath: originIndexPath, toDestinationIndexPath: indexPath.toSTIndexPath(board: tableView.index)) else {
            return
        }
        if let lastMovingTime = lastMovingTime {
            guard Date().timeIntervalSince(lastMovingTime) > minimumMovingRowInterval else {
                return
            }
        }
        var destinationIndexPath: STIndexPath = indexPath.toSTIndexPath(board: tableView.index)
        dataSource!.tableBoard(self, moveRowAt: sourceIndexPath, toDestinationIndexPath: &destinationIndexPath)
        let newIndexPath = destinationIndexPath.toIndexPath()
        if sourceIndexPath.board == tableView.index {
            tableView.beginUpdates()
            tableView.deleteRows(at: [sourceIndexPath.toIndexPath()], with: .fade)
            tableView.insertRows(at: [newIndexPath], with: .none)
            tableView.endUpdates()
            if let cell = tableView.cellForRow(at: newIndexPath) as? STBoardCell {
                cell.moving = true
            }
            if newIndexPath != sourceIndexPath.toIndexPath() {
                FeedbackGenerator.impactOccurred()
            }
        } else {
            let sourceTableView = boards[sourceIndexPath.board].tableView
            sourceTableView?.beginUpdates()
            sourceTableView?.deleteRows(at: [sourceIndexPath.toIndexPath()], with: .fade)
            sourceTableView?.endUpdates()
            rowDidBeRemovedFromTableView(sourceTableView!)
            tableView.beginUpdates()
            tableView.insertRows(at: [newIndexPath], with: .fade)
            tableView.endUpdates()
            rowDidBeInsertedIntoTableView(tableView)
            if let cell = tableView.cellForRow(at: newIndexPath) as? STBoardCell {
                cell.moving = true
            }
            FeedbackGenerator.impactOccurred()
        }
        sourceIndexPath = newIndexPath.toSTIndexPath(board: tableView.index)
        lastMovingTime = Date()
    }

    func updateSnapViewStatus(_ status: SnapViewStatus) {
        guard let snapshot = snapshot else {
            return
        }

        switch status {
        case .moving:
            let rotate = CGAffineTransform.identity.rotated(by: rotateAngel)
            let scale = CGAffineTransform.identity.scaledBy(x: 1.05, y: 1.05)
            snapshot.transform = scale.concatenating(rotate)
            snapshot.alpha = 0.95
            FeedbackGenerator.selectionChanged()
        case .origin:
            snapshot.transform = .identity
            snapshot.alpha = 1.0
        }

    }

    func autoScrollInScrollView() {
        // caculate velocity
        func velocityByOffset(_ offset: CGFloat) -> CGFloat {
            var newVelocity = defaultScrollViewScrollVelocity
            if offset >= 80 {
                newVelocity = 400
            } else if offset >= 50 {
                newVelocity = 200
            } else if offset >= 20 {
                newVelocity = 100
            }
            return newVelocity
        }

        guard let snapshot = self.snapshot else {
            return
        }
        let minX = snapshot.layer.presentation()!.frame.origin.x * currentScale
        let maxX = (snapshot.layer.presentation()!.frame.origin.x + snapshot.width) * currentScale
        let leftOffsetX = isScrolling ? scrollView.presentContenOffset()!.x : scrollView.contentOffset.x
        let rightOffsetX = (isScrolling ? scrollView.presentContenOffset()!.x : scrollView.contentOffset.x) + scrollView.width

        // left scrolling
        if minX < leftOffsetX && leftOffsetX > 0 {
            let offset = leftOffsetX - minX
            let newVelocity = velocityByOffset(offset)
            if newVelocity == self.velocity {
                if isScrolling {
                    return
                }
            } else {
                self.velocity = newVelocity
                stopAnimation()
            }
            isScrolling = true
            scrollDirection = .left
            let duration = Double(leftOffsetX / self.velocity)
            UIView.animate(withDuration: duration, delay: 0.0,
                options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear],
                animations: { () -> Void in
                    self.scrollView.contentOffset = .zero
                    snapshot.center = CGPoint(x: self.snapshotOffsetForLeftBounds + self.scrollView.contentOffset.x / self.currentScale, y: snapshot.center.y)
                }, completion: nil)
        } else if maxX > rightOffsetX && rightOffsetX < scrollView.contentSize.width {
            let offset = maxX - rightOffsetX
            let newVelocity = velocityByOffset(offset)
            if newVelocity == self.velocity {
                if isScrolling {
                    return
                }
            } else {
                self.velocity = newVelocity
                stopAnimation()
            }
            isScrolling = true
            scrollDirection = .right
            let scrollViewContentWidth = scrollView.contentSize.width
            let duration = Double((scrollViewContentWidth - rightOffsetX) / self.velocity)
            UIView.animate(withDuration: duration, delay: 0.0,
                options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear],
                animations: { () -> Void in
                    self.scrollView.contentOffset = CGPoint(x: scrollViewContentWidth - self.scrollView.width, y: 0)
                    snapshot.center = CGPoint(x: self.snapshotOffsetForLeftBounds + self.scrollView.contentOffset.x / self.currentScale, y: snapshot.center.y)
                }, completion: nil)
        } else {
            if isScrolling {
                stopAnimation()
            }
        }
    }

    func autoScrollInTableView(_ tableView: STShadowTableView?) {
        guard let tableView = tableView else {
            return
        }

        func canTableViewScroll() -> Bool {
            return tableView.height < tableView.contentSize.height
        }

        func caculateScrollDistanceForTableView() {
            let convertedTopLeftPoint = tableView.superview!.convert(snapshotTopLeftPoint(), from: containerView)
            let convertedBootomRightPoint = tableView.superview!.convert(snapshotBottomRightPoint(), from: containerView)
            let distanceToTopEdge = convertedTopLeftPoint.y - tableView.frame.minY
            let distanceToBottomEdge = tableView.frame.maxY - convertedBootomRightPoint.y

            if distanceToTopEdge < 0 {
                tableViewAutoScrollDistance = CGFloat(ceilf(Float(distanceToTopEdge / 5.0)))
            } else if distanceToBottomEdge < 0 {
                tableViewAutoScrollDistance = CGFloat(ceilf(Float(distanceToBottomEdge / 5.0))) * -1
            }
        }

        let convertedSnapshotRectInBoard = tableView.superview!.convert(snapshot.layer.presentation()!.frame, from: containerView)
        if canTableViewScroll() && tableView.frame.intersects(convertedSnapshotRectInBoard) {
            caculateScrollDistanceForTableView()

            if tableViewAutoScrollDistance == 0 {
                guard let timer = tableViewAutoScrollTimer else {
                    return
                }
                timer.invalidate()
                tableViewAutoScrollTimer = nil
            } else if tableViewAutoScrollTimer == nil {
                tableViewAutoScrollTimer = Timer.scheduledTimer(timeInterval: (1.0 / 60.0), target: self, selector: #selector(tableViewAutoScrollTimerFired(_:)), userInfo: [timerUserInfoTableViewKey: tableView], repeats: true)
            }
        }
    }

    func optimizeTableViewScrollDistance(_ tableView: STShadowTableView) {
        let minumumDistance = tableView.contentOffset.y * -1
        let maximumDistance = tableView.contentSize.height - (tableView.frame.height + tableView.contentOffset.y)
        tableViewAutoScrollDistance = max(tableViewAutoScrollDistance, minumumDistance)
        tableViewAutoScrollDistance = min(tableViewAutoScrollDistance, maximumDistance)
    }

    @objc func tableViewAutoScrollTimerFired(_ timer: Timer) {
        guard let userInfo = timer.userInfo as? [String: Any], let tableView = userInfo[timerUserInfoTableViewKey] as? STShadowTableView else {
            return
        }
        optimizeTableViewScrollDistance(tableView)

        tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + tableViewAutoScrollDistance)
    }

    func rowDidBeRemovedFromTableView(_ tableView: STShadowTableView) {
        guard let board = tableView.superview as? STBoardView else {
            return
        }
        autoAdjustTableBoardHeight(board, animated: true)
    }

    func rowDidBeInsertedIntoTableView(_ tableView: STShadowTableView) {
        guard let board = tableView.superview as? STBoardView else {
            return
        }
        autoAdjustTableBoardHeight(board, animated: true)
    }

    func deactivateDropMaskForDestinationBoard() {
        guard let destinationBoardIndex = destinationBoardIndex else {
            return
        }
        let destinationBoard = boards[destinationBoardIndex]
        destinationBoard.deactivateDropMask()
    }

    // stop the scrollView animation
    func stopAnimation() {
        let contentOffsetX = scrollView.layer.presentation()!.bounds.origin.x
        CATransaction.begin()
        scrollView.layer.removeAllAnimations()
        snapshot?.layer.removeAllAnimations()
        CATransaction.commit()
        scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: false)
        snapshot?.center = CGPoint(x: self.snapshotOffsetForLeftBounds + scrollView.presentContenOffset()!.x / currentScale, y: snapshot.center.y)
        isScrolling = false
        scrollDirection = .none
    }
}

// MARK: - board helper method
extension STTableBoard {
    func caculateBoardHeight(_ board: STBoardView) -> CGFloat {
        guard let tableView = board.tableView else {
            return 0
        }
        var height: CGFloat = headerViewHeight + board.footerViewHeightConstant
        let numberOfSections = tableView.numberOfSections
        for section in 0..<numberOfSections {
            let sectionHeaderHeight = self.tableView(tableView, heightForHeaderInSection: section)
            height += sectionHeaderHeight
            let numberOfRows = tableView.numberOfRows(inSection: section)
            for row in 0..<numberOfRows {
                height += self.tableView(tableView, heightForRowAt: IndexPath(row: row, section: section))
            }
            let sectionFooterHeight = self.tableView(tableView, heightForFooterInSection: section)
            height += sectionFooterHeight
        }
        return height
    }

    func autoAdjustTableBoardHeight(_ board: STBoardView, animated: Bool) {
        let boardHeight = caculateBoardHeight(board)
        let newHeight = min(boardHeight, maxBoardHeight)
        if animated {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                board.frame.size.height = newHeight
                board.layoutIfNeeded()
            })
        } else {
            board.frame.size.height = newHeight
        }
    }

    func tableBoard(_ tableBoard: STTableBoard, moveBoardAtIndex sourceIndex: Int, toIndex destinationIndex: Int) {
        guard sourceIndex != destinationIndex, let dataSource = dataSource, dataSource.tableBoard(self, shouldMoveBoardAt: sourceIndex, to: destinationIndex) else {
            return
        }
        dataSource.tableBoard(self, moveBoardAt: sourceIndex, to: destinationIndex)

        let sourceBoard = boards[sourceIndex]
        let destinationBoard = boards[destinationIndex]
        self.boards[sourceIndex] = destinationBoard
        self.boards[destinationIndex] = sourceBoard
        (sourceBoard.index, destinationBoard.index) = (destinationBoard.index, sourceBoard.index)
        self.sourceIndex = destinationIndex

        let destinationOrigin = destinationBoard.frame.origin
        let sourceOrigin = sourceBoard.frame.origin
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            sourceBoard.frame = CGRect(origin: destinationOrigin, size: sourceBoard.bounds.size)
            destinationBoard.frame = CGRect(origin: sourceOrigin, size: destinationBoard.bounds.size)
            }, completion: nil)
    }

    func showTextComposeView() {
        textComposeView.textField.becomeFirstResponder()
        textComposeView.textField.text = nil
        textComposeView.alpha = 1.0
        newBoardButtonView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.textComposeView.frame.size.height = newBoardComposeViewHeight
        })
    }

    func hiddenTextComposeView() {
        self.textComposeView.textField.resignFirstResponder()
        self.textComposeView.textField.text = nil
        self.newBoardButtonView.alpha = 1.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.textComposeView.alpha = 0.0
            self.textComposeView.frame.size.height = newBoardButtonViewHeight
        })
    }

    func hiddenKeyBoard() {
        if let boardView = boardViewForVisibleTextComposeView {
            boardView.hideTextComposeView()
        }
        if isAddBoardTextComposeViewVisible {
            hiddenTextComposeView()
            isAddBoardTextComposeViewVisible = false
        }
    }
}

// MARK: - Position helper method
extension STTableBoard {
    func boardAtPointInBoardArea(_ pointInContainerView: CGPoint) -> STBoardView? {
        var returnedBoard: STBoardView?
        boards.forEach { (board) -> Void in
            if pointInContainerView.x > board.minX && pointInContainerView.x < board.maxX {
                returnedBoard = board
            }
        }
        return returnedBoard
    }

    func boardAtPoint(_ pointInContainerView: CGPoint) -> STBoardView? {
        var returnedBoard: STBoardView?
        boards.forEach { (board) -> Void in
            if board.frame.contains(pointInContainerView) {
                returnedBoard = board
            }
        }
        return returnedBoard
    }

    func tableViewAtPoint(_ pointInContainerView: CGPoint) -> STShadowTableView? {
        guard let board = boardAtPoint(pointInContainerView) else {
            return nil
        }
        return board.tableView
    }

    func caculatePointOffset(originViewCenter: CGPoint, position: CGPoint, fromView: UIView) -> CGPoint {
        var convertedOriginViewCenter = originViewCenter
        var convertedPosition = position
        if fromView != containerView {
            convertedOriginViewCenter = containerView.convert(originViewCenter, from: fromView)
            convertedPosition = containerView.convert(position, from: fromView)
        }
        return CGPoint(x: convertedPosition.x - convertedOriginViewCenter.x, y: convertedPosition.y - convertedOriginViewCenter.y)
    }

    func caculateSnapShot(_ position: CGPoint) -> CGPoint {
        return CGPoint(x: position.x - snapshotCenterOffset.x, y: position.y - snapshotCenterOffset.y)
    }

    func snapshotBottomRightPoint() -> CGPoint {
        guard let snapshot = snapshot else {
            return .zero
        }
        let width = snapshot.width * 1.05
        let height = snapshot.height * 1.05
        let tanAngle = snapshot.height / snapshot.width
        let angle = atan(tanAngle) + rotateAngel
        let radius = sqrt(width * width + height * height) / 2
        let positionX = snapshot.layer.presentation()!.position.x + radius * cos(angle)
        let positionY = snapshot.layer.presentation()!.position.y + radius * sin(angle)
        return CGPoint(x: positionX, y: positionY)
    }

    func snapshotTopLeftPoint() -> CGPoint {
        guard let snapshot = snapshot else {
            return .zero
        }
        let width = snapshot.width * 1.05
        let height = snapshot.height * 1.05
        let tanAngle = snapshot.height / snapshot.width
        let angle = atan(tanAngle) + rotateAngel
        let radius = sqrt(width * width + height * height) / 2
        let positionX = snapshot.layer.presentation()!.position.x - radius * cos(angle)
        let positionY = snapshot.layer.presentation()!.position.y - radius * sin(angle)
        return CGPoint(x: positionX, y: positionY)
    }

    func pageAtPoint(_ pointInContainerView: CGPoint) -> Int {
        let pointX = pointInContainerView.x
        guard pointX > leading else {
            return 0
        }
        let page = Int(ceilf(Float((pointX - leading) / (scrollView.width - leading - pageSpacing))))
        return page
    }

    func insertBoardAtIndex(_ index: Int, animation: Bool) {
        if animation {
            resetContentSize()
        }
        let x = leading + CGFloat(index) * (boardWidth + pageSpacing)
        let y = top
        let boardViewFrame = CGRect(x: x, y: y, width: boardWidth, height: maxBoardHeight)

        let shouldShowActionButton = dataSource?.tableBoard(self, shouldShowActionButtonAt: index) ?? true
        let showRefreshFooter = dataSource?.tableBoard(self, showRefreshFooterAt: index) ?? false
        let shouldEnableAddRow = dataSource?.tableBoard(self, shouldEnableAddRowAt: index) ?? true
        let boardView = STBoardView(frame: boardViewFrame, shouldShowActionButton: shouldShowActionButton, showRefreshFooter: showRefreshFooter, shouldEnableAddRow: shouldEnableAddRow)
        boardView.headerView.addGestureRecognizer(self.longPressGestureForBoard)
        boardView.tableView.addGestureRecognizer(self.longPressGestureForCell)
        boardView.index = index
        boardView.tableBoard = self
        boardView.tableView.delegate = self
        boardView.tableView.dataSource = self
        boardView.delegate = self
        registeredCellClasses.forEach {
            boardView.tableView.register($0.0, forCellReuseIdentifier: $0.1)
        }
        registeredHeaderFooterViewClasses.forEach {
            boardView.tableView.register($0.0, forHeaderFooterViewReuseIdentifier: $0.1)
        }
        autoAdjustTableBoardHeight(boardView, animated: false)
        boards.insert(boardView, at: index)
        containerView.addSubview(boardView)

        guard let dataSource = dataSource, let boardTitle = dataSource.tableBoard(self, titleForBoardAt: index) else {
            return
        }
        boardView.title = boardTitle
        boardView.number = dataSource.tableBoard(self, numberForBoardAt: index)
        if animation {
            boardView.alpha = 0
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                boardView.alpha = 1.0
            })
        }

        if boards.count > index + 1 {
            for i in (index + 1)...(boards.count - 1) {
                let otherBoardView = boards[i]
                otherBoardView.index += 1
                let newFrame = CGRect(x: leading + CGFloat(i) * (boardWidth + pageSpacing), y: otherBoardView.minY, width: otherBoardView.width, height: otherBoardView.height)
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    otherBoardView.frame = newFrame
                })
            }
        }

        if showAddBoardButton && animation {
            let newFrame = CGRect(x: leading + CGFloat(numberOfPage - 1) * (boardWidth + pageSpacing), y: newBoardButtonView.minY, width: newBoardButtonView.width, height: newBoardButtonView.height)
            textComposeView.frame = newFrame
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.newBoardButtonView.frame = newFrame
            })
        }
        pageControl.numberOfPages = numberOfPage
    }
}

// MARK: - UITableView help method
extension STTableBoard {
    public func registerCellClasses(_ classAndIdentifiers: [(AnyClass, String)]) {
        registeredCellClasses = classAndIdentifiers
    }

    public func registerHeaderFooterViewClasses(_ classAndIdentifiers: [(AnyClass, String)]) {
        registeredHeaderFooterViewClasses = classAndIdentifiers
    }

    public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: STIndexPath) -> UITableViewCell {
        guard let tableView = boards[indexPath.board].tableView else {
            return UITableViewCell()
        }
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: IndexPath(row: indexPath.row, section: indexPath.section))
    }

    public func dequeueReusableHeaderFooterView(withIdentifier identifier: String, atBoard boardIndex: Int) -> UITableViewHeaderFooterView? {
        guard let tableView = boards[boardIndex].tableView else {
            return nil
        }
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
    }
}

// MARK: - IndexPath helper
extension IndexPath {
    func toSTIndexPath(board: Int) -> STIndexPath {
        return STIndexPath(forRow: row, section: section, inBoard: board)
    }
}

extension STIndexPath {
    func toIndexPath() -> IndexPath {
        return IndexPath(row: row, section: section)
    }
}

// MARK: - Page method
extension STTableBoard {
    func scrollToActualPage(_ scrollView: UIScrollView, offsetX: CGFloat) {
        guard tableBoardMode == .page && currentOrientation == .portrait else {
            return
        }
        let pageOffset = scrollView.frame.width - overlap
        let proportion = offsetX / pageOffset
        let page = Int(proportion)
        let actualPage = (offsetX - pageOffset * CGFloat(page)) > (pageOffset * 1 / 2) ?  page + 1 : page
        currentPage = actualPage

        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            scrollView.contentOffset = CGPoint(x: pageOffset * CGFloat(actualPage), y: 0)
        })
    }

    func scrollToPage(_ scrollView: UIScrollView, page: Int, targetContentOffset: UnsafeMutablePointer<CGPoint>?) {
        guard tableBoardMode == .page && currentOrientation == .portrait else {
            return
        }
        let pageOffset = scrollView.frame.width - overlap
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            scrollView.contentOffset = CGPoint(x: pageOffset * CGFloat(page), y: 0)
        })
        if let targetContentOffset = targetContentOffset {
            targetContentOffset.pointee = CGPoint(x: pageOffset * CGFloat(page), y: 0)
        }
        currentPage = page
    }
}
