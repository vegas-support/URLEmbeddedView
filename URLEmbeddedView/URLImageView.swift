//
//  URLImageView.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import UIKit
import MisterFusion

final class URLImageView: UIImageView {
    private let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private var task: NSURLSessionDataTask?
    var activityViewHidden: Bool = false
    
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
    
    func loadImage(url: String, uuidString: String, completion: ((UIImage?, String, NSError?) -> Void)? = nil) {
        cancelLoadImage()
        if !activityViewHidden {
            activityView.startAnimating()
        }
        task = OGImageProvider.sharedInstance.loadImage(url: url, uuidString: uuidString) { [weak self] image, uuidString, error in
            self?.task = nil
            dispatch_async(dispatch_get_main_queue()) {
                if self?.activityViewHidden == false {
                    self?.activityView.stopAnimating()
                }
                if let error = error {
                    self?.image = nil
                    completion?(nil, uuidString, error)
                    return
                }
                self?.image = image
                completion?(image, uuidString, nil)
            }
        }
    }
    
    func cancelLoadImage() {
        if !activityViewHidden {
            activityView.stopAnimating()
        }
        task?.cancel()
        task = nil
    }
}

