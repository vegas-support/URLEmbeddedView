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

class OGSampleViewController: UIViewController {

    @IBOutlet weak var embeddedView: URLEmbeddedView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var embeddedViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        automaticallyAdjustsScrollViewInsets = false
        
        searchBar.text = "https://github.com/szk-atmosphere/URLEmbeddedView"
        searchBar.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        textView.textContainer.lineFragmentPadding = 0
        
        OGDataProvider.sharedInstance.updateInterval = 10.days
        
        embeddedView.textProvider[.title].font = .boldSystemFont(ofSize: 18)
        embeddedView.textProvider[.description].fontColor = .lightGray
        embeddedView.textProvider[.domain].fontColor = .lightGray
        
        embeddedView.didTapHandler = { [weak self] embeddedView, URL in
            guard let URL = URL else { return }
            self?.present(SFSafariViewController(url: URL), animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(OGSampleViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OGSampleViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension OGSampleViewController {
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
            OGDataProvider.sharedInstance.fetchOGData(urlString: urlString) { [weak self] ogData, error in
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

extension OGSampleViewController {
    fileprivate struct KeyboardInfo {
        let animationDuration: TimeInterval
        let animationOptions: UIViewAnimationOptions
        let frame: CGRect
        init(userInfo: [AnyHashable: Any]?) {
            animationDuration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
            animationOptions = UIViewAnimationOptions(rawValue:userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt ?? 0)
            frame = (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let keyboard = KeyboardInfo(userInfo: (notification as NSNotification).userInfo)
        embeddedViewBottomConstraint.constant = keyboard.frame.size.height + 12
        UIView.animate(withDuration: keyboard.animationDuration, delay: 0, options:  keyboard.animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion:  nil)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let keyboard = KeyboardInfo(userInfo: (notification as NSNotification).userInfo)
        embeddedViewBottomConstraint.constant = 0
        UIView.animate(withDuration: keyboard.animationDuration, delay: 0, options:  keyboard.animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion:  nil)
    }
}
