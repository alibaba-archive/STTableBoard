//
//  STTableBoard.swift
//  STTableBoard
//
//  Created by DangGu on 15/10/27.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

let leading: CGFloat  = 30.0
let trailing: CGFloat = leading
let top: CGFloat = 20.0
let bottom: CGFloat = top
let pageSpacing: CGFloat = leading / 2
let overlap: CGFloat = pageSpacing * 3

class STTableBoard: UIView {
    
    var numberOfPage: Int = 1
    var views: [STTableView] = []
    var currentPage: Int = 0
    
    private var scrollView: UIScrollView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, numberOfPage: Int) {
        self.init(frame: frame)
        self.numberOfPage = numberOfPage
        setupProperty()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupProperty() {
        let viewWidth = CGRectGetWidth(frame)
        let viewHeight = CGRectGetHeight(frame)
        let contentViewWidth = viewWidth + (viewWidth - overlap) * CGFloat(numberOfPage - 1)
        
        scrollView = UIScrollView(frame: frame)
        scrollView.contentSize = CGSize(width: contentViewWidth, height: viewHeight)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false
        addSubview(scrollView)
        
        views = []
        for i in 0..<numberOfPage {
            let width = CGRectGetWidth(frame) - (leading + trailing)
            let height = CGRectGetHeight(frame) - (top + bottom)
            let x = leading + CGFloat(i) * (width + pageSpacing)
            let y = top
            let cardViewFrame = CGRectMake(x, y, width, height)
            
            let cardView: STTableView = STTableView(frame: cardViewFrame)
            cardView.backgroundColor = UIColor.blueColor()
            views.append(cardView)
        }
        
        views.forEach { (cardView) -> () in
            scrollView.addSubview(cardView)
        }
        
    }

    func scrollToActualPage(scrollView: UIScrollView, offsetX: CGFloat) {
        let pageOffset = CGRectGetWidth(scrollView.frame) - overlap
        let proportion = offsetX / pageOffset
        let page = Int(proportion)
        let actualPage = (offsetX - pageOffset * CGFloat(page)) > (pageOffset * 3 / 4) ?  page + 1 : page
        currentPage = actualPage
        
        UIView.animateWithDuration(0.33) { () -> Void in
            scrollView.contentOffset = CGPoint(x: pageOffset * CGFloat(actualPage), y: 0)
        }
    }
    
    func scrollToPage(scrollView: UIScrollView, page: Int, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageOffset = CGRectGetWidth(scrollView.frame) - overlap
        UIView.animateWithDuration(0.33) { () -> Void in
            scrollView.contentOffset = CGPoint(x: pageOffset * CGFloat(page), y: 0)
        }
        targetContentOffset.memory = CGPoint(x: pageOffset * CGFloat(page), y: 0)
        currentPage = page
    }
}

extension STTableBoard : UIScrollViewDelegate {
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToActualPage(scrollView, offsetX: scrollView.contentOffset.x)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x != 0 {
            if velocity.x < 0 && currentPage > 0{
                scrollToPage(scrollView, page: currentPage - 1, targetContentOffset: targetContentOffset)
            } else if velocity.x > 0 && currentPage < numberOfPage - 1{
                scrollToPage(scrollView, page: currentPage + 1, targetContentOffset: targetContentOffset)
            }
            
        }
    }
}
