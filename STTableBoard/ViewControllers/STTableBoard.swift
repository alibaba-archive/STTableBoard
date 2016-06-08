//
//  STTableBoard.swift
//  STTableBoard
//
//  Created by DangGu on 15/10/27.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit
import RefreshView

public class STTableBoard: UIViewController {
    
    public var boardWidth: CGFloat {
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

    public var showLoadingView: Bool = false {
        didSet {
            scrollView.showLoadingView = showLoadingView
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
            return page + (showAddBoardButton ? 1 : 0)
        }
    }
    
    var longPressGestureForCell: UILongPressGestureRecognizer {
        get {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(STTableBoard.handleLongPressGestureForCell(_:)))
            return gesture
        }
    }
    
    var longPressGestureForBoard: UILongPressGestureRecognizer {
        get {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(STTableBoard.handleLongPressGestureForBoard(_:)))
            return gesture
        }
    }
    
    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(STTableBoard.handleDoubleTap(_:)))
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
    
    lazy var newBoardButtonView: NewBoardButton = {
        let view = NewBoardButton(frame: CGRect.zero)
        view.image = UIImage(named: "icon_addBoard", inBundle: currentBundle, compatibleWithTraitCollection: nil)
        view.title = localizedString["STTableBoard.AddBoard"]
        view.delegate = self
        return view
    }()
    
    lazy var textComposeView: TextComposeView = {
        let view = TextComposeView(frame: CGRect.zero)
        view.delegate = self
        view.alpha = 0.0
        return view
    }()
    
    // BoardMenu Properties
    lazy var boardMenu: BoardMenu = {
        let menu = BoardMenu()
        menu.boardMenuDelegate = self
        return menu
    }()
    
    lazy var boardMenuMaskView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.clearColor()
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(STTableBoard.boardMenuMaskViewTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    lazy var boardMenuShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        let layer = view.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 30.0
        layer.cornerRadius = 6.0
        return view
    }()
    
    lazy var boardMenuPopover: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BoardMenu_Popover", inBundle: currentBundle, compatibleWithTraitCollection: nil))
        imageView.sizeToFit()
        return imageView
    }()
    
    public var contentInset: UIEdgeInsets = UIEdgeInsetsZero
    public var sizeOffset: CGSize = CGSize(width: 0, height: 0)
    public var keyboardInset: CGFloat = 0
    
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
    
    //Public Property
    public var showAddBoardButton: Bool = false

    //Move Row Or Board Property
    var snapshot: UIView!
    var snapshotCenterOffset: CGPoint!
    var snapshotOffsetForLeftBounds: CGFloat!
    var sourceIndexPath: STIndexPath!
    var originIndexPath: STIndexPath!
    var sourceIndex: Int = -1
    var originIndex: Int = -1
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
    var originFrame: CGRect!
    
    //Board Menu property 
    var boardMenuVisible: Bool = false
    
    //Text Compose property
    var boardViewForVisibleTextComposeView: STBoardView?
    var isAddBoardTextComposeViewVisible: Bool = false

    private var isFirstLoading: Bool = true

    //MARK: - life cycle

    public init(localizedStrings: [String: String]) {
        super.init(nibName: nil, bundle: nil)
        localizedString = localizedStrings
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupProperty()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstLoading {
            reloadData()
            isFirstLoading = false
        }
        addNotification()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.pinchGestureRecognizer?.enabled = false
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    //MARK: - init helper
    private func setupProperty() {
        view.frame = CGRect(x: contentInset.left, y: contentInset.top, width: view.width - (contentInset.left + contentInset.right + sizeOffset.width), height: view.height - (contentInset.top + contentInset.bottom + sizeOffset.height))
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = scaleForScroll
        scrollView.maximumZoomScale = scaleForPage
        scrollView.delegate = self
        scrollView.bounces = false
        view.addSubview(scrollView)

        containerView = UIView(frame: CGRect(origin: CGPoint.zero, size: scrollView.contentSize))
        scrollView.addSubview(containerView)
        containerView.backgroundColor = tableBoardBackgroundColor
        scrollView.backgroundColor = tableBoardBackgroundColor

        if currentDevice == .Pad {
            tableBoardMode = .Scroll
        } else if currentDevice == .Phone {
            tableBoardMode = .Page
            containerView.addGestureRecognizer(doubleTapGesture)
        }
    }

    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ [unowned self](context) -> Void in
            let newSize = CGSize(width: size.width - (self.contentInset.left + self.contentInset.right + self.sizeOffset.width), height: size.height - (self.contentInset.top + self.contentInset.bottom + self.sizeOffset.height))
//            print("newSize :\(newSize)")
            self.relayoutAllViews(newSize, hideBoardMenu: true)
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
    
    func relayoutAllViews(size: CGSize, hideBoardMenu: Bool) {
        scrollView.frame = CGRect(origin: CGPoint.zero, size: size)
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: size.height)
        containerView.frame = CGRect(origin: CGPoint.zero, size: scrollView.contentSize)
//        print("********************")
//        print("scrollView.frame \(scrollView.frame)")
//        print("scrollView.contentSize \(scrollView.contentSize)")
//        print("containerView.frame \(containerView.frame)")
//        print("********************")
        boardMenuMaskView.frame = CGRect(origin: CGPoint.zero, size: size)
        boards.forEach { (board) -> () in
            autoAdjustTableBoardHeight(board, animated: true)
        }
        originContentSize = CGSize(width: originContentSize.width, height: size.height)
        
        if boardMenuVisible && hideBoardMenu {
            hiddenBoardMenu()
        }
    }
    
    func resetContentSize() {
        scrollView.contentSize = CGSize(width: contentViewWidth, height: view.height)
        containerView.frame = CGRect(origin: CGPoint.zero, size: scrollView.contentSize)
    }
    
    func addNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(STTableBoard.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(STTableBoard.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
}

//MARK: - response method
extension STTableBoard {
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.CGRectValue()
            let keyboardHeight = CGRectGetHeight(keyboardFrame)
            let screenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)
            
            var adjustHeight = keyboardHeight
            originFrame = self.view.frame
            if screenHeight - CGRectGetMinY(keyboardFrame) < keyboardHeight {
                adjustHeight = screenHeight - CGRectGetMinY(keyboardFrame)
            }
            adjustHeight -= keyboardInset
            UIView.animateWithDuration(0.33, animations: { [unowned self]() -> Void in
                self.relayoutAllViews(CGSize(width: self.view.width, height: self.view.height - adjustHeight), hideBoardMenu: false)
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.33, animations: { [unowned self]() -> Void in
            self.relayoutAllViews(self.originFrame.size, hideBoardMenu: false)
            })
    }
}
