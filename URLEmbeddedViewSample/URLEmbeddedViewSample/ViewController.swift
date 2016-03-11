//
//  ViewController.swift
//  URLEmbeddedViewSample
//
//  Created by 鈴木大貴 on 2016/03/06.
//  Copyright © 2016年 鈴木大貴. All rights reserved.
//

import UIKit
import SafariServices
import URLEmbeddedView

class ViewController: UIViewController {

    @IBOutlet weak var embeddedView: URLEmbeddedView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textView.text = "https://github.com/szk-atmosphere/URLEmbeddedView"
        
        embeddedView.textProvider[.Title].font = .boldSystemFontOfSize(20)
        
        embeddedView.didTapHandler = { [weak self] embeddedView, URL in
            guard let URL = URL else { return }
            self?.presentViewController(SFSafariViewController(URL: URL), animated: true, completion: nil)
        }

        
        var dict: [String : String] = [:]
        (0..<10000).forEach { i in
            let a = NSUUID().UUIDString as String
            dict[a.substringToIndex(a.startIndex.advancedBy(2))] = a
        }
        
        print(Array(dict.keys).count)
        
        (0..<16).forEach { i in
            (0..<16).forEach { j in
                let directoryName = String(format: "%x%x", i, j)
                print(directoryName)
            }
        }
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