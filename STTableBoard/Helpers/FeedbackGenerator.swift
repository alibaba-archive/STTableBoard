//
//  FeedbackGenerator.swift
//  STTableBoard
//
//  Created by 洪鑫 on 2018/11/19.
//  Copyright © 2018 StormXX. All rights reserved.
//

import UIKit
import AudioToolbox

struct FeedbackGenerator {
    static func impactOccurred() {
        guard #available(iOS 10.0, *) else {
            return
        }
        // Only working with iPhone 7/7 Plus and later, iOS 10.0+
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    static func selectionChanged() {
        guard #available(iOS 10.0, *) else {
            return
        }
        // Only working with iPhone 7/7 Plus and later, iOS 10.0+
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
