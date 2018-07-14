//
//  OGImageProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import Foundation

@objc public final class OGImageProvider: NSObject {

    //MARK: - Static constants
    @objc(sharedInstance)
    public static let shared = OGImageProvider()
    
    //MARK: - Properties
    private let session = OGSession(configuration: .default)
    private let cacheManager = OGImageCacheManager()
    
    override init() {
        super.init()
    }

    @objc public func loadImage(withURLString urlString: String, completion: ((UIImage?, Error?) -> Void)? = nil) -> Task? {
        return loadImage(withURLString: urlString) { completion?($0.value, $0.error) }
    }
    
    @nonobjc public func loadImage(withURLString urlString: String, completion: ((Result<UIImage>) -> Void)? = nil) -> Task? {
        guard let url = URL(string: urlString) else {
            completion?(.failure(URLEmbeddedViewError.invalidURLString(urlString)))
            return nil
        }
        if !urlString.isEmpty {
            if let image = cacheManager.cachedImage(urlString: urlString) {
                completion?(.success(image))
                return nil
            }
        }
        let request = ImageRequest(url: url)
        return session.send(request, success: { [weak self] value, isExpired in
            self?.cacheManager.storeImage(value.1, data: value.0, urlString: urlString)
            if !isExpired { completion?(.success(value.1)) }
        }, failure: { error, isExpired in
            if !isExpired { completion?(.failure(error)) }
        })
    }
    
    @objc public func clearMemoryCache() {
        cacheManager.clearMemoryCache()
    }
    
    @objc public func clearAllCache() {
        cacheManager.clearAllCache()
    }
    
    func cancelLoading(_ task: Task, shouldContinueDownloading: Bool) {
        task.expire(shouldContinueDownloading: shouldContinueDownloading)
    }
}
