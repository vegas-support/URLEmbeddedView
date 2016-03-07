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

    @IBOutlet weak var embeddedView: URLEmbeddedView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textView.text = "https://github.com/szk-atmosphere"
        
        embeddedView.textProvider[.Title].font = .boldSystemFontOfSize(20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapLoadButton(sender: AnyObject) {
        guard let urlString = textView.text else { return }
        embeddedView.loadURL(urlString)
    }
}