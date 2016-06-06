//
//  UIViewControllerDemo.swift
//  RefreshDemo
//
//  Created by bruce on 16/4/25.
//  Copyright © 2016年 ZouLiangming. All rights reserved.
//

import UIKit
import RefreshView

class UIViewControllerDemo: UIViewController {

    var array = [String]()
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        for i in 0...20 {
//            self.array.append(String(i))
//        }

        //self.tableView.tableFooterView = UIView()
        //self.tableView.showLoadingView = true
        self.tableView.refreshHeader = CustomRefreshHeaderView.headerWithRefreshingBlock({
            let minseconds = 3 * Double(NSEC_PER_SEC)
            let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(minseconds))
            dispatch_after(dtime, dispatch_get_main_queue(), {
                for i in 0...20 {
                    self.array.append(String(i))
                }
                self.tableView.refreshHeader?.endRefreshing()
                self.tableView.reloadData()
//                self.tableView.showLoadingView = false
            })
        })

//        let minseconds = 3 * Double(NSEC_PER_SEC)
//        let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(minseconds))
//        dispatch_after(dtime, dispatch_get_main_queue(), {
//            for i in 0...5 {
//                self.array.append(String(i))
//            }
//            self.tableView.showLoadingView = false
//            self.tableView.reloadData()
//        })

        self.tableView.refreshFooter = CustomRefreshFooterView.footerWithRefreshingBlock({
            let minseconds = 1 * Double(NSEC_PER_SEC)
            let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(minseconds))
            dispatch_after(dtime, dispatch_get_main_queue(), {
                let count = self.array.count
                for i in count+1...count+5 {
                    self.array.append(String(i))
                    self.tableView.reloadData()
                }
                self.tableView.refreshFooter?.endRefreshing()
                self.tableView.refreshFooter?.showLoadingView = (self.array.count < 25)
            })
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewControllerDemo: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
        }
        cell?.textLabel?.text = "CELL"
        return cell!
    }
}
