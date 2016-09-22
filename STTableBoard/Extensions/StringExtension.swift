//
//  StringExtension.swift
//  STTableBoard
//
//  Created by DangGu on 16/1/15.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import Foundation

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
