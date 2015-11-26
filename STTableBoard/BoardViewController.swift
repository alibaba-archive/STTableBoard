//
//  BoardViewController.swift
//  STTableBoard
//
//  Created by DangGu on 15/11/25.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRectMake(30, 20, 315, 627)
        let board = STBoardView(frame: frame)
        view.addSubview(board)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
