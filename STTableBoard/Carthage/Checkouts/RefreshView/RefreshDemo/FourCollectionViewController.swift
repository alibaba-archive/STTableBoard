//
//  FourCollectionViewController.swift
//  RefreshDemo
//
//  Created by bruce on 16/3/16.
//  Copyright © 2016年 ZouLiangming. All rights reserved.
//

import UIKit
import RefreshView

private let reuseIdentifier = "Four"

class FourCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.showLoadingView = true
        let minseconds = 8 * Double(NSEC_PER_SEC)
        let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(minseconds))
        dispatch_after(dtime, dispatch_get_main_queue(), {
            self.collectionView?.showLoadingView = false
        })

        self.collectionView?.refreshHeader = CustomRefreshHeaderView.headerWithRefreshingBlock({
            let minseconds = 3 * Double(NSEC_PER_SEC)
            let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(minseconds))
            dispatch_after(dtime, dispatch_get_main_queue(), {
                self.collectionView?.refreshHeader?.endRefreshing()
            })
        })

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 4
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        return cell
    }
}
