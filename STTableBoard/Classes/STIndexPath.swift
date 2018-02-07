//
//  STIndexPath.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/24.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import Foundation

open class STIndexPath {
    open let row: Int
    open let board: Int

    public init(forRow row: Int, inBoard board: Int) {
        self.row = row
        self.board = board
    }
}

public func == (left: STIndexPath, right: STIndexPath) -> Bool {
    return left.board == right.board && left.row == right.row
}

public func != (left: STIndexPath, right: STIndexPath) -> Bool {
    return left.board != right.board || left.row != right.row
}
