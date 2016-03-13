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
        
        embeddedView.textProvider[.Title].font = .boldSystemFontOfSize(18)
        embeddedView.textProvider[.Description].fontColor = .lightGrayColor()
        embeddedView.textProvider[.Domain].fontColor = .lightGrayColor()
        
        embeddedView.didTapHandler = { [weak self] embeddedView, URL in
            guard let URL = URL else { return }
            self?.presentViewController(SFSafariViewController(URL: URL), animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    @IBAction func didTapBackButton(sender: AnyObject?) {
        navigationController?.popViewControllerAnimated(true)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let urlString = searchBar.text else { return }
        embeddedView.loadURL(urlString) {
            if let _ = $0 {
                return
            }
            OGDataProvider.sharedInstance.fetchOGData(url: urlString) { [weak self] ogData, error in
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
                    + "- imageUUID        = \(ogData.imageUUID)\n"
                    + "- faviconImageUUID = \(ogData.faviconImageUUID)\n"
                    + "- createDate       = \(ogData.createDate)\n"
                    + "- updateDate       = \(ogData.updateDate)\n"
                dispatch_async(dispatch_get_main_queue()) {
                    self?.textView.text = text
                }
            }
        }
    }
}

extension ViewController {
    private struct KeyboardInfo {
        let animationDuration: NSTimeInterval
        let animationOptions: UIViewAnimationOptions
        let frame: CGRect
        init(userInfo: [NSObject : AnyObject]?) {
            animationDuration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval ?? 0
            animationOptions = UIViewAnimationOptions(rawValue:userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt ?? 0)
            frame = (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() ?? .zero
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboard = KeyboardInfo(userInfo: notification.userInfo)
        embeddedViewBottomConstraint.constant = keyboard.frame.size.height + 12
        UIView.animateWithDuration(keyboard.animationDuration, delay: 0, options:  keyboard.animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion:  nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboard = KeyboardInfo(userInfo: notification.userInfo)
        embeddedViewBottomConstraint.constant = 0
        UIView.animateWithDuration(keyboard.animationDuration, delay: 0, options:  keyboard.animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion:  nil)
    }
}