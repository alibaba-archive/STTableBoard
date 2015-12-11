//
//  STTableBoardExtensions.swift
//  STTableBoard
//
//  Created by DangGu on 15/12/4.
//  Copyright © 2015年 Donggu. All rights reserved.
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
            currentScale = scaleForPage
        case .Scroll:
            newScale = scaleForScroll
            tableBoardMode = .Scroll
            currentScale = scaleForScroll
        }
        scrollView.setZoomScale(newScale, animated: true)
    }
}

//MARK: - long press drag
extension STTableBoard {
    func handleLongPressGesuter(recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            startMovingRow(recognizer)
        case .Changed:
            // move snapShot
            let positionInContainerView = recognizer.locationInView(containerView)
            let realPointX = isScrolling ? scrollView.presentContenOffset()!.x / currentScale + snapshotOffsetForLeftBounds + snapshotCenterOffset.x: positionInContainerView.x
            let tableView = tableViewAtPoint(CGPoint(x: realPointX, y: positionInContainerView.y))
            moveSnapshotToPosition(positionInContainerView)
            autoScrollInScrollView()
            autoScrollInTableView(tableView)
            moveRowToPosition(tableView, recognizer: recognizer)
        default:
            endMovingRow()
        }
    }

    func startMovingRow(recognizer: UIGestureRecognizer) {
        guard let tableView = tableViewAtPoint(recognizer.locationInView(containerView)) else { return }
        let positionInTableView = recognizer.locationInView(tableView)
        guard let indexPath = tableView.indexPathForRowAtPoint(positionInTableView),
            cell = tableView.cellForRowAtIndexPath(indexPath) as? STBoardCell else {return}
        snapshot = cell.snapshot
        updateSnapViewStatus(.Origin)
        snapshot.center = containerView.convertPoint(cell.center, fromView: tableView)
        containerView.addSubview(snapshot)
        snapshotCenterOffset = caculatePointOffset(cellCenter: cell.center, position: positionInTableView, fromView: tableView)
        UIView.animateWithDuration(0.33, animations: { [unowned self]() -> Void in
            self.updateSnapViewStatus(.Moving)
            cell.moving = true
            }, completion:nil)
        sourceIndexPath = STIndexPath(forRow: indexPath.row, inBoard: tableView.index)
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
            })
        self.sourceIndexPath = nil
        if isScrolling {
            stopAnimation()
        }
        if let timer = tableViewAutoScrollTimer {
            tableViewAutoScrollDistance = 0
            timer.invalidate()
            tableViewAutoScrollTimer = nil
        }
        scrollToActualPage(scrollView, offsetX: scrollView.contentOffset.x)
    }
    
    func moveSnapshotToPosition(position: CGPoint) {
        snapshot.center = caculateSnapShot(position)
        snapshotOffsetForLeftBounds = snapshot.center.x - (tableBoardMode == .Page ? scrollView.contentOffset.x : scrollView.contentOffset.x / currentScale)
    }
    
    func moveRowToPosition(tableView: STShadowTableView?, recognizer: UIGestureRecognizer) {
        guard let tableView = tableView else { return }
        
        let positionInTableView = recognizer.locationInView(tableView)
        var realPoint = positionInTableView
        switch (isScrolling, scrollDirection) {
        case (true, ScrollDirection.Left):
            realPoint = CGPoint(x: positionInTableView.x + scrollView.presentContenOffset()!.x / currentScale, y: positionInTableView.y)
        case (true, ScrollDirection.Right):
            realPoint = CGPoint(x: positionInTableView.x - (scrollView.contentOffset.x - scrollView.presentContenOffset()!.x) / currentScale, y: positionInTableView.y)
        default:
            break
        }
        
        if let indexPath = tableView.indexPathForRowAtPoint(realPoint), dataSource = dataSource {
            dataSource.tableBoard(tableBoard: self, moveRowAtIndexPath: sourceIndexPath, toIndexPath: indexPath.convertToSTIndexPath(tableView.index))
            if sourceIndexPath.board == tableView.index {
                tableView.moveRowAtIndexPath(sourceIndexPath.convertToNSIndexPath(), toIndexPath: indexPath)
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
        var tableViewContentHeight: CGFloat = 2 * headerFooterViewHeight
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
            })
        } else {
            board.frame = frame
        }
    }
}

//MARK: - Position helper method
extension STTableBoard {
    func boardAtPoint(pointInContainerView: CGPoint) -> STBoardView? {
        var returnedBoard:STBoardView? = nil
        
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
    
    func caculatePointOffset(cellCenter cellCenter: CGPoint, position: CGPoint, fromView: UIView) -> CGPoint{
        let convertedCellCenter = containerView.convertPoint(cellCenter, fromView: fromView)
        let convertedPosition = containerView.convertPoint(position, fromView: fromView)
        return CGPoint(x: convertedPosition.x - convertedCellCenter.x, y: convertedPosition.y - convertedCellCenter.y)
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
}


//MARK: - UITableView help method
extension STTableBoard {
    func registerClasses(classAndIdentifier classAndIdentifier: [(AnyClass,String)]) {
        registerCellClasses = classAndIdentifier
    }
    
    func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: STIndexPath) -> UITableViewCell {
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
        guard tableBoardMode == .Page else { return }
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
        guard tableBoardMode == .Page else { return }
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

extension STTableBoard: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
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
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard tableBoardMode == .Page else { return }
        if !decelerate {
            scrollToActualPage(scrollView, offsetX: scrollView.contentOffset.x)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard tableBoardMode == .Page else { return }
        if velocity.x != 0 {
            if velocity.x < 0 && currentPage > 0{
                scrollToPage(scrollView, page: currentPage - 1, targetContentOffset: targetContentOffset)
            } else if velocity.x > 0 && currentPage < numberOfPage - 1{
                scrollToPage(scrollView, page: currentPage + 1, targetContentOffset: targetContentOffset)
            }
            
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        switch tableBoardMode {
        case .Scroll:
            originContentOffset = scrollView.contentOffset
            originContentSize = scrollView.contentSize
        case .Page:
            scaledContentOffset = scrollView.contentOffset
        }
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
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
            scrollToPage(scrollView, page: pageAtPoint(tapPosition) - 1, targetContentOffset: nil)
        }
        containerView.frame = CGRect(origin: CGPointZero, size: scrollView.contentSize)
        boards.forEach { (board) -> () in
            autoAdjustTableBoardHeight(board, animated: true)
        }
    }
}

//MARK: - UITableViewDelegate
extension STTableBoard: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let board = (tableView as! STShadowTableView).index,
            heightForRow = delegate?.tableBoard(tableBoard: self, heightForRowAtIndexPath: STIndexPath(forRow: indexPath.row, inBoard: board)) else { return 44.0 }
        return heightForRow
    }
}

//MARK: - UITableViewDataSource
extension STTableBoard: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let board = (tableView as! STShadowTableView).index,
            numberOfRows = dataSource?.tableBoard(tableBoard: self, numberOfRowsInBoard: board) else { return 0 }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let board = (tableView as! STShadowTableView).index,
            cell = dataSource?.tableBoard(tableBoard: self, cellForRowAtIndexPath: STIndexPath(forRow: indexPath.row, inBoard: board)) as? STBoardCell else { fatalError("board or cell can not be nill") }
        cell.moving = false
        return cell
    }
}