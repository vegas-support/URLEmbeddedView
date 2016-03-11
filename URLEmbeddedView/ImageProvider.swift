//
//  ImageProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import Foundation

public final class ImageProvider {
    //MARK: - Static constants
    public static let sharedInstance = ImageProvider()
    
    //MARK: - Properties
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
}

extension ImageProvider {
    public func loadImage(url: String, uuidString: String, completion: ((UIImage?, String, NSError?) -> Void)? = nil) {
        guard let URL = NSURL(string: url) else {
            completion?(nil, uuidString, NSError(domain: "can not create NSURL with \(url)", code: 9999, userInfo: nil))
            return
        }
        if !uuidString.isEmpty {
            if let image = ImageCacheManager.sharedInstance.cachedImage(uuidString: uuidString) {
                completion?(image, uuidString, nil)
                return
            }
        }
        session.dataTaskWithURL(URL) { data, response, error in
            if let error = error {
                completion?(nil, uuidString, error)
                return
            }
            guard let data = data else {
                completion?(nil, uuidString, NSError(domain: "can not fetch image data with \(url)", code: 9999, userInfo: nil))
                return
            }
            guard let image = UIImage(data: data) else {
                completion?(nil, uuidString, NSError(domain: "can not fetch image with \(url)", code: 9999, userInfo: nil))
                return
            }
            let newUUIDString = uuidString.isEmpty ? NSUUID().UUIDString : uuidString
            ImageCacheManager.sharedInstance.storeImage(image, data: data, uuidString: newUUIDString)
            completion?(image, newUUIDString, nil)
        }.resume()
    }
    
    public func clearMemoryCache() {
        ImageCacheManager.sharedInstance.clearMemoryCache()
    }
    
    public func clearAllCache() {
        ImageCacheManager.sharedInstance.clearAllCache()
    }
}