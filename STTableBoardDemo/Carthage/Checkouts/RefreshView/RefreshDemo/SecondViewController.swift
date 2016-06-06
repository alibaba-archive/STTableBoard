//
//  SecondViewController.swift
//  RefreshDemo
//
//  Created by ZouLiangming on 16/1/25.
//  Copyright © 2016年 ZouLiangming. All rights reserved.
//

import UIKit
import RefreshView


class SecondViewController: UITableViewController {

    var content = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.showLoadingView = true
//        self.tableView.loadingView?.offsetX = 30
        self.tableView.loadingView?.offsetY = 30

        let minseconds = 2 * Double(NSEC_PER_SEC)
        let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(minseconds))
        dispatch_after(dtime, dispatch_get_main_queue(), {
            for i in 1...10 {
                self.content.append(String(i))
                self.tableView.reloadData()
                self.tableView.showLoadingView = false
                self.tableView.refreshFooter?.showLoadingView = true
            }
        })

        self.tableView.refreshHeader = CustomRefreshHeaderView.headerWithRefreshingBlock({
            let minseconds = 3 * Double(NSEC_PER_SEC)
            let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(minseconds))
            dispatch_after(dtime, dispatch_get_main_queue(), {
                let count = self.content.count
                for i in count+1...count+5 {
                    self.content.append(String(i))
                    self.tableView.reloadData()
                }
                self.tableView.refreshHeader?.endRefreshing()
                self.tableView.refreshFooter?.showLoadingView = false
            })
        }, customBackgroundColor: UIColor.whiteColor())

        self.tableView.refreshFooter = CustomRefreshFooterView.footerWithLoadingText("Loading More Data", startLoading: {
            let minseconds = 1 * Double(NSEC_PER_SEC)
            let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(minseconds))
            dispatch_after(dtime, dispatch_get_main_queue(), {
                let count = self.content.count
                for i in count+1...count+5 {
                    self.content.append(String(i))
                    self.tableView.reloadData()
                }
                self.tableView.refreshFooter?.endRefreshing()
                self.tableView.refreshFooter?.showLoadingView = count < 26
            })
        })
    }

    func dismiss() {
        self.tableView.refreshHeader?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.content.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BASIC", forIndexPath: indexPath)
        cell.textLabel?.text = self.content[indexPath.row]

        return cell
    }
}
