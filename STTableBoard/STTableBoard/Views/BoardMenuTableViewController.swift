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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)
        cell.textLabel?.text = "Delete the Board"
        cell.textLabel?.font = UIFont.systemFontOfSize(12.0)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let boardMenu = self.navigationController as? BoardMenu else { return }
        boardMenu.boardMenuDelegate?.boardIndex(boardIndex: boardMenu.boardIndex, rowDidSelectAtIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

