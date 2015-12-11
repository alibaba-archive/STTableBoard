//
//  STIndexPath.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/24.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import Foundation

class STIndexPath {
    let row: Int
    let board: Int

    init(forRow row: Int, inBoard board: Int) {
        self.row = row
        self.board = board
    }
}
