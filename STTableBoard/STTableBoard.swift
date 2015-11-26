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
    
    private func scrollToPage(scrollView: UIScrollView, page: Int, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageOffset = CGRectGetWidth(scrollView.frame) - overlap
        UIView.animateWithDuration(0.33) { () -> Void in
            scrollView.contentOffset = CGPoint(x: pageOffset * CGFloat(page), y: 0)
        }
        targetContentOffset.memory = CGPoint(x: pageOffset * CGFloat(page), y: 0)
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
