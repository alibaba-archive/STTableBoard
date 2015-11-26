//
//  STTableBoardDelegate.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/24.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

protocol STTableBoardDataSource: class {
    func numberOfBoardsInTableBoard(tableBoard: STTableBoard) -> Int
    func tableBoard(tableBoard tableBoard: STTableBoard, numberOfRowsInBoard board: Int) -> Int
    func tableBoard(tableBoard tableBoard: STTableBoard, cellForRowAtIndexPath indexPath: STIndexPath) -> UITableViewCell
}

//extension STTableBoardDataSource {
//    func numberOfBoardsInTableBoard(tableBoard: STTableBoard) -> Int {
//        return 1
//    }
//}