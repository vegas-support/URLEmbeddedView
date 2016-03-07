//
//  UIImageView+Load.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/08.
//
//

import UIKit

extension UIImageView {
    func loadImage(url: String, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        ImageProvider.sharedInstance.loadImage(url) { [weak self] image, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                self?.image = image
                completion?(image, nil)
            }
        }
    }
}