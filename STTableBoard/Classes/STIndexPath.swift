//
//  STIndexPath.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/24.
//  Copyright © 2015年 StormXX. All rights reserved.
//

import Foundation

open class STIndexPath {
    public let section: Int
    public let row: Int
    public let board: Int

    public init(forRow row: Int, section: Int = 0, inBoard board: Int) {
        self.section = section
        self.row = row
        self.board = board
    }
}

public func == (left: STIndexPath, right: STIndexPath) -> Bool {
    return left.board == right.board && left.row == right.row && left.section == right.section
}

public func != (left: STIndexPath, right: STIndexPath) -> Bool {
    return left.board != right.board || left.row != right.row || left.section != right.section
}

extension STIndexPath: CustomStringConvertible {
    public var description: String {
        return "STIndexPath(section: \(section), row: \(row), board: \(board))"
    }
}
