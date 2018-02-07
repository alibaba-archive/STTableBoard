//
//  ViewController+STTableBoard.swift
//  STTableBoardDemo
//
//  Created by DangGu on 16/12/13.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit
import STTableBoard

// MARK: - STTableBoardDelegate
extension ViewController: STTableBoardDelegate {
    func tableBoard(_ tableBoard: STTableBoard, didTapMoreButtonAt index: Int, boardTitle: String?, button: UIButton) {
        print("More button tapped")
    }

    func tableBoard(_ tableBoard: STTableBoard, heightForRowAt indexPath: STIndexPath) -> CGFloat {
        return 80
    }

    func tableBoard(_ tableBoard: STTableBoard, heightForHeaderInSection section: Int, atBoard boardIndex: Int) -> CGFloat {
        let dataArray = section == 0 ? dataArray1 : dataArray2
        guard !dataArray[boardIndex].isEmpty else {
            return 0
        }
        return 35
    }

    func tableBoard(_ tableBoard: STTableBoard, heightForFooterInSection section: Int, atBoard boardIndex: Int) -> CGFloat {
        return 0
    }

    func tableBoard(_ tableBoard: STTableBoard, willRemoveBoardAt index: Int) -> Bool {
        guard index != 0 else { return false }
        dataArray1.remove(at: index)
        dataArray2.remove(at: index)
        titleArray.remove(at: index)
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, willAddNewBoardAt index: Int, with boardTitle: String) {
        dataArray1.append([])
        dataArray2.append([])
        titleArray.append(boardTitle)
        tableBoard.insertBoard(at: index, animated: true)
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldShowActionButtonAt boardIndex: Int) -> Bool {
        if boardIndex != 1 {
            return true
        }
        return (dataArray1[boardIndex].count + dataArray2[boardIndex].count) % 2 == 0
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldEnableAddRowAt boardIndex: Int) -> Bool {
        if boardIndex == 2 {
            return false
        }
        return true
    }

    func customAddRowAction(for tableBoard: STTableBoard, at boardIndex: Int) -> (() -> Void)? {
        if boardIndex == 0 || boardIndex == 3 {
            return {
                let alert = UIAlertController(title: "Custom Add Row Action", message: "boardIndex: \(boardIndex)", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        return nil
    }

    func tableBoard(_ tableBoard: STTableBoard, didSelectRowAt indexPath: STIndexPath) {
        print("board \(indexPath.board) row \(indexPath.row)")
        if let cell = tableBoard.cellForRow(at: indexPath) as? BoardCardCell {
            print("cell's title \(String(describing: cell.titleText))")
        }
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        navigationController?.pushViewController(viewController, animated: true)
    }

    func tableBoard(_ tableBoard: STTableBoard, canEditBoardTitleAt boardIndex: Int) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, boardTitleDidChangeTo title: String, at boardIndex: Int) {
        titleArray[boardIndex] = title
    }

    func tableBoard(_ tableBoard: STTableBoard, handlePinchGesture recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            guard navigationController != nil, !isAnimatingForFullScreen else {
                break
            }
            animateTopBar(with: recognizer.velocity)
        default:
            break
        }
    }

    func dropMode(for tableBoard: STTableBoard, whenMovingRowAt indexPath: STIndexPath) -> STTableBoardDropMode {
        return .board
    }
}

// MARK: - STTableBoardDataSource
extension ViewController: STTableBoardDataSource {
    func numberOfBoards(in tableBoard: STTableBoard) -> Int {
        return titleArray.count
    }

    func tableBoard(_ tableBoard: STTableBoard, numberOfSectionsAt boardIndex: Int) -> Int {
        return 2
    }

    func tableBoard(_ tableBoard: STTableBoard, numberOfRowsInSection section: Int, atBoard boardIndex: Int) -> Int {
        let dataArray = section == 0 ? dataArray1 : dataArray2
        return dataArray[boardIndex].count
    }

    func tableBoard(_ tableBoard: STTableBoard, viewForHeaderInSection section: Int, atBoard boardIndex: Int) -> UIView? {
        let dataArray = section == 0 ? dataArray1 : dataArray2
        guard !dataArray[boardIndex].isEmpty else {
            return nil
        }
        guard let headerView = tableBoard.dequeueReusableHeaderFooterView(withIdentifier: ParentTaskHeaderView.reuseIdentifier, atBoard: boardIndex) as? ParentTaskHeaderView else {
            return nil
        }
        switch section {
        case 0:
            headerView.configurationIconImageView.image = #imageLiteral(resourceName: "scenarioFieldConfigurationRequirementIcon")
            headerView.titleLabel.text = "场景化的管理"
            headerView.workflowStatusView.backgroundColor = UIColor(red: 216 / 255, green: 238 / 255, blue: 253 / 255, alpha: 1)
            headerView.workflowStatusLabel.textColor = UIColor(red: 36 / 255, green: 100 / 255, blue: 147 / 255, alpha: 1)
            headerView.workflowStatusLabel.text = "开发中"
        case 1:
            headerView.configurationIconImageView.image = #imageLiteral(resourceName: "scenarioFieldConfigurationBugIcon")
            headerView.titleLabel.text = "登录问题报错"
            headerView.workflowStatusView.backgroundColor = UIColor(white: 229 / 255, alpha: 1)
            headerView.workflowStatusLabel.textColor = UIColor(white: 56 / 255, alpha: 1)
            headerView.workflowStatusLabel.text = "待处理"
        default:
            break
        }
        return headerView
    }

    func tableBoard(_ tableBoard: STTableBoard, cellForRowAt indexPath: STIndexPath) -> UITableViewCell {
        guard let cell = tableBoard.dequeueReusableCell(withIdentifier: BoardCardCell.reuseIdentifier, for: indexPath) as? BoardCardCell else {
            return UITableViewCell()
        }
        let dataArray = indexPath.section == 0 ? dataArray1 : dataArray2
        cell.titleText = dataArray[indexPath.board][indexPath.row]
        return cell
    }

    func tableBoard(_ tableBoard: STTableBoard, titleForBoardAt boardIndex: Int) -> String? {
        return titleArray[boardIndex]
    }

    func tableBoard(_ tableBoard: STTableBoard, numberForBoardAt boardIndex: Int) -> Int {
        return dataArray1[boardIndex].count + dataArray2[boardIndex].count
    }

    func tableBoard(_ tableBoard: STTableBoard, didAddRowAt boardIndex: Int, with rowTitle: String) {
        let indexPath = STIndexPath(forRow: dataArray2[boardIndex].count, section: 1, inBoard: boardIndex)
        dataArray2[boardIndex].append(rowTitle)
        tableBoard.insertRow(at: indexPath, withRowAnimation: .fade, atScrollPosition: .bottom)
        tableBoard.reloadBoardNumber(at: boardIndex)
        tableBoard.reloadBoardActionButton(at: boardIndex)
    }

    func tableBoard(_ tableBoard: STTableBoard, didCancelAddRowAt boardIndex: Int) {
        print("didCancelAddRowAt \(boardIndex)")
    }

    // move row
    func tableBoard(_ tableBoard: STTableBoard, canMoveRowAt indexPath: STIndexPath) -> Bool {
        if indexPath.board == 0 && indexPath.row == 2 {
            return false
        }
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldMoveRowAt sourceIndexPath: STIndexPath, originIndexPath: STIndexPath, toDestinationIndexPath destinationIndexPath: STIndexPath) -> Bool {
        if destinationIndexPath.board == 1 && destinationIndexPath.row == 1 {
            return false
        }
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldMoveRowAt sourceIndexPath: STIndexPath, originIndexPath: STIndexPath, toDestinationBoard boardIndex: Int) -> Bool {
        return boardIndex != 2
    }

    func tableBoard(_ tableBoard: STTableBoard, moveRowAt sourceIndexPath: STIndexPath, toDestinationIndexPath destinationIndexPath: inout STIndexPath) {
        var sourceDataArray = sourceIndexPath.section == 0 ? dataArray1 : dataArray2
        let data = sourceDataArray[sourceIndexPath.board][sourceIndexPath.row]
        if sourceIndexPath.section == 0 {
            dataArray1[sourceIndexPath.board].remove(at: sourceIndexPath.row)
        } else {
            dataArray2[sourceIndexPath.board].remove(at: sourceIndexPath.row)
        }
        if destinationIndexPath.section == 0 {
            dataArray1[destinationIndexPath.board].insert(data, at: destinationIndexPath.row)
        } else {
            dataArray2[destinationIndexPath.board].insert(data, at: destinationIndexPath.row)
        }
    }

    func tableBoard(_ tableBoard: STTableBoard, moveRowAt sourceIndexPath: STIndexPath, toDestinationBoard boardIndex: Int) {
        var sourceDataArray = sourceIndexPath.section == 0 ? dataArray1 : dataArray2
        let data = sourceDataArray[sourceIndexPath.board][sourceIndexPath.row]
        if sourceIndexPath.section == 0 {
            dataArray1[sourceIndexPath.board].remove(at: sourceIndexPath.row)
        } else {
            dataArray2[sourceIndexPath.board].remove(at: sourceIndexPath.row)
        }
        tableBoard.deleteRows(at: [sourceIndexPath], with: .fade)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            let destinationIndexPath = STIndexPath(forRow: self.dataArray2[boardIndex].count, section: 1, inBoard: boardIndex)
            self.dataArray2[destinationIndexPath.board].insert(data, at: destinationIndexPath.row)
            tableBoard.insertRow(at: destinationIndexPath, withRowAnimation: .fade, atScrollPosition: .bottom)
        })
    }

    func tableBoard(_ tableBoard: STTableBoard, didEndMoveRowAt originIndexPath: STIndexPath, toDestinationIndexPath destinationIndexPath: STIndexPath) {
        print("originIndexPath: \(originIndexPath), destinationIndexPath: \(destinationIndexPath)")
        tableBoard.reloadBoardNumber(at: originIndexPath.board)
        tableBoard.reloadBoardNumber(at: destinationIndexPath.board)
        tableBoard.reloadBoardActionButton(at: originIndexPath.board)
        tableBoard.reloadBoardActionButton(at: destinationIndexPath.board)
    }

    func tableBoard(_ tableBoard: STTableBoard, didEndMoveRowAt originIndexPath: STIndexPath, toDestinationBoard boardIndex: Int) {
        print("originIndexPath: \(originIndexPath), destinationBoard: \(boardIndex)")
        tableBoard.reloadBoardNumber(at: originIndexPath.board)
        tableBoard.reloadBoardNumber(at: boardIndex)
        tableBoard.reloadBoardActionButton(at: originIndexPath.board)
        tableBoard.reloadBoardActionButton(at: boardIndex)
    }

    func tableBoard(_ tableBoard: STTableBoard, dropReleaseTextForBoardAt boardIndex: Int) -> String? {
        return "松开进入该状态(Board \(boardIndex))"
    }

    // move board
    func tableBoard(_ tableBoard: STTableBoard, canMoveBoardAt boardIndex: Int) -> Bool {
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, shouldMoveBoardAt sourceIndex: Int, to destinationIndex: Int) -> Bool {
        if destinationIndex == titleArray.count - 1 {
            return false
        }
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, moveBoardAt sourceIndex: Int, to destinationIndex: Int) {
        let sourceData1 = dataArray1[sourceIndex]
        let sourceData2 = dataArray2[sourceIndex]
        let destinationData1 = dataArray1[destinationIndex]
        let destinationData2 = dataArray2[destinationIndex]
        dataArray1[sourceIndex] = destinationData1
        dataArray2[sourceIndex] = destinationData2
        dataArray1[destinationIndex] = sourceData1
        dataArray2[destinationIndex] = sourceData2
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
        return true
    }

    func tableBoard(_ tableBoard: STTableBoard, footerRefreshingAt boardIndex: Int) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            tableBoard.endRefreshing(boardIndex)
            tableBoard.showRefreshFooter(boardIndex, showRefreshFooter: false)
        })
    }
}
