//
//  ViewController.swift
//  URLEmbeddedViewSample
//
//  Created by 鈴木大貴 on 2016/03/06.
//  Copyright © 2016年 鈴木大貴. All rights reserved.
//

import UIKit
import URLEmbeddedView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let URL = NSURL(string: "https://github.com/szk-atmosphere/SAHistoryNavigationViewController")!
        OGDataProvider.sharedInstance.fetchOGData(URL: URL) { ogData, error in
            print(ogData)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
