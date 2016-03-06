//
//  URLImageView.swift
//  Pods
//
//  Created by 鈴木大貴 on 2016/03/07.
//
//

import UIKit
import MisterFusion

class URLImageView: UIImageView {
    private let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    init() {
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        activityView.hidesWhenStopped = true
        addLayoutSubview(activityView, andConstraints:
            activityView.Width |=| 30,
            activityView.Height |=| 30,
            activityView.CenterX,
            activityView.CenterY
        )
    }
    
    func loadImage(url: String, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        activityView.startAnimating()
        ImageProvider.sharedInstance.loadImage(url) { [weak self] image, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                self?.activityView.stopAnimating()
                self?.image = image
                completion?(image, nil)
            }
        }
    }
}
