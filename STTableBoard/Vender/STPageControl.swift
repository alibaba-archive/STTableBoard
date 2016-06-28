//
//  STPageControl.swift
//  STTableBoard
//
//  Created by DangGu on 16/6/28.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

class STPageControl: UIPageControl {

    var showAddDots: Bool = true
    private var customDotImageView: UIImageView? = nil

    // Image
    let activeAddPageControlImage = UIImage(named: "active_add", inBundle: currentBundle, compatibleWithTraitCollection: nil)
    let inactiveAddPageControlImage = UIImage(named: "inactive_add", inBundle: currentBundle, compatibleWithTraitCollection: nil)

    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }

    override var numberOfPages: Int {
        didSet {
            if oldValue != numberOfPages {
                customDotImageView?.removeFromSuperview()
                updateDots()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func imageViewForSubView(view: UIView) -> UIImageView? {
        var dot: UIImageView? = nil
        for subview in view.subviews {
            if let imageView = subview as? UIImageView {
                dot = imageView
                break
            }
        }
        if dot == nil {
            dot = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: view.width, height: view.height)))
            dot?.backgroundColor = tableBoardBackgroundColor
            customDotImageView = dot
            view.addSubview(dot!)
        }
        return dot
    }

    private func updateDots() {
        guard showAddDots else { return }
        if let view = subviews.last, dot = imageViewForSubView(view) {
            if currentPage == subviews.count - 1 {
                dot.image = activeAddPageControlImage
            } else {
                dot.image = inactiveAddPageControlImage
            }
        }
    }
}
