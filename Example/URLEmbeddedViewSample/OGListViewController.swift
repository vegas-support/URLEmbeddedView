//
//  OGListViewController.swift
//  URLEmbeddedViewSample
//
//  Created by Taiki Suzuki on 2016/03/15.
//  Copyright © 2016年 Taiki Suzuki. All rights reserved.
//

import UIKit
import SafariServices
import URLEmbeddedView

class OGListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let urlList: [String] = [
        "https://onboardmag.com/videos/web-series/sixty-minute-sessions-karl-anton-svensson.html",
        "https://www.youtube.com/watch?v=R3Jtl-pPLtQ",
        "https://github.com/marty-suzuki/URLEmbeddedView",
        "https://www.youtube.com/watch?v=IvUU8joBb1Q",
        "https://www.instagram.com/p/_0sZrcM81K/?taken-by=superstreet",
        "https://twitter.com/KidFromTheIsles/status/596761535541694464",
        "https://twitter.com/search?f=images&vertical=default&q=%23lancerevolution&src=typd",
        "http://www.hottoys.com.hk/productDetail.php?productID=256",
        "http://www.linkinpark.com"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "OGListCell", bundle: nil), forCellReuseIdentifier: "OGListCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension OGListViewController {
    @IBAction func didTapBackButton(_ sender: AnyObject?) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapClearButton(_ sender: AnyObject) {
        OGImageProvider.shared.clearMemoryCache()
    }
}

extension OGListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OGListCell") as! OGListCell
        let url = urlList[(indexPath as NSIndexPath).row]
        cell.embeddedView.load(urlString: url)
        cell.label.text = url
        cell.selectionStyle = .none
        cell.embeddedView.didTapHandler = { [weak self] embeddedView, URL in
            guard let URL = URL else { return }
            if #available(iOS 9.0, *) {
                self?.present(SFSafariViewController(url: URL), animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urlList.count
    }
}

extension OGListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}
