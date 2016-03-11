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
    
    override func loadImage(url: String, uuidString: String, completion: ((UIImage?, String, NSError?) -> Void)? = nil) {
        activityView.startAnimating()
        super.loadImage(url, uuidString: uuidString) { [weak self] in
            self?.activityView.stopAnimating()
            completion?($0, $1, $2)
        }
    }
}

