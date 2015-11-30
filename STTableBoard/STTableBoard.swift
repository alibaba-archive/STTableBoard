//
//  STTableBoard.swift
//  STTableBoard
//
//  Created by DangGu on 15/10/27.
//  Copyright © 2015年 Donggu. All rights reserved.
//



import UIKit

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
        let tableView = boards[currentPage].tableView
        
        switch recognizer.state {
        case .Began:
            let position = recognizer.locationInView(tableView)
            guard let indexPath = tableView.indexPathForRowAtPoint(position), cell = tableView.cellForRowAtIndexPath(indexPath) as? STBoardCell else {return}
            snapshot = cell.snapshot
            updateSnapViewStatus(.Origin)
            snapshot.center = scrollView.convertPoint(cell.center, fromView: tableView)
            scrollView.addSubview(snapshot)
            snapshotCenterOffset = caculatePointOffset(cellCenter: cell.center, position: position, fromView: tableView)
            UIView.animateWithDuration(0.33, animations: { [unowned self]() -> Void in
                self.updateSnapViewStatus(.Moving)
                cell.moving = true
                }, completion:nil)
            sourceIndexPath = STIndexPath(forRow: indexPath.row, inBoard: currentPage)
        case .Changed:
            let positionInScrollView = recognizer.locationInView(scrollView)
            let positionInTableView = recognizer.locationInView(tableView)
            snapshot.center = caculateSnapShot(positionInScrollView)
            snapshotOffsetForLeftBounds = snapshot.center.x - scrollView.contentOffset.x
            scrollBySnapshot()
            if let indexPath = tableView.indexPathForRowAtPoint(positionInTableView), dataSource = dataSource {
                dataSource.tableBoard(tableBoard: self, moveRowAtIndexPath: sourceIndexPath, toIndexPath: indexPath.convertToSTIndexPath(currentPage))
                tableView.moveRowAtIndexPath(sourceIndexPath.convertToNSIndexPath(), toIndexPath: indexPath)
                sourceIndexPath = indexPath.convertToSTIndexPath(currentPage)
            }
        default:
            guard let cell = tableView.cellForRowAtIndexPath(sourceIndexPath.convertToNSIndexPath()) as? STBoardCell else {return}
            UIView.animateWithDuration(0.33, animations: { () -> Void in
                self.snapshot.center = self.scrollView.convertPoint(cell.center, fromView: tableView)
                self.updateSnapViewStatus(.Origin)
                }, completion: { [unowned self](finished) -> Void in
                    cell.moving = false
                    self.snapshot.removeFromSuperview()
                    self.snapshot = nil
            })
            self.sourceIndexPath = nil
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
        guard let snapshot = self.snapshot else {return}

        let minX = snapshot.minX
        let maxX = snapshot.maxX
        
        let leftPage = pageWithXPoint(minX)
        let rightPage = pageWithXPoint(maxX)
        
        if leftPage != currentPage && self.scrollView.contentOffset.x >= 0{
            let contentOffSet = scrollView.contentOffset
            let velocity: CGFloat = 10
            let x = contentOffSet.x - velocity
//            self.scrollView.setContentOffset(CGPoint(x: x, y: contentOffSet.y), animated: true)
            
            UIView.animateWithDuration(2.0, animations: { () -> Void in
                self.scrollView.contentOffset = CGPoint(x: x, y: contentOffSet.y)
                snapshot.center = CGPoint(x: self.snapshotOffsetForLeftBounds + self.scrollView.contentOffset.x, y: snapshot.center.y)
                }, completion: nil)
        }
    }
    
    func pageWithXPoint(x: CGFloat) -> Int{
        let page = Int(x / (view.width - overlap))
        if page > numberOfPage {
            return numberOfPage
        } else if page < 0 {
            return 0
        } else {
            return page
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
        print("contentOffset : \(scrollView.contentOffset)")
//        guard let snapshot = snapshot else {return}
//        snapshot.center = CGPoint(x: snapshotOffsetForLeftBounds + scrollView.contentOffset.x, y: snapshot.center.y)
//        scrollBySnapshot()
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
