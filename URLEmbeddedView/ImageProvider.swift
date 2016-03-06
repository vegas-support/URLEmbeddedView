//
//  ImageProvider.swift
//  Pods
//
//  Created by 鈴木大貴 on 2016/03/07.
//
//

import Foundation

class ImageProvider {
    static let sharedInstance = ImageProvider()
    
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    func loadImage(url: String, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        guard let URL = NSURL(string: url) else { return }
        session.dataTaskWithURL(URL) { data, response, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            guard let data = data else {
                completion?(nil, nil)
                return
            }
            completion?(UIImage(data: data), nil)
        }.resume()
    }
}