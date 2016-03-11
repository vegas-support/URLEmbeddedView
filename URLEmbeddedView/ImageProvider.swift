//
//  ImageProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import Foundation

final class ImageProvider {
    //MARK: - Static constants
    static let sharedInstance = ImageProvider()
    
    //MARK: - Properties
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    func loadImage(ogData: OGData, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        let url = ogData.imageUrl
        let uuidString = ogData.imageUUID
        guard let URL = NSURL(string: url) else {
            completion?(nil, NSError(domain: "can not create NSURL with \(url)", code: 9999, userInfo: nil))
            return
        }
        if !uuidString.isEmpty {
            if let image = ImageCacheManager.sharedInstance.cachedImage(uuidString: uuidString) {
                completion?(image, nil)
                return
            }
        }
        session.dataTaskWithURL(URL) { data, response, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            guard let data = data else {
                completion?(nil, NSError(domain: "can not fetch image data with \(url)", code: 9999, userInfo: nil))
                return
            }
            guard let image = UIImage(data: data) else {
                completion?(nil, NSError(domain: "can not fetch image with \(url)", code: 9999, userInfo: nil))
                return
            }
            ogData.imageUUID = uuidString.isEmpty ? NSUUID().UUIDString : uuidString
            if ImageCacheManager.sharedInstance.storeImage(image, data: data, uuidString: ogData.imageUUID) {
                ogData.save()
            }
            completion?(image, nil)
        }.resume()
    }
}