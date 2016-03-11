//
//  UIImageView+Load.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/08.
//
//

import UIKit

extension UIImageView {
    func loadImage(url: String, uuidString: String, completion: ((UIImage?, String, NSError?) -> Void)? = nil) {
        OGImageProvider.sharedInstance.loadImage(url, uuidString: uuidString) { [weak self] image, uuidString, error in
            dispatch_async(dispatch_get_main_queue()) {
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
}