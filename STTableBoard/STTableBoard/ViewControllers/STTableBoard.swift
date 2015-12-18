//
//  STTableBoard.swift
//  STTableBoard
//
//  Created by DangGu on 15/10/27.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit

public class STTableBoard: UIViewController {
    
    var boardWidth: CGFloat {
        get {
            if currentDevice == .Pad {
                return self.customBoardWidth
            } else {
                var width: CGFloat = 0
                switch currentOrientation {
                case .Portrait:
                    width = self.view.width
                case .Landscape:
                    width = self.view.height
                }
                return width - (leading + trailing)
            }
        }
    }
    var maxBoardHeight: CGFloat {
        get {
            return self.containerView.height - (top + bottom)
        }
    }

    var numberOfPage: Int {
        get {
            guard let page = self.dataSource?.numberOfBoardsInTableBoard(self) else { return 1 }
            return page
        }
    }
    
    var longPressGestureForCell: UILongPressGestureRecognizer {
        get {
            let gesture = UILongPressGestureRecognizer(target: self, action: "handleLongPressGestureForCell:")
            return gesture
        }
    }
    
    var longPressGestureForBoard: UILongPressGestureRecognizer {
        get {
            let gesture = UILongPressGestureRecognizer(target: self, action: "handleLongPressGestureForBoard:")
            return gesture
        }
    }
    
    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        gesture.delegate = self
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    
    var contentViewWidth: CGFloat {
        get {
            return 2 * leading + CGFloat(numberOfPage) * boardWidth + CGFloat(numberOfPage - 1) * pageSpacing
        }
        
    }
    
    var currentPage: Int = 0
    var registerCellClasses:[(AnyClass, String)] = []
    var tableBoardMode: STTableBoardMode = .Page
    public var customBoardWidth: CGFloat = 280
    
    //Views Property
    var boards: [STBoardView] = []
    var scrollView: UIScrollView!
    var containerView: UIView!

    //Delegate Property
    public weak var dataSource: STTableBoardDataSource?
    public weak var delegate: STTableBoardDelegate?

    //Move Row Or Board Property
    var snapshot: UIView!
    var snapshotCenterOffset: CGPoint!
    var snapshotOffsetForLeftBounds: CGFloat!
    var sourceIndexPath: STIndexPath!
    var sourceIndex: Int = -1
    var isMoveBoardFromPageMode: Bool = false
    var lastMovingTime: NSDate!

    //ScrollView Auto Scroll property
    var isScrolling: Bool = false
    var scrollDirection: ScrollDirection = .None
    var velocity: CGFloat = defaultScrollViewScrollVelocity

    //TableView Auto Scroll Property
    var tableViewAutoScrollTimer: NSTimer?
    var tableViewAutoScrollDistance: CGFloat = 0

    //Zoom Property
    var originContentOffset = CGPoint(x: 0, y: 0)
    var originContentSize = CGSize(width: 0, height: 0)
    var scaledContentOffset = CGPoint(x: 0, y: 0)
    var currentScale: CGFloat = scaleForPage
    var tapPosition: CGPoint = CGPoint(x: 0, y: 0)

    //MARK: - life cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupProperty()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.pinchGestureRecognizer?.enabled = false
    }

    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    //MARK: - init helper
    private func setupProperty() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = scaleForScroll
        scrollView.maximumZoomScale = scaleForPage
        scrollView.delegate = self
        scrollView.bounces = false
        view.addSubview(scrollView)

        containerView = UIView(frame: CGRect(origin: CGPointZero, size: scrollView.contentSize))
        scrollView.addSubview(containerView)
        containerView.backgroundColor = tableBoardBackgroundColor
        scrollView.backgroundColor = tableBoardBackgroundColor

        if currentDevice == .Pad {
            tableBoardMode = .Scroll
        } else if currentDevice == .Phone {
            containerView.addGestureRecognizer(doubleTapGesture)
        }
    }

    public func reloadData() {
        scrollView.contentSize = CGSize(width: contentViewWidth, height: view.height)
        containerView.frame = CGRect(origin: CGPointZero, size: scrollView.contentSize)

        if boards.count != 0 {
            boards.forEach({ (board) -> () in
                board.removeFromSuperview()
            })
            boards.removeAll()
        }

        for i in 0..<numberOfPage {
            let x = leading + CGFloat(i) * (boardWidth + pageSpacing)
            let y = top
            let boardViewFrame = CGRect(x: x, y: y, width: boardWidth, height: maxBoardHeight)

            let boardView: STBoardView = STBoardView(frame: boardViewFrame)
            boardView.headerView.addGestureRecognizer(self.longPressGestureForBoard)
            boardView.tableView.addGestureRecognizer(self.longPressGestureForCell)
            boardView.index = i
            boardView.tableView.delegate = self
            boardView.tableView.dataSource = self
            registerCellClasses.forEach({ (classAndIdentifier) -> () in
                boardView.tableView.registerClass(classAndIdentifier.0, forCellReuseIdentifier: classAndIdentifier.1)
            })
            autoAdjustTableBoardHeight(boardView, animated: false)
            boards.append(boardView)
            
            guard let dataSource = dataSource, let boardTitle = dataSource.tableBoard(tableBoard: self, titleForBoardInBoard: i) else { return }
            boardView.title = boardTitle
            
        }

        boards.forEach { (cardView) -> () in
            containerView.addSubview(cardView)
        }
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ [unowned self](context) -> Void in
            self.relayoutAllViews(size)
            }) { [unowned self](contenxt) -> Void in
                switch (currentOrientation, currentDevice) {
                case (_, .Pad):
                    self.tableBoardMode = .Scroll
                case (.Landscape, _):
                    self.tableBoardMode = .Scroll
                case (.Portrait, _):
                    self.tableBoardMode = .Page
                }
                self.scrollToActualPage(self.scrollView, offsetX: self.scrollView.contentOffset.x)
        }
    }
    
    func relayoutAllViews(size: CGSize) {
        scrollView.frame = CGRect(origin: CGPointZero, size: size)
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: size.height)
        containerView.frame = CGRect(origin: CGPointZero, size: scrollView.contentSize)
        boards.forEach { (board) -> () in
            autoAdjustTableBoardHeight(board, animated: true)
        }
        originContentSize = CGSize(width: originContentSize.width, height: size.height)
    }
}
