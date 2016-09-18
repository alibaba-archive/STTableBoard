//
//  ViewController.swift
//  STTableBoardDemo
//
//  Created by DangGu on 15/12/14.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import UIKit
import STTableBoard

class ViewController: UIViewController {
    
    var dataArray: [[String]] = []
    var titleArray: [String] = []
    var localizedString: [String: String] = [
        "STTableBoard.AddRow": "Add Task...",
        "STTableBoard.AddBoard": "Add Stage...",
        "STTableBoard.BoardMenuTextViewController.Title": "编辑阶段名称",
        "STTableBoard.EditBoardNameCell.Title": "编辑阶段",
        "STTableBoard.DeleteBoardCell.Title": "删除阶段",
        "STTableBoard.DeleteBoard.Alert.Message": "确定要删除这个阶段吗？",
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
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        self.title = "Teambition"
        addAddButton()
        dataArray = [
            ["七里香1","七里香2","七里香3","七里香4","最后的战役1","最后的战役2","最后的战役3","晴天1","晴天2","晴天3","晴天4","晴天5","爱情悬崖1","爱情悬崖2","爱情悬崖3","爱情悬崖4","彩虹1","彩虹2","彩虹3","彩虹4"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3"],
            ["恩"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3"],
            ["彩虹1","彩虹2","彩虹3","彩虹4","彩虹5","彩虹6","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3","最后的战役1","最后的战役2","最后的战役3"]
        ]
        
        titleArray = ["七里香11111111111111111", "星晴", "彩虹", "彩虹", "aha"]
        
//        tableBoard.contentInset = UIEdgeInsets(top: 64.0, left: 0, bottom: 0, right: 0)
//        tableBoard.sizeOffset = CGSize(width: 0.0, height: 64)
        tableBoard.registerClasses([(BoardCardCell.self,"DefaultCell")])
        tableBoard.delegate = self
        tableBoard.dataSource = self
        tableBoard.showAddBoardButton = true
        view.frame.size.height -= 64.0
        tableBoard.view.frame.size = view.frame.size
        self.addChildViewController(tableBoard)
        view.addSubview(tableBoard.view)
        tableBoard.didMove(toParentViewController: self)
//        tableBoard.showLoadingView = true
    }

    deinit {
        print("no retain cycle")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        (dataArray[0], dataArray[1]) = (dataArray[1], dataArray[0])
//        tableBoard.exchangeBoardAtIndex(0, destinationIndex: 1, animation: true)
//        let indexPath = STIndexPath(forRow: 0, inBoard: 1)
//        tableBoard.reloadRowAtIndexPath([indexPath], withRowAnimation: .Automatic)
//        delay(5) {
//            self.tableBoard.stopMovingBoard()
//            self.tableBoard.stopMovingCell()
//        }
    }
    
    func addAddButton() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.doneButtonClick))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func doneButtonClick() {
//        let indexPath1 = STIndexPath(forRow: dataArray[1].count, inBoard: 1)
//        dataArray[1].append("wtf")
//        tableBoard.insertRowAtIndexPath(indexPath1, withRowAnimation: .Fade, atScrollPosition: .Bottom)
        tableBoard.reloadData(false, resetMode: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func delay(_ seconds: Int, function: @escaping () -> Void) {
        let triggerTime = (Int64(NSEC_PER_SEC) * Int64(seconds))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            function()
        })
    }
}

extension ViewController: STTableBoardDelegate {
    func tableBoard(_ tableBoard: STTableBoard, heightForRowAt indexPath: STIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableBoard(_ tableBoard: STTableBoard, willRemoveBoardAt index: Int) -> Bool {
        guard index != 0 else { return false }
        dataArray.remove(at: index)
        titleArray.remove(at: index)
        return true
    }
    
    func tableBoard(_ tableBoard: STTableBoard, willAddNewBoardAt index: Int, with boardTitle: String) {
        dataArray.append([])
        titleArray.append(boardTitle)
        tableBoard.insertBoardAtIndex(index, withAnimation: true)
    }
    
    func tableBoard(_ tableBoard: STTableBoard, didSelectRowAt indexPath: STIndexPath) {
        print("board \(indexPath.board) row \(indexPath.row)")
        if let cell = tableBoard.cellForRowAtIndexPath(indexPath) as? BoardCardCell {
            print("cell's title \(cell.titleText)")
        }
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.white
        navigationController?.pushViewController(viewController, animated: true)
    }

    func tableBoard(_ tableBoard: STTableBoard, canEditBoardTitleAt boardIndex: Int) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, boardTitleBeChangedTo title: String, at boardIndex: Int) {
        titleArray[boardIndex] = title
    }
}

extension ViewController: STTableBoardDataSource {
    func numberOfBoards(in tableBoard: STTableBoard) -> Int {
        return dataArray.count
    }

    func tableBoard(_ tableBoard: STTableBoard, numberOfRowsAt boardIndex: Int) -> Int {
        return dataArray[boardIndex].count
    }

    func tableBoard(_ tableBoard: STTableBoard, cellForRowAt indexPath: STIndexPath) -> UITableViewCell {
        let cell = tableBoard.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath) as! BoardCardCell
        cell.titleText = dataArray[indexPath.board][indexPath.row]
        return cell
    }

    func tableBoard(_ tableBoard: STTableBoard, titleForBoardAt boardIndex: Int) -> String? {
        return titleArray[boardIndex]
    }

    func tableBoard(_ tableBoard: STTableBoard, numberForBoardAt boardIndex: Int) -> Int {
        return dataArray[boardIndex].count
    }

    func tableBoard(_ tableBoard: STTableBoard, didAddRowAt boardIndex: Int, with rowTitle: String) {
        let indexPath = STIndexPath(forRow: dataArray[boardIndex].count, inBoard: boardIndex)
        dataArray[boardIndex].append(rowTitle)
        tableBoard.insertRowAtIndexPath(indexPath, withRowAnimation: .fade, atScrollPosition: .bottom)
    }
    
    // move row
    func tableBoard(_ tableBoard: STTableBoard, canMoveRowAt indexPath: STIndexPath) -> Bool {
        if indexPath.board == 0 && indexPath.row == 2 {
            return false
        }
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldMoveRowAt sourceIndexPath: STIndexPath, to destinationIndexPath: STIndexPath) -> Bool {
        if destinationIndexPath.board == 1 && destinationIndexPath.row == 1 {
            return false
        }
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, moveRowAt sourceIndexPath: STIndexPath, to destinationIndexPath: inout STIndexPath) {
//        destinationIndexPath = STIndexPath(forRow: 0, inBoard: destinationIndexPath.board)
        let data = dataArray[sourceIndexPath.board][sourceIndexPath.row]
        dataArray[sourceIndexPath.board].remove(at: sourceIndexPath.row)
        dataArray[destinationIndexPath.board].insert(data, at: destinationIndexPath.row)
    }
    
    func tableBoard(_ tableBoard: STTableBoard, didEndMoveRowAt originIndexPath: STIndexPath, to destinationIndexPath: STIndexPath) {
        print("originIndexPath \(originIndexPath), destinationIndexPath \(destinationIndexPath)")
    }
    
    // move board
    func tableBoard(_ tableBoard: STTableBoard, canMoveBoardAt boardIndex: Int) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldMoveBoardAt sourceIndex: Int, to destinationIndex: Int) -> Bool {
        if destinationIndex == dataArray.count - 1 {
            return false
        }
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, moveBoardAt sourceIndex: Int, to destinationIndex: Int) {
        let sourceData = dataArray[sourceIndex]
        let destinationData = dataArray[destinationIndex]
        dataArray[sourceIndex] = destinationData
        dataArray[destinationIndex] = sourceData
    }
    
    func tableBoard(_ tableBoard: STTableBoard, didEndMoveBoardAt originIndex: Int, to destinationIndex: Int) {
        print("originIndex \(originIndex), destinationIndex \(destinationIndex)")
    }

    // scale table board
    func tableBoard(_ tableBoard: STTableBoard, scaleTableBoard isScaled: Bool) {
        print("isScaled : \(isScaled)")
    }

    // footer refresh handle
    func tableBoard(_ tableBoard: STTableBoard, showRefreshFooterAt boardIndex: Int) -> Bool {
//        if boardIndex == dataArray.count - 1 {
//            return true
//        }
//        return false
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, footerRefreshingAt boardIndex: Int) {
//        tableBoard.endRefreshing(boardIndex)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            tableBoard.endRefreshing(boardIndex)
            tableBoard.showRefreshFooter(boardIndex, showRefreshFooter: false)
        });
        print("1")
    }
}
