//
//  STTableBoard.swift
//  STTableBoard
//
//  Created by DangGu on 15/10/27.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit
import RefreshView

open class STTableBoard: UIViewController {
    open var boardWidth: CGFloat {
        if currentDevice == .pad {
            return self.customBoardWidth
        } else {
            if let width = preferredBoardWidth {
                return width - (leading + trailing)
            } else {
                var width: CGFloat = 0
                switch currentOrientation {
                case .portrait:
                    width = self.view.width
                case .landscape:
                    width = self.view.height
                }
                return width - (leading + trailing)
            }
        }
    }

    open var preferredBoardWidth: CGFloat?

    open var showLoadingView: Bool = false {
        didSet {
            scrollView.isShowLoadingView = showLoadingView
        }
    }
    open var tintColor: UIColor? {
        didSet {
            view.tintColor = tintColor
        }
    }

    var maxBoardHeight: CGFloat {
        return self.containerView.height - (top + bottom)
    }

    var numberOfPage: Int {
        guard let page = self.dataSource?.numberOfBoards(in: self) else {
            return 1
        }
        return page + (showAddBoardButton ? 1 : 0)
    }

    var longPressGestureForCell: UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureForCell(_:)))
        return gesture
    }

    var longPressGestureForBoard: UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureForBoard(_:)))
        return gesture
    }

    lazy var pinchGesture: UIPinchGestureRecognizer = {
        let gesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        return gesture
    }()

    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        gesture.delegate = self
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()

    var contentViewWidth: CGFloat {
        return 2 * leading + CGFloat(numberOfPage) * boardWidth + CGFloat(numberOfPage - 1) * pageSpacing
    }

    lazy var newBoardButtonView: NewBoardButton = {
        let view = NewBoardButton(frame: .zero)
        view.image = UIImage(named: "icon_addBoard", in: currentBundle, compatibleWith: nil)
        view.title = localizedString["STTableBoard.AddBoard"]
        view.delegate = self
        return view
    }()

    lazy var textComposeView: TextComposeView = {
        let view = TextComposeView(frame: .zero)
        view.delegate = self
        view.alpha = 0.0
        return view
    }()

    open var contentInset: UIEdgeInsets = .zero
    open var sizeOffset: CGSize = .zero
    open var keyboardInset: CGFloat = 0
    open internal(set) var dropMode: STTableBoardDropMode = .row

    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    var registeredCellClasses = [(AnyClass, String)]()
    var registeredHeaderFooterViewClasses = [(AnyClass, String)]()
    var tableBoardMode: STTableBoardMode = .page {
        didSet {
            switch tableBoardMode {
            case .page:
                showPageControl = true
            case .scroll:
                showPageControl = false
            }
        }
    }
    open var customBoardWidth: CGFloat = 280

    //Views Property
    var boards = [STBoardView]()
    var scrollView: UIScrollView!
    var containerView: UIView!
    lazy var pageControl: STPageControl = {
        let control = STPageControl(frame: .zero)
        control.backgroundColor = .clear
        control.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        control.pageIndicatorTintColor = pageIndicatorTintColor
        control.currentPage = self.currentPage
        control.numberOfPages = self.numberOfPage
        control.isEnabled = false
        return control
    }()

    //Delegate Property
    open weak var dataSource: STTableBoardDataSource?
    open weak var delegate: STTableBoardDelegate?

    //Public Property
    open var showAddBoardButton: Bool = false {
        didSet {
            pageControl.showAddDots = showAddBoardButton
        }
    }

    //Move Row Or Board Property
    var snapshot: UIView!
    var snapshotCenterOffset: CGPoint!
    var snapshotOffsetForLeftBounds: CGFloat!
    var sourceIndexPath: STIndexPath!
    var originIndexPath: STIndexPath!
    var destinationBoardIndex: Int!
    var sourceIndex = -1
    var originIndex = -1
    var isMoveBoardFromPageMode = false
    var lastMovingTime: Date!
    var showPageControl: Bool = false {
        didSet {
            self.pageControl.isHidden = !showPageControl
        }
    }

    //ScrollView Auto Scroll property
    var isScrolling = false
    var scrollDirection: ScrollDirection = .none
    var velocity: CGFloat = defaultScrollViewScrollVelocity

    //TableView Auto Scroll Property
    var tableViewAutoScrollTimer: Timer?
    var tableViewAutoScrollDistance: CGFloat = 0

    //Zoom Property
    var originContentOffset: CGPoint = .zero
    var originContentSize: CGSize = .zero
    var scaledContentOffset: CGPoint = .zero
    public internal(set) var currentScale: CGFloat = scaleForPage
    var tapPosition: CGPoint = .zero
    var originFrame: CGRect!

    //Text Compose property
    var boardViewForVisibleTextComposeView: STBoardView?
    var isAddBoardTextComposeViewVisible = false

    fileprivate var isFirstLoading = true

    // Current Working Gesture
    var currentLongPressGestureForCell: UILongPressGestureRecognizer?
    var currentLongPressGestureForBoard: UILongPressGestureRecognizer?

    // MARK: - life cycle

    public init(localizedStrings: [String: String]) {
        super.init(nibName: nil, bundle: nil)
        localizedString = localizedStrings
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupProperty()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstLoading {
            reloadData()
            isFirstLoading = false
        }
        addNotification()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.pinchGestureRecognizer?.isEnabled = false
        if !isFirstLoading {
            relayoutAllViews(view.bounds.size)
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - init helper
    fileprivate func setupProperty() {
        view.frame = CGRect(x: contentInset.left, y: contentInset.top, width: view.width - (contentInset.left + contentInset.right + sizeOffset.width), height: view.height - (contentInset.top + contentInset.bottom + sizeOffset.height))

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = scaleForScroll
        scrollView.maximumZoomScale = scaleForPage
        scrollView.delegate = self
        scrollView.bounces = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(scrollView)

        pageControl.frame = CGRect(x: 0, y: view.height - pageControlHeight, width: view.width, height: pageControlHeight)
        view.addSubview(pageControl)

        containerView = UIView(frame: CGRect(origin: .zero, size: scrollView.contentSize))
        scrollView.addSubview(containerView)
        containerView.backgroundColor = tableBoardBackgroundColor
        scrollView.backgroundColor = tableBoardBackgroundColor

        if currentDevice == .pad {
            tableBoardMode = .scroll
            showPageControl = false
        } else if currentDevice == .phone {
            if currentOrientation == .landscape {
                tableBoardMode = .scroll
                showPageControl = false
            } else {
                showPageControl = true
                tableBoardMode = .page
            }
            containerView.addGestureRecognizer(doubleTapGesture)
        }
        containerView.addGestureRecognizer(pinchGesture)
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) -> Void in
            let width = self.view.width
            let height = self.view.height
            let newSize = CGSize(width: width - (self.contentInset.left + self.contentInset.right + self.sizeOffset.width), height: height - (self.contentInset.top + self.contentInset.bottom + self.sizeOffset.height))
            self.relayoutAllViews(newSize)
            }) { (_) -> Void in
                switch (currentOrientation, currentDevice) {
                case (_, .pad):
                    self.tableBoardMode = .scroll
                case (.landscape, _):
                    self.tableBoardMode = .scroll
                case (.portrait, _):
                    self.tableBoardMode = self.currentScale == scaleForPage ? .page : .scroll
                }
                self.scrollToActualPage(self.scrollView, offsetX: self.scrollView.contentOffset.x)
        }
    }

    func relayoutAllViews(_ size: CGSize) {
        guard !size.equalTo(scrollView.frame.size) else {
            return
        }
        scrollView.frame = CGRect(origin: .zero, size: size)
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: size.height)
        containerView.frame = CGRect(origin: .zero, size: scrollView.contentSize)
        UIView.animate(withDuration: 0.5) {
            self.pageControl.frame = CGRect(x: 0, y: size.height - self.pageControl.height, width: size.width, height: pageControlHeight)
        }
        boards.forEach { (board) -> Void in
            autoAdjustTableBoardHeight(board, animated: true)
        }
        originContentSize = CGSize(width: originContentSize.width, height: size.height)
    }

    open func relayoutAllViews() {
        relayoutAllViews(view.frame.size)
    }

    func resetContentSize() {
        scrollView.contentSize = CGSize(width: contentViewWidth, height: view.height)
        containerView.frame = CGRect(origin: .zero, size: scrollView.contentSize)
        pageControl.frame = CGRect(x: 0, y: view.height - pageControl.height, width: view.width, height: pageControlHeight)
    }

    public func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - response method
extension STTableBoard {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo, let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.cgRectValue
            let keyboardHeight = keyboardFrame.height
            let screenHeight = UIScreen.main.bounds.height

            var adjustHeight = keyboardHeight
            originFrame = self.view.frame
            if screenHeight - keyboardFrame.minY < keyboardHeight {
                adjustHeight = screenHeight - keyboardFrame.minY
            }
            adjustHeight -= keyboardInset
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                self.relayoutAllViews(CGSize(width: self.view.width, height: self.view.height - adjustHeight))
            })
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard self.originFrame != nil else {
            return
        }
        UIView.animate(withDuration: 0.33, animations: { [weak self]() -> Void in
            guard let `self` = self else {
                return
            }
            self.relayoutAllViews(self.originFrame.size)
            })
    }
}
