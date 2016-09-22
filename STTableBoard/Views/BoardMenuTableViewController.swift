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

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(white: 221 / 255.0, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        configCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let boardMenu = self.navigationController as? BoardMenu, let tableBoard = boardMenu.tableBoard else { return }
        if isEditBoardTitleCell(indexPath) {
            if let canEditTitle = tableBoard.delegate?.tableBoard(tableBoard, canEditBoardTitleAt: boardMenu.boardIndex) , canEditTitle {
                let textViewController = BoardMenuTextViewController()
                textViewController.boardTitle = boardMenu.boardMenuTitle
                self.navigationController?.pushViewController(textViewController, animated: true)
            } else {
                return
            }
        } else if isDeleteBoardCell(indexPath) {
            boardMenu.boardMenuDelegate?.boardMenu(boardMenu, boardMenuHandleType: BoardMenuHandleType.boardDeleted, userInfo: nil)
        } else {
        
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BoardMenuTableViewController {
    fileprivate func configCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            cell.textLabel?.text = localizedString["STTableBoard.EditBoardNameCell.Title"]
            cell.imageView?.image = UIImage(named: "BoardMenu_Icon_Edit", in: currentBundle, compatibleWith: nil)
            cell.accessoryType = .disclosureIndicator
        case (0,1):
            cell.textLabel?.text = localizedString["STTableBoard.DeleteBoardCell.Title"]
            cell.imageView?.image = UIImage(named: "BoardMenu_Icon_Delete", in: currentBundle, compatibleWith: nil)
            cell.accessoryType = .none
        default:
            break
        }
    }
    
    func isEditBoardTitleCell(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.row == 0
    }
    
    func isDeleteBoardCell(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.row == 1
    }
}

