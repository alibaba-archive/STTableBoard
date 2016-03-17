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
    func handleDoubleTap(recognizer: UIGestureRecognizer) {
        tapPosition = recognizer.locationInView(containerView)
        switchMode()
    }

    func switchMode() {
        let newMode: STTableBoardMode = tableBoardMode == .Page ? .Scroll : .Page
        var newScale: CGFloat = 0.0
        switch newMode {
        case .Page:
            newScale = scaleForPage
            tableBoardMode = .Page
            currentScale = newScale
        case .Scroll:
            newScale = scaleForScroll
            tableBoardMode = .Scroll
            currentScale = newScale
        }
        scrollView.setZoomScale(newScale, animated: true)
    }
}

//MARK: - long press drag for board
extension STTableBoard {
    func handleLongPressGestureForBoard(recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            startMovingBoard(recognizer)
        case .Changed:
            guard let _ = snapshot else { return }
            let positionInContainerView = recognizer.locationInView(containerView)
            moveSnapshotToPosition(positionInContainerView)
            autoScrollInScrollView()
            moveBoardToPosition(positionInContainerView)
        default:
            guard let _ = snapshot else { return }
            endMovingBoard()
        }
        
    }
    
    func startMovingBoard(recognizer: UIGestureRecognizer) {
        let positionInContainerView = recognizer.locationInView(containerView)
        guard let board = boardAtPoint(positionInContainerView), let dataSource = self.dataSource where dataSource.tableBoard(self, canMoveBoardAtIndex: board.index) else { return }
        if currentDevice == .Phone && tableBoardMode == .Page {
            switchMode()
            isMoveBoardFromPageMode = true
        }
        snapshot = board.snapshot
        snapshot.center = board.center
        containerView.addSubview(snapshot)
        updateSnapViewStatus(.Origin)
        snapshotCenterOffset = caculatePointOffset(originViewCenter: board.center, position: positionInContainerView, fromView: containerView)
        
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.updateSnapViewStatus(.Moving)
            board.moving = true
            }, completion: nil)
        sourceIndex = board.index
        originIndex = board.index
    }
    
    func endMovingBoard() {
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
            dataSource?.tableBoard(self, didEndMoveBoardAtOriginIndex: originIndex, toIndex: sourceIndex)
            sourceIndex = -1
            originIndex = -1
        }
        
        UIView.animateWithDuration(0.33, animations: { [unowned self]() -> Void in
//            self.snapshot.frame = board.frame
            self.snapshot.center = board.center
            self.updateSnapViewStatus(.Origin)
            }) { [unowned self](finished) -> Void in
                board.moving = false
                self.snapshot.removeFromSuperview()
                self.snapshot = nil
                resetBoard()
        }
    }
    
    func moveBoardToPosition(positionInContainerView: CGPoint) {
        let realPointX = isScrolling ? scrollView.presentContenOffset()!.x / currentScale + snapshotOffsetForLeftBounds + snapshotCenterOffset.x: positionInContainerView.x
        
        guard let destinationBoard = boardAtPointInBoardArea(CGPoint(x: realPointX, y: positionInContainerView.y)) else { return }
        
        
        tableBoard(self, moveBoardAtIndex: sourceIndex, toIndex: destinationBoard.index)
    }
}

//MARK: - long press drag for cell
extension STTableBoard {
    func handleLongPressGestureForCell(recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            startMovingRow(recognizer)
        case .Changed:
            // move snapShot
            guard let _ = snapshot else { return }
            let positionInContainerView = recognizer.locationInView(containerView)
            let realPointX = isScrolling ? scrollView.presentContenOffset()!.x / currentScale + snapshotOffsetForLeftBounds + snapshotCenterOffset.x: positionInContainerView.x
            let tableView = tableViewAtPoint(CGPoint(x: realPointX, y: positionInContainerView.y))
            moveSnapshotToPosition(positionInContainerView)
            autoScrollInScrollView()
            autoScrollInTableView(tableView)
            moveRowToPosition(tableView, recognizer: recognizer)
        default:
            guard let _ = snapshot else { return }
            endMovingRow()
        }
    }

    func startMovingRow(recognizer: UIGestureRecognizer) {
        guard let tableView = tableViewAtPoint(recognizer.locationInView(containerView)) else { return }
        let positionInTableView = recognizer.locationInView(tableView)
        guard let indexPath = tableView.indexPathForRowAtPoint(positionInTableView), cell = tableView.cellForRowAtIndexPath(indexPath) as? STBoardCell else {return}
        guard let dataSource = self.dataSource where dataSource.tableBoard(self, canMoveRowAtIndexPath: indexPath.convertToSTIndexPath(tableView.index)) else { return }
        snapshot = cell.snapshot
        updateSnapViewStatus(.Origin)
        snapshot.center = containerView.convertPoint(cell.center, fromView: tableView)
        containerView.addSubview(snapshot)
        snapshotCenterOffset = caculatePointOffset(originViewCenter: cell.center, position: positionInTableView, fromView: tableView)
        UIView.animateWithDuration(0.33, animations: { [unowned self]() -> Void in
            self.updateSnapViewStatus(.Moving)
            cell.moving = true
            }, completion:nil)
        sourceIndexPath = STIndexPath(forRow: indexPath.row, inBoard: tableView.index)
        originIndexPath = STIndexPath(forRow: indexPath.row, inBoard: tableView.index)
    }

    func endMovingRow() {
        let sourceTableView = boards[sourceIndexPath.board].tableView
        guard let cell = sourceTableView.cellForRowAtIndexPath(sourceIndexPath.convertToNSIndexPath()) as? STBoardCell else {return}
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.snapshot.center = self.containerView.convertPoint(cell.center, fromView: sourceTableView)
            self.updateSnapViewStatus(.Origin)
            }, completion: { [unowned self](finished) -> Void in
                cell.moving = false
                self.snapshot.removeFromSuperview()
                self.snapshot = nil
                self.dataSource?.tableBoard(self, didEndMoveRowAtOriginIndexPath: self.originIndexPath, toIndexPath: self.sourceIndexPath)
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
    }
    
    func moveSnapshotToPosition(position: CGPoint) {
        snapshot.center = caculateSnapShot(position)
        snapshotOffsetForLeftBounds = snapshot.center.x - (tableBoardMode == .Page ? scrollView.contentOffset.x : scrollView.contentOffset.x / currentScale)
    }
    
    func moveRowToPosition(tableView: STShadowTableView?, recognizer: UIGestureRecognizer) {
        guard let tableView = tableView, dataSource = dataSource else { return }
        
        func moveRowToIndexPath(indexPath: NSIndexPath) {
            guard dataSource.tableBoard(self, shouldMoveRowAtIndexPath: sourceIndexPath, toIndexPath: indexPath.convertToSTIndexPath(tableView.index)) else { return }
            if let lastMovingTime = lastMovingTime {
                guard NSDate().timeIntervalSinceDate(lastMovingTime) > minimumMovingRowInterval else { return }
            }
            dataSource.tableBoard(self, moveRowAtIndexPath: sourceIndexPath, toIndexPath: indexPath.convertToSTIndexPath(tableView.index))
            if sourceIndexPath.board == tableView.index {
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([sourceIndexPath.convertToNSIndexPath()], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                tableView.endUpdates()
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! STBoardCell
                cell.moving = true
            } else {
                let sourceTableView = boards[sourceIndexPath.board].tableView
                sourceTableView.beginUpdates()
                sourceTableView.deleteRowsAtIndexPaths([sourceIndexPath.convertToNSIndexPath()], withRowAnimation: .Fade)
                sourceTableView.endUpdates()
                rowDidBeRemovedFromTableView(sourceTableView)
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.endUpdates()
                rowDidBeInsertedIntoTableView(tableView)
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! STBoardCell
                cell.moving = true
            }
            sourceIndexPath = indexPath.convertToSTIndexPath(tableView.index)
            lastMovingTime = NSDate()
        }
        
        let positionInTableView = recognizer.locationInView(tableView)
        
        if tableView.height == 0.0 {
           let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            moveRowToIndexPath(indexPath)
        } else {
            var realPoint = positionInTableView
            switch (isScrolling, scrollDirection) {
            case (true, ScrollDirection.Left):
                realPoint = CGPoint(x: positionInTableView.x + scrollView.presentContenOffset()!.x / currentScale, y: positionInTableView.y)
            case (true, ScrollDirection.Right):
                realPoint = CGPoint(x: positionInTableView.x - (scrollView.contentOffset.x - scrollView.presentContenOffset()!.x) / currentScale, y: positionInTableView.y)
            default:
                break
            }
            
            if let indexPath = tableView.indexPathForRowAtPoint(realPoint) {
                moveRowToIndexPath(indexPath)
            }
        }
    }
    
    func updateSnapViewStatus(status: SnapViewStatus) {
        guard let snapshot = self.snapshot else {return}
        
        switch status {
        case .Moving:
            let rotate = CGAffineTransformRotate(CGAffineTransformIdentity,rotateAngel)
            let scale = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05)
            snapshot.transform = CGAffineTransformConcat(scale, rotate)
            snapshot.alpha = 0.95
        case .Origin:
            snapshot.transform = CGAffineTransformIdentity
            snapshot.alpha = 1.0
        }
        
    }
    
    func autoScrollInScrollView() {
        // caculate velocity
        func velocityByOffset(offset: CGFloat) -> CGFloat{
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
        let minX = snapshot.layer.presentationLayer()!.frame.origin.x * currentScale
        let maxX = (snapshot.layer.presentationLayer()!.frame.origin.x + snapshot.width) * currentScale
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
            scrollDirection = .Left
            let duration = Double(leftOffsetX / self.velocity)
            UIView.animateWithDuration(duration, delay: 0.0,
                options: [.BeginFromCurrentState, .AllowUserInteraction, .CurveLinear],
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
            scrollDirection = .Right
            let scrollViewContentWidth = scrollView.contentSize.width
            let duration = Double((scrollViewContentWidth - rightOffsetX) / self.velocity)
            UIView.animateWithDuration(duration, delay: 0.0,
                options: [.BeginFromCurrentState, .AllowUserInteraction, .CurveLinear],
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
    
    func autoScrollInTableView(tableView: STShadowTableView?) {
        guard let tableView = tableView else { return }
        
        func canTableViewScroll() -> Bool {
            return tableView.height < tableView.contentSize.height
        }
        
        func caculateScrollDistanceForTableView() {
            let convertedTopLeftPoint = tableView.superview!.convertPoint(snapshotTopLeftPoint(), fromView: containerView)
            let convertedBootomRightPoint = tableView.superview!.convertPoint(snapshotBottomRightPoint(), fromView: containerView)
            let distanceToTopEdge = convertedTopLeftPoint.y - CGRectGetMinY(tableView.frame)
            let distanceToBottomEdge = CGRectGetMaxY(tableView.frame) - convertedBootomRightPoint.y
            
            if distanceToTopEdge < 0 {
                tableViewAutoScrollDistance = CGFloat(ceilf(Float(distanceToTopEdge / 5.0)))
            } else if distanceToBottomEdge < 0 {
                tableViewAutoScrollDistance = CGFloat(ceilf(Float(distanceToBottomEdge / 5.0))) * -1
            }
        }
        
        let convertedSnapshotRectInBoard = tableView.superview!.convertRect(snapshot.layer.presentationLayer()!.frame, fromView: containerView)
        if canTableViewScroll() && CGRectIntersectsRect(tableView.frame, convertedSnapshotRectInBoard) {
            caculateScrollDistanceForTableView()
            
            if tableViewAutoScrollDistance == 0 {
                guard let timer = tableViewAutoScrollTimer else { return }
                timer.invalidate()
                tableViewAutoScrollTimer = nil
            } else if tableViewAutoScrollTimer == nil {
                tableViewAutoScrollTimer = NSTimer.scheduledTimerWithTimeInterval((1.0 / 60.0), target: self, selector: "tableViewAutoScrollTimerFired:", userInfo: [timerUserInfoTableViewKey : tableView], repeats: true)
            }
        }
    }
    
    func optimizeTableViewScrollDistance(tableView: STShadowTableView) {
        let minumumDistance = tableView.contentOffset.y * -1
        let maximumDistance = tableView.contentSize.height - (CGRectGetHeight(tableView.frame) + tableView.contentOffset.y)
        tableViewAutoScrollDistance = max(tableViewAutoScrollDistance, minumumDistance)
        tableViewAutoScrollDistance = min(tableViewAutoScrollDistance, maximumDistance)
    }
    
    func tableViewAutoScrollTimerFired(timer: NSTimer) {
        guard let userInfo = timer.userInfo as? [String:AnyObject], let tableView = userInfo[timerUserInfoTableViewKey] as? STShadowTableView else { return }
        optimizeTableViewScrollDistance(tableView)
        
        tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + tableViewAutoScrollDistance)
    }
    
    func rowDidBeRemovedFromTableView(tableView: STShadowTableView) {
        guard let board = tableView.superview as? STBoardView else { return }
        autoAdjustTableBoardHeight(board, animated: true)
    }
    
    func rowDidBeInsertedIntoTableView(tableView: STShadowTableView) {
        guard let board = tableView.superview as? STBoardView else { return }
        autoAdjustTableBoardHeight(board, animated: true)
    }
    
    // stop the scrollView animation
    func stopAnimation() {
        CATransaction.begin()
        scrollView.layer.removeAllAnimations()
        snapshot.layer.removeAllAnimations()
        CATransaction.commit()
        scrollView.setContentOffset(CGPoint(x: scrollView.layer.presentationLayer()!.bounds.origin.x, y: 0), animated: false)
        snapshot.center = CGPoint(x: self.snapshotOffsetForLeftBounds + scrollView.presentContenOffset()!.x / currentScale, y: snapshot.center.y)
        isScrolling = false
        scrollDirection = .None
        
    }
}

//MARK: - board helper method
extension STTableBoard {
    func caculateBoardHeight(board: STBoardView) -> CGFloat {
        guard let tableView = board.tableView else { return 0.0 }
        let numberOfRows = tableView.numberOfRowsInSection(0)
        var tableViewContentHeight: CGFloat = headerViewHeight + footerViewHeight
        if numberOfRows > 0 {
            for i in 0..<numberOfRows {
                tableViewContentHeight += self.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: i, inSection: 0))
            }
        }
        return tableViewContentHeight
    }
    
    func autoAdjustTableBoardHeight(board: STBoardView, animated: Bool) {
        let realBoardHeight = caculateBoardHeight(board)
        let newHeight = realBoardHeight < maxBoardHeight ? realBoardHeight : maxBoardHeight
        var frame = board.frame
        frame.size.height = newHeight
        if animated {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                board.frame = frame
                board.layoutIfNeeded()
            })
        } else {
            board.frame = frame
        }
    }
    
    func tableBoard(tableBoard: STTableBoard, moveBoardAtIndex sourceIndex:Int, toIndex destinationIndex:Int) {
        
        guard sourceIndex != destinationIndex , let dataSource = dataSource else { return }
        dataSource.tableBoard(self, moveBoardAtIndex: sourceIndex, toIndex: destinationIndex)
        
        let sourceBoard = boards[sourceIndex]
        let destinationBoard = boards[destinationIndex]
        self.boards[sourceIndex] = destinationBoard
        self.boards[destinationIndex] = sourceBoard
        (sourceBoard.index, destinationBoard.index) = (destinationBoard.index, sourceBoard.index)
        self.sourceIndex = destinationIndex
        
        let destinationOrigin = destinationBoard.frame.origin
        let sourceOrigin = sourceBoard.frame.origin
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            sourceBoard.frame = CGRect(origin: destinationOrigin, size: sourceBoard.bounds.size)
            destinationBoard.frame = CGRect(origin: sourceOrigin, size: destinationBoard.bounds.size)
            }, completion: nil)
    }
    
    func showTextComposeView() {
        textComposeView.textField.becomeFirstResponder()
        textComposeView.textField.text = nil
        textComposeView.alpha = 1.0
        newBoardButtonView.alpha = 0.0
        UIView.animateWithDuration(0.2) { () -> Void in
            self.textComposeView.frame.size.height = newBoardComposeViewHeight
        }
    }
    
    func hiddenTextComposeView() {
        self.textComposeView.textField.text = nil
        self.newBoardButtonView.alpha = 1.0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.textComposeView.alpha = 0.0
            self.textComposeView.frame.size.height = newBoardButtonViewHeight
            })
    }
}

//MARK: - Position helper method
extension STTableBoard {
    func boardAtPointInBoardArea(pointInContainerView: CGPoint) -> STBoardView? {
        var returnedBoard: STBoardView? = nil
        
        boards.forEach { (board) -> () in
            if pointInContainerView.x > board.minX && pointInContainerView.x < board.maxX {
                returnedBoard = board
            }
        }
        
        return returnedBoard
    }
    
    func boardAtPoint(pointInContainerView: CGPoint) -> STBoardView? {
        var returnedBoard: STBoardView? = nil
        
        boards.forEach { (board) -> () in
            if CGRectContainsPoint(board.frame, pointInContainerView) {
                returnedBoard = board
            }
        }
        
        return returnedBoard
    }
    
    func tableViewAtPoint(pointInContainerView: CGPoint) -> STShadowTableView? {
        guard let board = boardAtPoint(pointInContainerView) else { return nil }
        return board.tableView
    }
    
    func caculatePointOffset(originViewCenter originViewCenter: CGPoint, position: CGPoint, fromView: UIView) -> CGPoint{
        var convertedOriginViewCenter = originViewCenter
        var convertedPosition = position
        if fromView != containerView {
            convertedOriginViewCenter = containerView.convertPoint(originViewCenter, fromView: fromView)
            convertedPosition = containerView.convertPoint(position, fromView: fromView)
        }
        return CGPoint(x: convertedPosition.x - convertedOriginViewCenter.x, y: convertedPosition.y - convertedOriginViewCenter.y)
    }
    
    func caculateSnapShot(position: CGPoint) -> CGPoint{
        return CGPoint(x: position.x - snapshotCenterOffset.x, y: position.y - snapshotCenterOffset.y)
    }
    
    func snapshotBottomRightPoint() -> CGPoint {
        guard let snapshot = snapshot else { return CGPoint(x: 0, y: 0) }
        let width = snapshot.width * 1.05
        let height = snapshot.height * 1.05
        let tanAngle = snapshot.height / snapshot.width
        let angle = atan(tanAngle) + rotateAngel
        let radius = sqrt(width * width + height * height) / 2
        let positionX = snapshot.layer.presentationLayer()!.position.x + radius * cos(angle)
        let positionY = snapshot.layer.presentationLayer()!.position.y + radius * sin(angle)
        return CGPoint(x: positionX, y: positionY)
    }
    
    func snapshotTopLeftPoint() -> CGPoint {
        guard let snapshot = snapshot else { return CGPoint(x: 0, y: 0) }
        let width = snapshot.width * 1.05
        let height = snapshot.height * 1.05
        let tanAngle = snapshot.height / snapshot.width
        let angle = atan(tanAngle) + rotateAngel
        let radius = sqrt(width * width + height * height) / 2
        let positionX = snapshot.layer.presentationLayer()!.position.x - radius * cos(angle)
        let positionY = snapshot.layer.presentationLayer()!.position.y - radius * sin(angle)
        return CGPoint(x: positionX, y: positionY)
    }
    
    func pageAtPoint(pointInContainerView: CGPoint) -> Int {
        let pointX = pointInContainerView.x
        guard pointX > leading else { return 0 }
        let page = Int(ceilf(Float((pointX - leading) / (scrollView.width - leading - pageSpacing))))
        return page
    }
    
    func boardMenuFrameBelowMenuButton(button: UIButton) -> CGRect {
        let buttonFrameInView = view.convertRect(button.frame, fromView: button.superview)
        var frame: CGRect = CGRect.zero
        let height: CGFloat = 144.0
        let width: CGFloat = boardWidth + 60.0
        let verticalSpacing: CGFloat = 5.0
        switch (tableBoardMode, currentOrientation, currentDevice) {
        case (.Page, _, _), (.Scroll, .Portrait, .Phone):
            let y: CGFloat = CGRectGetMaxY(buttonFrameInView) + verticalSpacing
            let x: CGFloat = 0.0
            frame = CGRect(x: x, y: y, width: width, height: height)
        case (.Scroll, _, _):
            let y: CGFloat = CGRectGetMaxY(buttonFrameInView) + verticalSpacing
            let boardMenuLeftToEdge = CGRectGetMinX(buttonFrameInView) + CGRectGetWidth(buttonFrameInView)/2 - width / 2
            let boardMenuRightToEdge = view.width - (CGRectGetMaxX(buttonFrameInView) - CGRectGetWidth(buttonFrameInView) / 2 + width / 2)
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
    
    func setBoardMenuPopoverFrameBelowMenuButton(button: UIButton) {
        let buttonFrameInView = view.convertRect(button.frame, fromView: button.superview)
        boardMenuPopover.center.x = CGRectGetMinX(buttonFrameInView) + buttonFrameInView.width / 2
        boardMenuPopover.center.y = CGRectGetMinY(boardMenu.view.frame) - boardMenuPopover.height / 2
        if view.width - CGRectGetMaxX(boardMenu.view.frame) == boardmenuMaxSpacingToEdge {
            let x = CGRectGetMaxX(boardMenu.view.frame) - boardMenuPopover.width
            if boardMenuPopover.frame.origin.x > x {
                boardMenuPopover.frame.origin.x = x
            }
        } else if CGRectGetMinX(boardMenu.view.frame) == boardmenuMaxSpacingToEdge && CGRectGetMinX(boardMenuPopover.frame) < boardmenuMaxSpacingToEdge {
            boardMenuPopover.frame.origin.x = boardmenuMaxSpacingToEdge
        }
    }
    
    func insertBoardAtIndex(index: Int, animation: Bool) {
        if animation {
            resetContentSize()
        }
        let x = leading + CGFloat(index) * (boardWidth + pageSpacing)
        let y = top
        let boardViewFrame = CGRect(x: x, y: y, width: boardWidth, height: maxBoardHeight)
        
        let boardView: STBoardView = STBoardView(frame: boardViewFrame)
        boardView.headerView.addGestureRecognizer(self.longPressGestureForBoard)
        boardView.tableView.addGestureRecognizer(self.longPressGestureForCell)
        boardView.index = index
        boardView.tableBoard = self
        boardView.tableView.delegate = self
        boardView.tableView.dataSource = self
        boardView.delegate = self
        registerCellClasses.forEach({ (classAndIdentifier) -> () in
            boardView.tableView.registerClass(classAndIdentifier.0, forCellReuseIdentifier: classAndIdentifier.1)
        })
        autoAdjustTableBoardHeight(boardView, animated: false)
        boards.append(boardView)
        containerView.addSubview(boardView)
        
        guard let dataSource = dataSource, let boardTitle = dataSource.tableBoard(self, titleForBoardInBoard: index) else { return }
        boardView.title = boardTitle
        if animation {
            boardView.alpha = 0
            UIView.animateWithDuration(0.5) { () -> Void in
                boardView.alpha = 1.0
            }
        }
        
        if showAddBoardButton && animation {
            let newFrame = CGRect(x: leading + CGFloat(numberOfPage - 1) * (boardWidth + pageSpacing), y: newBoardButtonView.minY, width: newBoardButtonView.width, height: newBoardButtonView.height)
            textComposeView.frame = newFrame
            UIView.animateWithDuration(0.5) { () -> Void in
                self.newBoardButtonView.frame = newFrame
            }
        }
    }
}

//MARK: - UITableView help method
extension STTableBoard {
    public func registerClasses(classAndIdentifier classAndIdentifier: [(AnyClass,String)]) {
        registerCellClasses = classAndIdentifier
    }
    
    public func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: STIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let tableView = boards[indexPath.board].tableView
        return tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: NSIndexPath(forRow: row, inSection: 0))
    }
}

//MARK: - IndexPath helper
extension NSIndexPath {
    func convertToSTIndexPath(board: Int) -> STIndexPath{
        return STIndexPath(forRow: self.row, inBoard: board)
    }
}

extension STIndexPath {
    func convertToNSIndexPath() -> NSIndexPath {
        return NSIndexPath(forRow: self.row, inSection: 0)
    }
}

//MARK: - Page method
extension STTableBoard {
    func scrollToActualPage(scrollView: UIScrollView, offsetX: CGFloat) {
        guard tableBoardMode == .Page && currentOrientation == .Portrait else { return }
        let pageOffset = CGRectGetWidth(scrollView.frame) - overlap
        let proportion = offsetX / pageOffset
        let page = Int(proportion)
        let actualPage = (offsetX - pageOffset * CGFloat(page)) > (pageOffset * 1 / 2) ?  page + 1 : page
        currentPage = actualPage
        
        UIView.animateWithDuration(0.33) { () -> Void in
            scrollView.contentOffset = CGPoint(x: pageOffset * CGFloat(actualPage), y: 0)
        }
    }
    
    func scrollToPage(scrollView: UIScrollView, page: Int, targetContentOffset: UnsafeMutablePointer<CGPoint>?) {
        guard tableBoardMode == .Page && currentOrientation == .Portrait else { return }
        let pageOffset = CGRectGetWidth(scrollView.frame) - overlap
        UIView.animateWithDuration(0.33) { () -> Void in
            scrollView.contentOffset = CGPoint(x: pageOffset * CGFloat(page), y: 0)
        }
        if let targetContentOffset = targetContentOffset {
            targetContentOffset.memory = CGPoint(x: pageOffset * CGFloat(page), y: 0)
        }
        currentPage = page
    }
}

//MARK: - BoardMenu method
extension STTableBoard {
    func showBoardMenu(button: UIButton, boardIndex: Int, boardTitle: String?) {
        let frame = boardMenuFrameBelowMenuButton(button)
        boardMenuShadowView.frame = frame
        view.addSubview(boardMenuShadowView)
        boardMenu.view.frame = frame
        boardMenu.boardIndex = boardIndex
        boardMenu.boardMenuTitle = boardTitle
        view.addSubview(boardMenuMaskView)
        self.addChildViewController(boardMenu)
        view.addSubview(boardMenu.view)
        boardMenu.didMoveToParentViewController(self)
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
    
    func boardMenuMaskViewTapped(recognizer: UIGestureRecognizer) {
        hiddenBoardMenu()
    }
}



