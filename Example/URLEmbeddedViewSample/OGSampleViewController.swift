//
//  OGSampleViewController.swift
//  URLEmbeddedViewSample
//
//  Created by Taiki Suzuki on 2016/03/06.
//  Copyright © 2016年 Taiki Suzuki. All rights reserved.
//

import UIKit
import SafariServices
import URLEmbeddedView
import NoticeObserveKit

class OGSampleViewController: UIViewController {

    @IBOutlet weak var embeddedView: URLEmbeddedView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var embeddedViewBottomConstraint: NSLayoutConstraint!
    
    private var pool = NoticeObserverPool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        automaticallyAdjustsScrollViewInsets = false
        
        searchBar.text = "https://github.com/marty-suzuki/URLEmbeddedView"
        searchBar.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        textView.textContainer.lineFragmentPadding = 0
        
        OGDataProvider.shared.updateInterval = 10.days
        
        embeddedView.textProvider[.title].font = .boldSystemFont(ofSize: 18)
        embeddedView.textProvider[.description].fontColor = .lightGray
        embeddedView.textProvider[.domain].fontColor = .lightGray
        
        embeddedView.didTapHandler = { [weak self] embeddedView, URL in
            guard let URL = URL else { return }
            self?.present(SFSafariViewController(url: URL), animated: true, completion: nil)
        }
    }
    
    private struct KeyboardInfo: NoticeUserInfoDecodable {
        let animationDuration: TimeInterval
        let animationOptions: UIViewAnimationOptions
        let frame: CGRect
        init?(info: [AnyHashable: Any]) {
            animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
            animationOptions = UIViewAnimationOptions(rawValue:info[UIKeyboardAnimationCurveUserInfoKey] as? UInt ?? 0)
            frame = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        }
    }
    
    private struct UIKeyboardWillShow: NoticeType {
        typealias InfoType = KeyboardInfo
        static let name: Notification.Name = .UIKeyboardWillShow
    }
    
    private struct UIKeyboardWillHide: NoticeType {
        typealias InfoType = KeyboardInfo
        static let name: Notification.Name = .UIKeyboardWillHide
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pool = NoticeObserverPool()
        
        UIKeyboardWillShow.observe { [weak self] keyboard in
            self?.embeddedViewBottomConstraint.constant = keyboard.frame.size.height + 12
            UIView.animate(withDuration: keyboard.animationDuration, delay: 0, options:  keyboard.animationOptions, animations: {
                self?.view.layoutIfNeeded()
            }, completion:  nil)
        }
        .addObserverTo(pool)
        
        UIKeyboardWillHide.observe { [weak self] keyboard in
            self?.embeddedViewBottomConstraint.constant = 0
            UIView.animate(withDuration: keyboard.animationDuration, delay: 0, options:  keyboard.animationOptions, animations: {
                self?.view.layoutIfNeeded()
            }, completion:  nil)
        }
        .addObserverTo(pool)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pool = NoticeObserverPool()
        searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapBackButton(_ sender: AnyObject?) {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension OGSampleViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let urlString = searchBar.text else { return }
        embeddedView.loadURL(urlString) {
            if let _ = $0 {
                return
            }
            OGDataProvider.shared.fetchOGData(urlString: urlString) { [weak self] ogData, error in
                if let _ = error {
                    return
                }
                let text = "- sourceUrl        = \(ogData.sourceUrl)\n"
                    + "- url              = \(ogData.url)\n"
                    + "- siteName         = \(ogData.siteName)\n"
                    + "- pageTitle        = \(ogData.pageTitle)\n"
                    + "- pageType         = \(ogData.pageType)\n"
                    + "- pageDescription  = \(ogData.pageDescription)\n"
                    + "- imageUrl         = \(ogData.imageUrl)\n"
                    + "- createDate       = \(ogData.createDate)\n"
                    + "- updateDate       = \(ogData.updateDate)\n"
                DispatchQueue.main.async {
                    self?.textView.text = text
                }
            }
        }
    }
}
