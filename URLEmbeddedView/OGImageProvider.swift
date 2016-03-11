//
//  OGImageProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import Foundation

public final class OGImageProvider: NSObject {
    //MARK: - Static constants
    public static let sharedInstance = OGImageProvider()
    
    //MARK: - Properties
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    private override init() {
        super.init()
    }
}

extension OGImageProvider {
    public func loadImage(url url: String, uuidString: String, completion: ((UIImage?, String, NSError?) -> Void)? = nil) {
        guard let URL = NSURL(string: url) else {
            completion?(nil, uuidString, NSError(domain: "can not create NSURL with \(url)", code: 9999, userInfo: nil))
            return
        }
        if !uuidString.isEmpty {
            if let image = OGImageCacheManager.sharedInstance.cachedImage(uuidString: uuidString) {
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
            OGImageCacheManager.sharedInstance.storeImage(image, data: data, uuidString: newUUIDString)
            completion?(image, newUUIDString, nil)
        }.resume()
    }
    
    public func clearMemoryCache() {
        OGImageCacheManager.sharedInstance.clearMemoryCache()
    }
    
    public func clearAllCache() {
        OGImageCacheManager.sharedInstance.clearAllCache()
    }
}