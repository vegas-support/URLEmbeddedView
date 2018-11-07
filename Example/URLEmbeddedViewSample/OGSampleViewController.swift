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
            if #available(iOS 9.0, *) {
                self?.present(SFSafariViewController(url: URL), animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private struct KeyboardInfo: NoticeUserInfoDecodable {
        #if swift(>=4.2)
        typealias UIViewAnimationOptions = UIView.AnimationOptions
        #endif

        let animationDuration: TimeInterval
        let animationOptions: UIViewAnimationOptions
        let frame: CGRect

        init?(info: [AnyHashable: Any]) {
            #if swift(>=4.2)
            animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
            animationOptions = UIView.AnimationOptions(rawValue:info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0)
            frame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
            #else
            animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
            animationOptions = UIViewAnimationOptions(rawValue:info[UIKeyboardAnimationCurveUserInfoKey] as? UInt ?? 0)
            frame = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
            #endif
        }
    }
    
    private struct UIKeyboardWillShow: NoticeType {
        typealias InfoType = KeyboardInfo
        #if swift(>=4.2)
        static let name: Notification.Name = UIResponder.keyboardWillShowNotification
        #else
        static let name: Notification.Name = .UIKeyboardWillShow
        #endif
    }
    
    private struct UIKeyboardWillHide: NoticeType {
        typealias InfoType = KeyboardInfo
        #if swift(>=4.2)
        static let name: Notification.Name = UIResponder.keyboardWillHideNotification
        #else
        static let name: Notification.Name = .UIKeyboardWillHide
        #endif
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
        .disposed(by: pool)
        
        UIKeyboardWillHide.observe { [weak self] keyboard in
            self?.embeddedViewBottomConstraint.constant = 0
            UIView.animate(withDuration: keyboard.animationDuration, delay: 0, options:  keyboard.animationOptions, animations: {
                self?.view.layoutIfNeeded()
            }, completion:  nil)
        }
        .disposed(by: pool)
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
        embeddedView.load(urlString: urlString) { result in
            if result.error != nil {
                return
            }

            OGDataProvider.shared.fetchOGData(withURLString: urlString) { [weak self] ogData, error in
                if let _ = error {
                    return
                }
                let text = "- sourceUrl        = \(ogData.sourceUrl as URL?)\n"
                    + "- url              = \(ogData.url as URL?)\n"
                    + "- siteName         = \(ogData.siteName as String?)\n"
                    + "- pageTitle        = \(ogData.pageTitle as String?)\n"
                    + "- pageType         = \(ogData.pageType as String?)\n"
                    + "- pageDescription  = \(ogData.pageDescription as String?)\n"
                    + "- imageUrl         = \(ogData.imageUrl as URL?)\n"
                DispatchQueue.main.async {
                    self?.textView.text = text
                }
            }
        }
    }
}
