//
//  STIndexPath.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/24.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import Foundation

public class STIndexPath {
    public let row: Int
    public let board: Int

    init(forRow row: Int, inBoard board: Int) {
        self.row = row
        self.board = board
    }
}
