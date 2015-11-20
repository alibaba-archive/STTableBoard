//
//  ViewController.swift
//  STTableBoard
//
//  Created by DangGu on 15/10/25.
//  Copyright © 2015年 Donggu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let table = STTableBoard(frame: view.frame, numberOfPage: 3)
        view.addSubview(table)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

