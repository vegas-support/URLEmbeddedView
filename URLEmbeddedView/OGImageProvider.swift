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
    public func loadImage(urlString urlString: String, completion: ((UIImage?, NSError?) -> Void)? = nil) -> NSURLSessionDataTask? {
        guard let URL = NSURL(string: urlString) else {
            completion?(nil, NSError(domain: "can not create NSURL with \(urlString)", code: 9999, userInfo: nil))
            return nil
        }
        if !urlString.isEmpty {
            if let image = OGImageCacheManager.sharedInstance.cachedImage(urlString: urlString) {
                completion?(image, nil)
                return nil
            }
        }
        let task = session.dataTaskWithURL(URL) { data, response, error in
            if let error = error {
                completion?(nil,  error)
                return
            }
            guard let data = data else {
                completion?(nil, NSError(domain: "can not fetch image data with \(urlString)", code: 9999, userInfo: nil))
                return
            }
            guard let image = UIImage(data: data) else {
                completion?(nil, NSError(domain: "can not fetch image with \(urlString)", code: 9999, userInfo: nil))
                return
            }
            OGImageCacheManager.sharedInstance.storeImage(image, data: data, urlString: urlString)
            completion?(image, nil)
        }
        task.resume()
        return task
    }
    
    public func clearMemoryCache() {
        OGImageCacheManager.sharedInstance.clearMemoryCache()
    }
    
    public func clearAllCache() {
        OGImageCacheManager.sharedInstance.clearAllCache()
    }
}