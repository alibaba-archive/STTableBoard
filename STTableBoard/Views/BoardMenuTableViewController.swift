//
//  BoardMenuTableViewController.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/7.
//  Copyright © 2016年 StormXX. All rights reserved.
//


import UIKit

class BoardMenuTableViewController: UITableViewController {

    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(white: 221 / 255.0, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)
        configCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard let boardMenu = self.navigationController as? BoardMenu, let tableBoard = boardMenu.tableBoard else { return }
        if isEditBoardTitleCell(indexPath) {
            if let canEditTitle = tableBoard.delegate?.tableBoard(tableBoard, canEditBoardTitleInBoard: boardMenu.boardIndex) where canEditTitle {
                let textViewController = BoardMenuTextViewController()
                textViewController.boardTitle = boardMenu.boardMenuTitle
                self.navigationController?.pushViewController(textViewController, animated: true)
            } else {
                return
            }
        } else if isDeleteBoardCell(indexPath) {
            boardMenu.boardMenuDelegate?.boardMenu(boardMenu, boardMenuHandleType: BoardMenuHandleType.BoardDeleted, userInfo: nil)
        } else {
        
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BoardMenuTableViewController {
    private func configCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            cell.textLabel?.text = localizedString["STTableBoard.EditBoardNameCell.Title"]
            cell.imageView?.image = UIImage(named: "BoardMenu_Icon_Edit", inBundle: currentBundle, compatibleWithTraitCollection: nil)
            cell.accessoryType = .DisclosureIndicator
        case (0,1):
            cell.textLabel?.text = localizedString["STTableBoard.DeleteBoardCell.Title"]
            cell.imageView?.image = UIImage(named: "BoardMenu_Icon_Delete", inBundle: currentBundle, compatibleWithTraitCollection: nil)
            cell.accessoryType = .None
        default:
            break
        }
    }
    
    func isEditBoardTitleCell(indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.row == 0
    }
    
    func isDeleteBoardCell(indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.row == 1
    }
}

