//
//  constant.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/26.
//  Copyright © 2015年 StormXX. All rights reserved.
//
import UIKit

public enum BoardMenuHandleType {
    case boardTitleChanged
    case boardDeleted
}

enum SnapViewStatus {
    case moving
    case origin
}

enum ScrollDirection {
    case left
    case right
    case none
}

enum STTableBoardMode {
    case page
    case scroll
}

enum STTableBoardOrientation {
    case landscape
    case portrait
}

let timerUserInfoTableViewKey = "theTableView"
let leading: CGFloat  = 30.0
let trailing: CGFloat = leading
let top: CGFloat = 20.0
let bottom: CGFloat = top
let pageSpacing: CGFloat = leading / 2
let overlap: CGFloat = pageSpacing * 3
let rotateAngel: CGFloat = CGFloat(M_PI/36)
let headerViewHeight: CGFloat = 48.0
let footerViewHeight: CGFloat = 48.0
let newBoardButtonViewHeight: CGFloat = 56.0
let newBoardComposeViewHeight: CGFloat = 122.0
let newCellComposeViewTextFieldHeight: CGFloat = 40.0
let newCellComposeViewHeight: CGFloat = 106.0
let scaleForPage: CGFloat = 1.0
let scaleForScroll: CGFloat = 0.5
let defaultScrollViewScrollVelocity: CGFloat = 50.0
let currentBundle = Bundle(for: STTableBoard.self)
let minimumMovingRowInterval: TimeInterval = 0.2
let boardmenuMaxSpacingToEdge: CGFloat = 20.0
let pageControlHeight: CGFloat = 20.0

//Color
let boardBackgroundColor: UIColor = UIColor(red: 234.0/255.0, green: 235.0/255.0, blue: 236.0/255.0, alpha: 1.0)
let tableBoardBackgroundColor: UIColor = UIColor(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1.0)
let boardBorderColor: UIColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
let boardFooterButtonTitleColor: UIColor = UIColor(red: 166.0/255.0, green: 166.0/255.0, blue: 166.0/255.0, alpha: 1.0)
let currentPageIndicatorTintColor: UIColor = UIColor(red: 184.0/255.0, green: 184.0/255.0, blue: 184.0/255.0, alpha: 1.0)
let pageIndicatorTintColor: UIColor = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.0)

// new board button colors
let dashedLineColor: UIColor = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.0)
let newBoardButtonBackgroundColor: UIColor = UIColor(red: 234.0/255.0, green: 235.0/255.0, blue: 236.0/255.0, alpha: 1.0)
let newBoardButtonTextColor: UIColor = UIColor(red: 189.0/255.0, green: 189.0/255.0, blue: 189.0/255.0, alpha: 1.0)
let cancelButtonTextColor: UIColor = UIColor(red: 166/255.0, green: 166/255.0, blue: 166/255.0, alpha: 1.0)

// board menu colors
let boardMenuTextViewControllerBackgroundColor: UIColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
let boardMenuTextFieldBorderColor: UIColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)

// board menu userInfo keys
let newBoardTitleKey = "newBoardTitle"
let boardIndexKey = "boardIndex"

var currentDevice: UIUserInterfaceIdiom {
    get {
        return UIDevice.current.userInterfaceIdiom
    }
}

var currentOrientation: STTableBoardOrientation {
    get {
        var orientation: STTableBoardOrientation = .portrait
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .portraitUpsideDown, .unknown:
            orientation = .portrait
        case .landscapeLeft, .landscapeRight:
            orientation = .landscape
        }
        return orientation
    }
}

var localizedString: [String: String] = [
    "STTableBoard.AddRow": "添加任务...",
    "STTableBoard.AddBoard": "添加阶段...",
    "STTableBoard.BoardMenuTextViewController.Title": "编辑阶段名称",
    "STTableBoard.EditBoardNameCell.Title": "编辑阶段",
    "STTableBoard.DeleteBoardCell.Title": "删除阶段",
    "STTableBoard.DeleteBoard.Alert.Message": "确定要删除这个阶段吗？",
    "STTableBoard.Delete": "删除",
    "STTableBoard.Cancel": "取消",
    "STTableBoard.OK": "确定",
    "STTableBoard.Create": "创建",
    "STTableBoard.RefreshFooter.text": "载入中..."
]
