//
//  ViewController.swift
//  STTableBoardDemo
//
//  Created by DangGu on 15/12/14.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit
import STTableBoard

struct ContainerViewConstant {
    static let height: CGFloat = 40
}

struct ExitFullScreenViewConstant {
    static let buttonWidth: CGFloat = 34
    static let height: CGFloat = 44
}

class ViewController: UIViewController {

    var dataArray1 = [[String]]()
    var dataArray2 = [[String]]()
    var titleArray = [String]()
    var localizedString: [String: String] = [
        "STTableBoard.AddRow": "Add Task...",
        "STTableBoard.AddBoard": "Add Stage...",
        "STTableBoard.Delete": "删除",
        "STTableBoard.Cancel": "Cancel",
        "STTableBoard.OK": "确定",
        "STTableBoard.Create": "Create",
        "STTableBoard.RefreshFooter.text": "Fuck Loading..."
    ]
    lazy var tableBoard: STTableBoard = {
        let table = STTableBoard(localizedStrings: self.localizedString)
        return table
    }()

    // all screen
    fileprivate lazy var containerView: UIView = self.makeContainerView()
    fileprivate lazy var exitFullScreenView: UIView = self.makeExitFullScreenView()
    fileprivate var topConstraint: NSLayoutConstraint!
    fileprivate var bottomConstraintForExitFullScreenView: NSLayoutConstraint!
    fileprivate var isBarHidden = false

    fileprivate let enterFullScreenDuration: TimeInterval = 0.33
    var isAnimatingForFullScreen = false

    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        self.title = "Teambition"
        setupContianerView()
        setupExitFullScreenView()
        configureTableBoard()
        layoutView()
        addAddButton()
        tableBoard.reloadData()
        let footerRect = tableBoard.boardFooterRect(at: 0)
        print("viewDidLoad \(footerRect)")
    }

    deinit {
        print("no retain cycle")
    }

    func addAddButton() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(doneButtonClick))
        navigationItem.rightBarButtonItem = doneButton
    }

    @objc func doneButtonClick() {
        tableBoard.reloadData(false, resetMode: true)
    }

    func delay(_ seconds: Int, function: @escaping () -> Void) {
        let triggerTime = (Int64(NSEC_PER_SEC) * Int64(seconds))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            function()
        })
    }
    @IBAction func reloadButtonTapped(_ sender: Any) {
        tableBoard.reloadData(true, resetMode: true)
    }
}

extension ViewController {
    override var prefersStatusBarHidden: Bool {
        return isBarHidden
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}

extension ViewController {
    fileprivate func makeContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }

    fileprivate func makeExitFullScreenView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        let exitButton = UIButton()
        exitButton.addTarget(self, action: #selector(exitFullScreenTapped), for: .touchUpInside)
        exitButton.setImage(#imageLiteral(resourceName: "exitFullScreen"), for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(exitButton)
        let centerXConstraint = NSLayoutConstraint(item: exitButton, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerYConstraint = NSLayoutConstraint(item: exitButton, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: exitButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ExitFullScreenViewConstant.buttonWidth)
        let heightConstraint = NSLayoutConstraint(item: exitButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ExitFullScreenViewConstant.buttonWidth)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint, widthConstraint, heightConstraint])
        return containerView
    }

    fileprivate func configureTableBoard() {
        dataArray1 = [
            ["七里香1", "七里香2", "七里香3", "七里香4", "最后的战役1", "最后的战役2", "最后的战役3", "晴天1", "晴天2", "晴天3", "晴天4", "晴天5", "爱情悬崖1", "爱情悬崖2", "爱情悬崖3", "爱情悬崖4", "彩虹1", "彩虹2", "彩虹3", "彩虹4"],
            ["彩虹1", "彩虹2", "彩虹3", "彩虹4", "彩虹5", "彩虹6", "最后的战役1", "最后的战役2", "最后的战役3", "最后的战役1", "最后的战役2", "最后的战役3"],
            ["七里香1", "七里香2", "七里香3", "七里香4", "最后的战役1", "最后的战役2", "最后的战役3", "晴天1", "晴天2", "晴天3", "晴天4", "晴天5", "爱情悬崖1", "爱情悬崖2", "爱情悬崖3", "爱情悬崖4", "彩虹1", "彩虹2", "彩虹3", "彩虹4"],
            ["七里香1", "七里香2", "七里香3", "七里香4", "最后的战役1", "最后的战役2", "最后的战役3", "晴天1", "晴天2", "晴天3", "晴天4", "晴天5", "爱情悬崖1", "爱情悬崖2", "爱情悬崖3", "爱情悬崖4", "彩虹1", "彩虹2", "彩虹3", "彩虹4"],
            []
        ]
        dataArray2 = [
            ["雨下一整晚1", "雨下一整晚2", "雨下一整晚3", "雨下一整晚4", "红尘客栈1", "红尘客栈2", "红尘客栈3", "乔克叔叔1"],
            ["以父之名1", "以父之名2", "以父之名3", "以父之名4", "以父之名5", "以父之名6", "世界末日1", "世界末日2", "世界末日3"],
            ["等你下课1", "等你下课2", "等你下课3", "等你下课4", "梯田1", "梯田2"],
            ["千里之外1", "千里之外2", "千里之外3", "千里之外4", "半岛铁盒1", "半岛铁盒2"],
            []
        ]

        titleArray = ["1爷爷泡的茶七里香你比从前快乐又是十一月的萧邦", "2星晴", "3彩虹", "4火车叨位去", "5不完整的旋律"]

        //        tableBoard.contentInset = UIEdgeInsets(top: 64.0, left: 0, bottom: 0, right: 0)
        //        tableBoard.sizeOffset = CGSize(width: 0.0, height: 64)
        //        view.frame.size.height -= 64.0
        //        tableBoard.view.frame.size = view.frame.size
        tableBoard.registerCellClasses([(BoardCardCell.self, BoardCardCell.reuseIdentifier)])
        tableBoard.registerHeaderFooterViewClasses([(ParentTaskHeaderView.self, ParentTaskHeaderView.reuseIdentifier)])
        tableBoard.delegate = self
        tableBoard.dataSource = self
        tableBoard.showAddBoardButton = true
//        tableBoard.preferredBoardWidth = 280
        self.addChild(tableBoard)
        view.addSubview(tableBoard.view)
        tableBoard.didMove(toParent: self)
    }

    fileprivate func setupContianerView() {
        if let navigationBar = navigationController?.navigationBar {
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(containerView, belowSubview: navigationBar)
            topConstraint = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
            view.addConstraint(topConstraint)
            view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: ContainerViewConstant.height))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: ["containerView": containerView]))
        }
    }

    fileprivate func setupExitFullScreenView() {
        view.insertSubview(exitFullScreenView, belowSubview: containerView)
        exitFullScreenView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[exitFullScreenView]|", options: [], metrics: nil, views: ["exitFullScreenView": exitFullScreenView])
        let heightConstraint = NSLayoutConstraint(item: exitFullScreenView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ExitFullScreenViewConstant.height)
        bottomConstraintForExitFullScreenView = NSLayoutConstraint(item: exitFullScreenView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: ExitFullScreenViewConstant.height)
        NSLayoutConstraint.activate([heightConstraint, bottomConstraintForExitFullScreenView] + horizontalConstraints)
        exitFullScreenView.layoutIfNeeded()
    }

    fileprivate func layoutView() {
        tableBoard.view.translatesAutoresizingMaskIntoConstraints = false
        let views: [String: Any] = ["tableBoard": tableBoard.view]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableBoard]|", options: [], metrics: nil, views: views)
        let top = NSLayoutConstraint(item: tableBoard.view, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: tableBoard.view, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate(horizontalConstraints + [top, bottom])
    }

    func animateTopBar(with velocity: CGFloat) {
        if !isBarHidden && velocity > 0.5 {
            enterFullScreen()
        } else if isBarHidden && velocity < -0.5 {
            exitFullScreen()
        }
    }

    fileprivate func animateExitFullScreenView() {
        let constant = isBarHidden ? 0 : ExitFullScreenViewConstant.height
        bottomConstraintForExitFullScreenView.constant = constant
        UIView.animate(withDuration: 0.33) {
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func enterFullScreen() {
        guard !isBarHidden else {
            return
        }
        isAnimatingForFullScreen = true
        isBarHidden = true
        topConstraint.constant = -ContainerViewConstant.height
        UIView.animate(withDuration: enterFullScreenDuration, delay: 0.0, options: .curveLinear,
                       animations: {
                        self.navigationController?.setNavigationBarHidden(true, animated: false)
                        self.setTabBarVisible(visible: false, animated: false)
        }, completion: { (finished) in
            guard finished else {
                return
            }
            self.isAnimatingForFullScreen = false
            self.setNeedsStatusBarAppearanceUpdate()
            self.tableBoard.relayoutAllViews()
            self.animateExitFullScreenView()
        })
    }

    fileprivate func exitFullScreen() {
        guard isBarHidden else {
            return
        }
        isAnimatingForFullScreen = true
        isBarHidden = false
        topConstraint.constant = 0
        UIView.animate(withDuration: enterFullScreenDuration, delay: 0.0, options: .curveLinear,
                       animations: {
                        self.navigationController?.setNavigationBarHidden(false, animated: false)
                        self.setTabBarVisible(visible: true, animated: false)
        }, completion: { (finished) in
            guard finished else {
                return
            }
            self.isAnimatingForFullScreen = false
            self.setNeedsStatusBarAppearanceUpdate()
            self.animateExitFullScreenView()
            self.tableBoard.relayoutAllViews()
        })
    }

}

extension ViewController {
    @objc func exitFullScreenTapped() {
        exitFullScreen()
    }
}

extension UIViewController {
    func setTabBarVisible(visible: Bool, animated: Bool) {
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time

        // bail if the current state matches the desired state
        if isTabBarVisible == visible {
            return
        }

        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)

        // zero duration means no animation
        let duration: TimeInterval = (animated ? 0.3 : 0.0)

        //  animate the tabBar
        if frame != nil {
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }
        }
    }

    var isTabBarVisible: Bool {
        return (self.tabBarController?.tabBar.frame.origin.y ?? 0) < self.view.frame.maxY
    }
}
