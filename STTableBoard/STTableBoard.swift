//
//  STTableBoard.swift
//  STTableBoard
//
//  Created by DangGu on 15/10/27.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit
import QuartzCore

let leading: CGFloat  = 30.0
let trailing: CGFloat = leading
let top: CGFloat = 20.0
let bottom: CGFloat = top
let pageSpacing: CGFloat = leading / 2
let overlap: CGFloat = pageSpacing * 3

class STTableBoard: UIViewController {
    
    weak var dataSource: STTableBoardDataSource?
    
    private var numberOfPage: Int {
        get {
            guard let page = self.dataSource?.numberOfBoardsInTableBoard(self) else { return 1 }
            return page
        }
    }
    private var currentPage: Int = 0
    private var boards: [STBoardView] = []
    private var registerCellClasses:[(AnyClass,String)] = []
    private var scrollView: UIScrollView!
    
    private var longPressGesture: UILongPressGestureRecognizer {
        get {
            let gesture = UILongPressGestureRecognizer(target: self, action: "handleLongPressGesuter:")
            return gesture
        }
    }
    
    private var snapshot: UIView!
    private var sourceIndexPath: STIndexPath!
    private var snapshotCenterOffset: CGPoint!
    private var snapshotOffsetForLeftBounds: CGFloat!
    private var isScrolling: Bool = false
    private var scrollDirection: ScrollDirection = .None
    private var velocity: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperty()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    private func setupProperty() {
        let contentViewWidth = view.width + (view.width - overlap) * CGFloat(numberOfPage - 1)
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: contentViewWidth, height: view.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false
        view.addSubview(scrollView)
    }
    
    private func reloadData() {
        let contentViewWidth = view.width + (view.width - overlap) * CGFloat(numberOfPage - 1)
        scrollView.contentSize = CGSize(width: contentViewWidth, height: view.height)
        
        if boards.count != 0 {
            boards.forEach({ (board) -> () in
                board.removeFromSuperview()
            })
            boards.removeAll()
        }
        
        for i in 0..<numberOfPage {
            let width = self.view.width - (leading + trailing)
            let height = self.view.height - (top + bottom)
            let x = leading + CGFloat(i) * (width + pageSpacing)
            let y = top
            let boardViewFrame = CGRectMake(x, y, width, height)
            
            let boardView: STBoardView = STBoardView(frame: boardViewFrame)
            boardView.addGestureRecognizer(self.longPressGesture)
            boardView.index = i
            boardView.tableView.delegate = self
            boardView.tableView.dataSource = self
            registerCellClasses.forEach({ (classAndIdentifier) -> () in
                boardView.tableView.registerClass(classAndIdentifier.0, forCellReuseIdentifier: classAndIdentifier.1)
            })
            boards.append(boardView)
        }
        
        boards.forEach { (cardView) -> () in
            scrollView.addSubview(cardView)
        }
    }
}

//MARK: - long press drag
extension STTableBoard {
    func handleLongPressGesuter(recognizer: UIGestureRecognizer) {
        
        switch recognizer.state {
        case .Began:
            guard let tableView = tableViewAtPoint(recognizer.locationInView(scrollView)) else { return }
            let positionInTableView = recognizer.locationInView(tableView)
            guard let indexPath = tableView.indexPathForRowAtPoint(positionInTableView), cell = tableView.cellForRowAtIndexPath(indexPath) as? STBoardCell else {return}
            snapshot = cell.snapshot
            updateSnapViewStatus(.Origin)
            snapshot.center = scrollView.convertPoint(cell.center, fromView: tableView)
            scrollView.addSubview(snapshot)
            snapshotCenterOffset = caculatePointOffset(cellCenter: cell.center, position: positionInTableView, fromView: tableView)
            UIView.animateWithDuration(0.33, animations: { [unowned self]() -> Void in
                self.updateSnapViewStatus(.Moving)
                cell.moving = true
                }, completion:nil)
            sourceIndexPath = STIndexPath(forRow: indexPath.row, inBoard: tableView.index)
        case .Changed:
            // move snapShot
            let positionInScrollView = recognizer.locationInView(scrollView)
            snapshot.center = caculateSnapShot(positionInScrollView)
            snapshotOffsetForLeftBounds = snapshot.center.x - scrollView.contentOffset.x
            
            scrollBySnapshot()
            //move row to newIndexPath
            
            let realPointX = isScrolling ? scrollView.presentContenOffset()!.x + snapshotOffsetForLeftBounds + snapshotCenterOffset.x: positionInScrollView.x
            
            guard let tableView = tableViewAtPoint(CGPoint(x: realPointX, y: positionInScrollView.y)) else { return }
            print("positionInScrollView.x \(positionInScrollView.x)")
            print("scrollView.presentContenOffset()!.x \(scrollView.presentContenOffset()!.x)")
            print("snapshotOffsetForLeftBounds \(snapshotOffsetForLeftBounds)")
            let positionInTableView = recognizer.locationInView(tableView)
            var realPoint = positionInTableView
            switch (isScrolling, scrollDirection) {
            case (true, ScrollDirection.Left):
                realPoint = CGPoint(x: positionInTableView.x + scrollView.presentContenOffset()!.x, y: positionInTableView.y)
            case (true, ScrollDirection.Right):
                realPoint = CGPoint(x: positionInTableView.x - (scrollView.contentOffset.x - scrollView.presentContenOffset()!.x), y: positionInTableView.y)
            default:
                break
            }
//            let realPoint = isScrolling ? CGPoint(x: positionInTableView.x + scrollView.presentContenOffset()!.x, y: positionInTableView.y) : positionInTableView
//            print("isScrolling : \(isScrolling)")
//            print("ScrollDirection : \(scrollDirection)")
            print("realPoint : \(realPoint)")
//            print("$$$$$$$$$$$$$$$$$$$$")
//            print("******************")
            if let indexPath = tableView.indexPathForRowAtPoint(realPoint), dataSource = dataSource {
                dataSource.tableBoard(tableBoard: self, moveRowAtIndexPath: sourceIndexPath, toIndexPath: indexPath.convertToSTIndexPath(tableView.index))
                if sourceIndexPath.board == tableView.index {
                    tableView.moveRowAtIndexPath(sourceIndexPath.convertToNSIndexPath(), toIndexPath: indexPath)
                } else {
                    let sourceTableView = boards[sourceIndexPath.board].tableView
                    sourceTableView.beginUpdates()
                    sourceTableView.deleteRowsAtIndexPaths([sourceIndexPath.convertToNSIndexPath()], withRowAnimation: .Automatic)
                    sourceTableView.endUpdates()
                    tableView.beginUpdates()
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    tableView.endUpdates()
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! STBoardCell
                    cell.moving = true
                }
                sourceIndexPath = indexPath.convertToSTIndexPath(tableView.index)
            }
        default:
            let sourceTableView = boards[sourceIndexPath.board].tableView
            guard let cell = sourceTableView.cellForRowAtIndexPath(sourceIndexPath.convertToNSIndexPath()) as? STBoardCell else {return}
            UIView.animateWithDuration(0.33, animations: { () -> Void in
                self.snapshot.center = self.scrollView.convertPoint(cell.center, fromView: sourceTableView)
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
            scrollToActualPage(scrollView, offsetX: scrollView.contentOffset.x)
        }
    }
    
    func updateSnapViewStatus(status: SnapViewStatus) {
        guard let snapshot = self.snapshot else {return}
        
        switch status {
        case .Moving:
            let rotate = CGAffineTransformRotate(CGAffineTransformIdentity,CGFloat(M_PI_4/8.0))
            let scale = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05)
            snapshot.transform = CGAffineTransformConcat(scale, rotate)
            snapshot.alpha = 0.95
        case .Origin:
            snapshot.transform = CGAffineTransformIdentity
            snapshot.alpha = 1.0
        }
        
    }
    
    func scrollBySnapshot() {
        // caculate velocity
        func velocityByOffset(offset: CGFloat) -> CGFloat{
            if offset >= 80 {
                return 400
            } else if offset >= 50 {
                return 200
            } else if offset >= 20 {
                return 100
            }
            return 50
        }
        

        
        guard let snapshot = self.snapshot else {return}

        let minX = snapshot.layer.presentationLayer()!.frame.origin.x
        let maxX = snapshot.layer.presentationLayer()!.frame.origin.x + CGRectGetWidth(snapshot.frame)
        
        let leftOffsetX = scrollView.presentContenOffset()!.x
        let rightOffsetX = scrollView.presentContenOffset()!.x + screenWidth
        
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
                    snapshot.center = CGPoint(x: self.snapshotOffsetForLeftBounds + self.scrollView.contentOffset.x, y: snapshot.center.y)
                }, completion: nil)
        } else if maxX > rightOffsetX && rightOffsetX < scrollView.contentSize.width {
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
                    self.scrollView.contentOffset = CGPoint(x: scrollViewContentWidth - screenWidth, y: 0)
                    snapshot.center = CGPoint(x: self.snapshotOffsetForLeftBounds + self.scrollView.contentOffset.x, y: snapshot.center.y)
                }, completion: nil)
        } else {
            if isScrolling {
                stopAnimation()
            }
        }
    }
    
    func caculatePointOffset(cellCenter cellCenter: CGPoint, position: CGPoint, fromView: UIView) -> CGPoint{
        let convertedCellCenter = scrollView.convertPoint(cellCenter, fromView: fromView)
        let convertedPosition = scrollView.convertPoint(position, fromView: fromView)
        return CGPoint(x: convertedPosition.x - convertedCellCenter.x, y: convertedPosition.y - convertedCellCenter.y)
    }
    
    func caculateSnapShot(position: CGPoint) -> CGPoint{
        return CGPoint(x: position.x - snapshotCenterOffset.x, y: position.y - snapshotCenterOffset.y)
    }
    
    // stop the scrollView animation
    func stopAnimation() {
        CATransaction.begin()
        scrollView.layer.removeAllAnimations()
        snapshot.layer.removeAllAnimations()
        CATransaction.commit()
        scrollView.setContentOffset(CGPoint(x: scrollView.layer.presentationLayer()!.bounds.origin.x, y: 0), animated: false)
        snapshot.center = CGPoint(x: self.snapshotOffsetForLeftBounds + scrollView.presentContenOffset()!.x, y: snapshot.center.y)
        isScrolling = false
        scrollDirection = .None
        
    }
}

//MARK: - Postiion helper 
extension STTableBoard {
    func boardAtPoint(pointInScrollView: CGPoint) -> STBoardView? {
        var returnedBoard:STBoardView? = nil
        
        boards.forEach { (board) -> () in
            if CGRectContainsPoint(board.frame, pointInScrollView) {
                returnedBoard = board
            }
        }
        print("$$$$$$$$$$$$$$$$$$$$")
        print("$$$$$$$$$$$$$$$$$$$$")
        print("$$$$$$$$$$$$$$$$$$$$")
        print("pointInScrollView : \(pointInScrollView)")
        print("isScrolling : \(isScrolling)")
        if returnedBoard != nil{
            print("index : \(returnedBoard!.index)")
        } else {
            print("index wtf nil")
        }
//        print("$$$$$$$$$$$$$$$$$$$$")
        
        return returnedBoard
    }
    
    func tableViewAtPoint(pointInScrollView: CGPoint) -> STShadowTableView? {
        guard let board = boardAtPoint(pointInScrollView) else { return nil }
        return board.tableView
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
    private func scrollToActualPage(scrollView: UIScrollView, offsetX: CGFloat) {
        let pageOffset = CGRectGetWidth(scrollView.frame) - overlap
        let proportion = offsetX / pageOffset
        let page = Int(proportion)
        let actualPage = (offsetX - pageOffset * CGFloat(page)) > (pageOffset * 3 / 4) ?  page + 1 : page
        currentPage = actualPage
        
        UIView.animateWithDuration(0.33) { () -> Void in
            scrollView.contentOffset = CGPoint(x: pageOffset * CGFloat(actualPage), y: 0)
        }
    }
    
    private func scrollToPage(scrollView: UIScrollView, page: Int, targetContentOffset: UnsafeMutablePointer<CGPoint>?) {
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

//MARK: - UIScrollViewDelegate
extension STTableBoard : UIScrollViewDelegate {
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToActualPage(scrollView, offsetX: scrollView.contentOffset.x)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x != 0 {
            if velocity.x < 0 && currentPage > 0{
                scrollToPage(scrollView, page: currentPage - 1, targetContentOffset: targetContentOffset)
            } else if velocity.x > 0 && currentPage < numberOfPage - 1{
                scrollToPage(scrollView, page: currentPage + 1, targetContentOffset: targetContentOffset)
            }
            
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        print("contentOffset : \(scrollView.contentOffset)")
    }
}

//MARK: - UITableViewDelegate
extension STTableBoard: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension STTableBoard: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let board = (tableView as! STShadowTableView).index, numberOfRows = dataSource?.tableBoard(tableBoard: self, numberOfRowsInBoard: board) else { return 0 }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let board = (tableView as! STShadowTableView).index, cell = dataSource?.tableBoard(tableBoard: self, cellForRowAtIndexPath: STIndexPath(forRow: indexPath.row, inBoard: board)) else { fatalError("board or cell can not be nill") }
        return cell
    }
}
