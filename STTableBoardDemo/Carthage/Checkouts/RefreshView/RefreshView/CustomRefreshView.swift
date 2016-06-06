//
//  CustomRefreshView.swift
//  RefreshView
//
//  Created by bruce on 16/5/12.
//  Copyright © 2016年 ZouLiangming. All rights reserved.
//

import UIKit

public class CustomRefreshView: UIView {

    var pan: UIPanGestureRecognizer?
    var scrollView: UIScrollView?
    var pullingPercent: CGFloat?
    var start: (() -> ())?
    var insetTDelta: CGFloat = 0
    var scrollViewOriginalInset: UIEdgeInsets?
    var originInset: UIEdgeInsets?

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    func cellsCount() -> Int {
        var count = 0
        if let tableView = self.scrollView as? UITableView {
            if let dataSource = tableView.dataSource {
                if dataSource.respondsToSelector(TableViewSelectors.numberOfSections) {
                    let sections = dataSource.numberOfSectionsInTableView!(tableView)
                    for section in 0..<sections {
                        count += dataSource.tableView(tableView, numberOfRowsInSection: section)
                    }
                } else {
                    count += dataSource.tableView(tableView, numberOfRowsInSection: 0)
                }
            }
        } else if let collectionView = self.scrollView as? UICollectionView {
            if let dataSource = collectionView.dataSource {
                if dataSource.respondsToSelector(CollectionViewSelectors.numberOfSections) {
                    let sections = dataSource.numberOfSectionsInCollectionView!(collectionView)
                    for section in 0..<sections {
                        count += dataSource.collectionView(collectionView, numberOfItemsInSection: section)
                    }
                } else {
                    count += dataSource.collectionView(collectionView, numberOfItemsInSection: 0)
                }
            }
        }

        return count
    }
}
