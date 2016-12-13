//
//  STTableBoardExtensions.swift
//  STTableBoard
//
//  Created by DangGu on 15/12/4.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

//MARK: - double tap
extension STTableBoard {
    func handleDoubleTap(_ recognizer: UIGestureRecognizer) {
        tapPosition = recognizer.location(in: containerView)
        dataSource?.tableBoard(self, scaleTableBoard: tableBoardMode == .page)
        switchMode()
    }

    func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
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

//MARK: - long press drag for board
extension STTableBoard {
    func handleLongPressGestureForBoard(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startMovingBoard(recognizer)
        case .changed:
            guard let _ = snapshot else { return }
            let positionInContainerView = recognizer.location(in: containerView)
            moveSnapshotToPosition(positionInContainerView)
            autoScrollInScrollView()
            moveBoardToPosition(positionInContainerView)
        case .cancelled:
            guard let _ = snapshot else { return }
            endMovingBoard(false)
            recognizer.isEnabled = true
        default:
            guard let _ = snapshot else { return }
            endMovingBoard()
        }
        
    }
    
    func startMovingBoard(_ recognizer: UIGestureRecognizer) {
        let positionInContainerView = recognizer.location(in: containerView)
        guard let board = boardAtPoint(positionInContainerView), let dataSource = self.dataSource , dataSource.tableBoard(self, canMoveBoardAt: board.index) else { return }
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
        guard sourceIndex != -1 else { return }
        let board = boards[sourceIndex]
        
        func resetBoard() {
            if isScrolling {
                stopAnimation()
            }
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
            }, completion: { (finished) -> Void in
                board.moving = false
                self.snapshot.removeFromSuperview()
                self.snapshot = nil
                resetBoard()
        }) 
        if let _ = currentLongPressGestureForBoard {
            currentLongPressGestureForBoard = nil
        }
    }
    
    func moveBoardToPosition(_ positionInContainerView: CGPoint) {
        let realPointX = isScrolling ? scrollView.presentContenOffset()!.x / currentScale + snapshotOffsetForLeftBounds + snapshotCenterOffset.x: positionInContainerView.x
        
        guard let destinationBoard = boardAtPointInBoardArea(CGPoint(x: realPointX, y: positionInContainerView.y)) else { return }
        
        
        tableBoard(self, moveBoardAtIndex: sourceIndex, toIndex: destinationBoard.index)
    }
}

//MARK: - long press drag for cell
extension STTableBoard {
    func handleLongPressGestureForCell(_ recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startMovingRow(recognizer)
        case .changed:
            // move snapShot
            guard let _ = snapshot else { return }
            let positionInContainerView = recognizer.location(in: containerView)
            let realPointX = isScrolling ? scrollView.presentContenOffset()!.x / currentScale + snapshotOffsetForLeftBounds + snapshotCenterOffset.x: positionInContainerView.x
            let tableView = tableViewAtPoint(CGPoint(x: realPointX, y: positionInContainerView.y))
            moveSnapshotToPosition(positionInContainerView)
            autoScrollInScrollView()
            autoScrollInTableView(tableView)
            moveRowToPosition(tableView, recognizer: recognizer)
        case .cancelled:
            guard let _ = snapshot else { return }
            endMovingRow(false)
            recognizer.isEnabled = true
        default:
            guard let _ = snapshot else { return }
            endMovingRow()
        }
    }

    func startMovingRow(_ recognizer: UIGestureRecognizer) {
        guard let tableView = tableViewAtPoint(recognizer.location(in: containerView)) else { return }
        let positionInTableView = recognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: positionInTableView), let cell = tableView.cellForRow(at: indexPath) as? STBoardCell else {return}
        guard let dataSource = self.dataSource , dataSource.tableBoard(self, canMoveRowAt: indexPath.convertToSTIndexPath(tableView.index)) else { return }
        hiddenKeyBoard()
        snapshot = cell.snapshot
        updateSnapViewStatus(.origin)
        snapshot.center = containerView.convert(cell.center, from: tableView)
        containerView.addSubview(snapshot)
        snapshotCenterOffset = caculatePointOffset(originViewCenter: cell.center, position: positionInTableView, fromView: tableView)
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.updateSnapViewStatus(.moving)
            cell.moving = true
            }, completion:nil)
        sourceIndexPath = STIndexPath(forRow: indexPath.row, inBoard: tableView.index)
        originIndexPath = STIndexPath(forRow: indexPath.row, inBoard: tableView.index)
        if let longpressRecognizer = recognizer as? UILongPressGestureRecognizer {
            currentLongPressGestureForCell = longpressRecognizer
        }
    }

    func endMovingRow(_ callDataSource: Bool = true) {
        let sourceTableView = boards[sourceIndexPath.board].tableView
        guard let cell = sourceTableView?.cellForRow(at: sourceIndexPath.ConvertToIndexPath()) as? STBoardCell else {return}
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.snapshot.center = self.containerView.convert(cell.center, from: sourceTableView)
            self.updateSnapViewStatus(.origin)
            }, completion: { (finished) -> Void in
                cell.moving = false
                self.snapshot.removeFromSuperview()
                self.snapshot = nil
                if callDataSource {
                    self.dataSource?.tableBoard(self, didEndMoveRowAt: self.originIndexPath, to: self.sourceIndexPath)
                }
                self.sourceIndexPath = nil
                self.originIndexPath = nil
            })
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
        if let _ = currentLongPressGestureForCell {
            currentLongPressGestureForCell = nil
        }
    }
    
    func moveSnapshotToPosition(_ position: CGPoint) {
        snapshot.center = caculateSnapShot(position)
        snapshotOffsetForLeftBounds = snapshot.center.x - (tableBoardMode == .page ? scrollView.contentOffset.x : scrollView.contentOffset.x / currentScale)
    }
    
    func moveRowToPosition(_ tableView: STShadowTableView?, recognizer: UIGestureRecognizer) {
        guard let tableView = tableView, let _ = dataSource else { return }
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
        guard dataSource!.tableBoard(self, shouldMoveRowAt: sourceIndexPath, to: indexPath.convertToSTIndexPath(tableView.index)) else { return }
        if let lastMovingTime = lastMovingTime {
            guard Date().timeIntervalSince(lastMovingTime) > minimumMovingRowInterval else { return }
        }
        var destinationIndexPath: STIndexPath = indexPath.convertToSTIndexPath(tableView.index)
        dataSource!.tableBoard(self, moveRowAt: sourceIndexPath, to: &destinationIndexPath)
        let newIndexPath = destinationIndexPath.ConvertToIndexPath()
        if sourceIndexPath.board == tableView.index {
            tableView.beginUpdates()
            tableView.deleteRows(at: [sourceIndexPath.ConvertToIndexPath()], with: .fade)
            tableView.insertRows(at: [newIndexPath], with: .none)
            tableView.endUpdates()
            let cell = tableView.cellForRow(at: newIndexPath) as! STBoardCell
            cell.moving = true
        } else {
            let sourceTableView = boards[sourceIndexPath.board].tableView
            sourceTableView?.beginUpdates()
            sourceTableView?.deleteRows(at: [sourceIndexPath.ConvertToIndexPath()], with: .fade)
            sourceTableView?.endUpdates()
            rowDidBeRemovedFromTableView(sourceTableView!)
            tableView.beginUpdates()
            tableView.insertRows(at: [newIndexPath], with: .fade)
            tableView.endUpdates()
            rowDidBeInsertedIntoTableView(tableView)
            let cell = tableView.cellForRow(at: newIndexPath) as! STBoardCell
            cell.moving = true
        }
        sourceIndexPath = newIndexPath.convertToSTIndexPath(tableView.index)
        lastMovingTime = Date()
    }
    
    func updateSnapViewStatus(_ status: SnapViewStatus) {
        guard let snapshot = self.snapshot else {return}
        
        switch status {
        case .moving:
            let rotate = CGAffineTransform.identity.rotated(by: rotateAngel)
            let scale = CGAffineTransform.identity.scaledBy(x: 1.05, y: 1.05)
            snapshot.transform = scale.concatenating(rotate)
            snapshot.alpha = 0.95
        case .origin:
            snapshot.transform = CGAffineTransform.identity
            snapshot.alpha = 1.0
        }
        
    }
    
    func autoScrollInScrollView() {
        // caculate velocity
        func velocityByOffset(_ offset: CGFloat) -> CGFloat{
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
        
        guard let snapshot = self.snapshot else {return}
        let minX = snapshot.layer.presentation()!.frame.origin.x * currentScale
        let maxX = (snapshot.layer.presentation()!.frame.origin.x + snapshot.width) * currentScale
        let leftOffsetX = scrollView.presentContenOffset()!.x
        let rightOffsetX = scrollView.presentContenOffset()!.x  + scrollView.width
        
        // left scrolling
        if minX < leftOffsetX && leftOffsetX > 0 {
            let offset = leftOffsetX - minX
            let newVelocity = velocityByOffset(offset)
            if newVelocity == self.velocity {
                if isScrolling { return }
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
                    self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                    snapshot.center = CGPoint(x: self.snapshotOffsetForLeftBounds + self.scrollView.contentOffset.x / self.currentScale , y: snapshot.center.y)
                }, completion: nil)
        } else if maxX > rightOffsetX && rightOffsetX < scrollView.contentSize.width  {
            let offset = maxX - rightOffsetX
            let newVelocity = velocityByOffset(offset)
            if newVelocity == self.velocity {
                if isScrolling { return }
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
        guard let tableView = tableView else { return }
        
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
                guard let timer = tableViewAutoScrollTimer else { return }
                timer.invalidate()
                tableViewAutoScrollTimer = nil
            } else if tableViewAutoScrollTimer == nil {
                tableViewAutoScrollTimer = Timer.scheduledTimer(timeInterval: (1.0 / 60.0), target: self, selector: #selector(STTableBoard.tableViewAutoScrollTimerFired(_:)), userInfo: [timerUserInfoTableViewKey : tableView], repeats: true)
            }
        }
    }
    
    func optimizeTableViewScrollDistance(_ tableView: STShadowTableView) {
        let minumumDistance = tableView.contentOffset.y * -1
        let maximumDistance = tableView.contentSize.height - (tableView.frame.height + tableView.contentOffset.y)
        tableViewAutoScrollDistance = max(tableViewAutoScrollDistance, minumumDistance)
        tableViewAutoScrollDistance = min(tableViewAutoScrollDistance, maximumDistance)
    }
    
    func tableViewAutoScrollTimerFired(_ timer: Timer) {
        guard let userInfo = timer.userInfo as? [String:AnyObject], let tableView = userInfo[timerUserInfoTableViewKey] as? STShadowTableView else { return }
        optimizeTableViewScrollDistance(tableView)
        
        tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + tableViewAutoScrollDistance)
    }
    
    func rowDidBeRemovedFromTableView(_ tableView: STShadowTableView) {
        guard let board = tableView.superview as? STBoardView else { return }
        autoAdjustTableBoardHeight(board, animated: true)
    }
    
    func rowDidBeInsertedIntoTableView(_ tableView: STShadowTableView) {
        guard let board = tableView.superview as? STBoardView else { return }
        autoAdjustTableBoardHeight(board, animated: true)
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

//MARK: - board helper method
extension STTableBoard {
    func caculateBoardHeight(_ board: STBoardView) -> CGFloat {
        guard let tableView = board.tableView else { return 0.0 }
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        var tableViewContentHeight: CGFloat = headerViewHeight + board.footerViewHeightConstant
        if numberOfRows > 0 {
            for i in 0..<numberOfRows {
                tableViewContentHeight += self.tableView(tableView, heightForRowAt: IndexPath(row: i, section: 0))
            }
        }
        return tableViewContentHeight
    }
    
    func autoAdjustTableBoardHeight(_ board: STBoardView, animated: Bool) {
        let realBoardHeight = caculateBoardHeight(board)
        let newHeight = realBoardHeight < maxBoardHeight ? realBoardHeight : maxBoardHeight
        var frame = board.frame
        frame.size.height = newHeight
        if animated {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                board.frame = frame
                board.layoutIfNeeded()
            })
        } else {
            board.frame = frame
        }
    }
    
    func tableBoard(_ tableBoard: STTableBoard, moveBoardAtIndex sourceIndex:Int, toIndex destinationIndex:Int) {
        
        guard sourceIndex != destinationIndex , let dataSource = dataSource , dataSource.tableBoard(self, shouldMoveBoardAt: sourceIndex, to: destinationIndex) else { return }
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

//MARK: - Position helper method
extension STTableBoard {
    func boardAtPointInBoardArea(_ pointInContainerView: CGPoint) -> STBoardView? {
        var returnedBoard: STBoardView? = nil
        
        boards.forEach { (board) -> () in
            if pointInContainerView.x > board.minX && pointInContainerView.x < board.maxX {
                returnedBoard = board
            }
        }
        
        return returnedBoard
    }
    
    func boardAtPoint(_ pointInContainerView: CGPoint) -> STBoardView? {
        var returnedBoard: STBoardView? = nil
        
        boards.forEach { (board) -> () in
            if board.frame.contains(pointInContainerView) {
                returnedBoard = board
            }
        }
        
        return returnedBoard
    }
    
    func tableViewAtPoint(_ pointInContainerView: CGPoint) -> STShadowTableView? {
        guard let board = boardAtPoint(pointInContainerView) else { return nil }
        return board.tableView
    }
    
    func caculatePointOffset(originViewCenter: CGPoint, position: CGPoint, fromView: UIView) -> CGPoint{
        var convertedOriginViewCenter = originViewCenter
        var convertedPosition = position
        if fromView != containerView {
            convertedOriginViewCenter = containerView.convert(originViewCenter, from: fromView)
            convertedPosition = containerView.convert(position, from: fromView)
        }
        return CGPoint(x: convertedPosition.x - convertedOriginViewCenter.x, y: convertedPosition.y - convertedOriginViewCenter.y)
    }
    
    func caculateSnapShot(_ position: CGPoint) -> CGPoint{
        return CGPoint(x: position.x - snapshotCenterOffset.x, y: position.y - snapshotCenterOffset.y)
    }
    
    func snapshotBottomRightPoint() -> CGPoint {
        guard let snapshot = snapshot else { return CGPoint(x: 0, y: 0) }
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
        guard let snapshot = snapshot else { return CGPoint(x: 0, y: 0) }
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
        guard pointX > leading else { return 0 }
        let page = Int(ceilf(Float((pointX - leading) / (scrollView.width - leading - pageSpacing))))
        return page
    }
    
    func boardMenuFrameBelowMenuButton(_ button: UIButton) -> CGRect {
        let buttonFrameInView = view.convert(button.frame, from: button.superview)
        var frame: CGRect = CGRect.zero
        let height: CGFloat = 144.0
        let width: CGFloat = boardWidth + 60.0
        let verticalSpacing: CGFloat = 5.0
        switch (tableBoardMode, currentOrientation, currentDevice) {
        case (.page, _, _), (.scroll, .portrait, .phone):
            let y: CGFloat = buttonFrameInView.maxY + verticalSpacing
            let x: CGFloat = 0.0
            frame = CGRect(x: x, y: y, width: width, height: height)
        case (.scroll, _, _):
            let y: CGFloat = buttonFrameInView.maxY + verticalSpacing
            let boardMenuLeftToEdge = buttonFrameInView.minX + buttonFrameInView.width/2 - width / 2
            let boardMenuRightToEdge = view.width - (buttonFrameInView.maxX - buttonFrameInView.width / 2 + width / 2)
            var x: CGFloat = 0
            switch (boardMenuLeftToEdge, boardMenuRightToEdge) {
            case (_, _) where boardMenuLeftToEdge > boardmenuMaxSpacingToEdge && boardMenuRightToEdge > boardmenuMaxSpacingToEdge:
                x = boardMenuLeftToEdge
            case (_, _) where boardMenuLeftToEdge > boardmenuMaxSpacingToEdge && boardMenuRightToEdge <= boardmenuMaxSpacingToEdge:
                x = view.width - boardmenuMaxSpacingToEdge - width
            case (_, _) where boardMenuLeftToEdge <= boardmenuMaxSpacingToEdge:
                x = boardmenuMaxSpacingToEdge
            default:
                x = boardmenuMaxSpacingToEdge
            }
            frame = CGRect(x: x, y: y, width: width, height: height)
        }
        return frame
    }
    
    func setBoardMenuPopoverFrameBelowMenuButton(_ button: UIButton) {
        let buttonFrameInView = view.convert(button.frame, from: button.superview)
        boardMenuPopover.center.x = buttonFrameInView.minX + buttonFrameInView.width / 2
        boardMenuPopover.center.y = boardMenu.view.frame.minY - boardMenuPopover.height / 2
        if view.width - boardMenu.view.frame.maxX == boardmenuMaxSpacingToEdge {
            let x = boardMenu.view.frame.maxX - boardMenuPopover.width
            if boardMenuPopover.frame.origin.x > x {
                boardMenuPopover.frame.origin.x = x
            }
        } else if boardMenu.view.frame.minX == boardmenuMaxSpacingToEdge && boardMenuPopover.frame.minX < boardmenuMaxSpacingToEdge {
            boardMenuPopover.frame.origin.x = boardmenuMaxSpacingToEdge
        }
    }
    
    func insertBoardAtIndex(_ index: Int, animation: Bool) {
        if animation {
            resetContentSize()
        }
        let x = leading + CGFloat(index) * (boardWidth + pageSpacing)
        let y = top
        let boardViewFrame = CGRect(x: x, y: y, width: boardWidth, height: maxBoardHeight)
        
        guard let showRefreshFooter = dataSource?.tableBoard(self, showRefreshFooterAt: index) else { return }
        let boardView: STBoardView = STBoardView(frame: boardViewFrame,showRefreshFooter: showRefreshFooter)
        boardView.headerView.addGestureRecognizer(self.longPressGestureForBoard)
        boardView.tableView.addGestureRecognizer(self.longPressGestureForCell)
        boardView.index = index
        boardView.tableBoard = self
        boardView.tableView.delegate = self
        boardView.tableView.dataSource = self
        boardView.delegate = self
        registerCellClasses.forEach({ (classAndIdentifier) -> () in
            boardView.tableView.register(classAndIdentifier.0, forCellReuseIdentifier: classAndIdentifier.1)
        })
        autoAdjustTableBoardHeight(boardView, animated: false)
//        boards.append(boardView)
        boards.insert(boardView, at: index)
        containerView.addSubview(boardView)
        
        guard let dataSource = dataSource, let boardTitle = dataSource.tableBoard(self, titleForBoardAt: index) else { return }
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

//MARK: - UITableView help method
extension STTableBoard {
    public func registerClasses(_ classAndIdentifier: [(AnyClass,String)]) {
        registerCellClasses = classAndIdentifier
    }
    
    public func dequeueReusableCellWithIdentifier(_ identifier: String, forIndexPath indexPath: STIndexPath) -> UITableViewCell {
        let row = indexPath.row
        guard let tableView = boards[indexPath.board].tableView else {
            return UITableViewCell()
        }
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: IndexPath(row: row, section: 0))
    }
}

//MARK: - IndexPath helper
extension IndexPath {
    func convertToSTIndexPath(_ board: Int) -> STIndexPath{
        return STIndexPath(forRow: self.row, inBoard: board)
    }
}

extension STIndexPath {
    func ConvertToIndexPath() -> IndexPath {
        return IndexPath(row: self.row, section: 0)
    }
}

//MARK: - Page method
extension STTableBoard {
    func scrollToActualPage(_ scrollView: UIScrollView, offsetX: CGFloat) {
        guard tableBoardMode == .page && currentOrientation == .portrait else { return }
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
        guard tableBoardMode == .page && currentOrientation == .portrait else { return }
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

//MARK: - BoardMenu method
extension STTableBoard {
    func showBoardMenu(_ button: UIButton, boardIndex: Int, boardTitle: String?) {
        let frame = boardMenuFrameBelowMenuButton(button)
        boardMenuShadowView.frame = frame
        view.addSubview(boardMenuShadowView)
        boardMenu.view.frame = frame
        boardMenu.boardIndex = boardIndex
        boardMenu.boardMenuTitle = boardTitle
        view.addSubview(boardMenuMaskView)
        self.addChildViewController(boardMenu)
        view.addSubview(boardMenu.view)
        boardMenu.didMove(toParentViewController: self)
        boardMenuVisible = true
        
        setBoardMenuPopoverFrameBelowMenuButton(button)
        view.addSubview(boardMenuPopover)
    }
    
    func hiddenBoardMenu() {
        boardMenuShadowView.removeFromSuperview()
        boardMenu.view.removeFromSuperview()
        boardMenu.removeFromParentViewController()
        boardMenuMaskView.removeFromSuperview()
        boardMenuPopover.removeFromSuperview()
        boardMenuVisible = false
    }
    
    func boardMenuMaskViewTapped(_ recognizer: UIGestureRecognizer) {
        hiddenBoardMenu()
    }

    func showEditBoardTitleAlert(_ boardIndex: Int, boardTitle: String?) {
        let alert = UIAlertController(title: localizedString["STTableBoard.BoardMenuTextViewController.Title"], message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: localizedString["STTableBoard.OK"], style: .destructive) { (action) in
            let textField = alert.textFields!.first!
            guard let text = textField.text , !text.isEmpty else { return }
            self.delegate?.tableBoard(self, boardTitleBeChangedTo: text, at: boardIndex)
            self.reloadBoardTitleAtIndex(boardIndex)
            self.addNotification()
        }
        let cancelAction = UIAlertAction(title: localizedString["STTableBoard.Cancel"], style: .cancel) { (action) in
            self.addNotification()
        }
        alert.addTextField { (textFiled) in
            textFiled.borderStyle = .none
            textFiled.text = boardTitle
            textFiled.becomeFirstResponder()
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        NotificationCenter.default.removeObserver(self)
        present(alert, animated: true, completion: nil)
    }

    func showDeleteBoardAlert(_ boardIndex: Int) {
        let alertController = UIAlertController(title: nil, message: localizedString["STTableBoard.DeleteBoard.Alert.Message"], preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: localizedString["STTableBoard.Delete"], style: .destructive, handler: { (action) -> Void in
            guard let delegate = self.delegate , delegate.tableBoard(self, willRemoveBoardAt: boardIndex) else { return }
            self.removeBoardAtIndex(boardIndex)
        })
        let cancelAction = UIAlertAction(title: localizedString["STTableBoard.Cancel"], style: .cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func showBoardMenuActionSheet(_ boardIndex: Int, boardTitle: String?) {
        let boardMenuActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: localizedString["STTableBoard.Cancel"], style: .cancel, handler: nil)
        let editBoardTitleAction = UIAlertAction(title: localizedString["STTableBoard.EditBoardNameCell.Title"], style: .default) { (action) in
            guard let canEditTitle = self.delegate?.tableBoard(self, canEditBoardTitleAt: boardIndex), canEditTitle else {
                return
            }
            self.showEditBoardTitleAlert(boardIndex, boardTitle: boardTitle)
        }
        let deleteBoardTitleAction = UIAlertAction(title: localizedString["STTableBoard.Delete"], style: .destructive) { (action) in
            self.showDeleteBoardAlert(boardIndex)
        }
        boardMenuActionSheet.addAction(editBoardTitleAction)
        boardMenuActionSheet.addAction(deleteBoardTitleAction)
        boardMenuActionSheet.addAction(cancelAction)
        present(boardMenuActionSheet, animated: true, completion: nil)
    }
}
