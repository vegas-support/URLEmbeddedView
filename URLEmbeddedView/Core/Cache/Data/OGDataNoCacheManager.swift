//
//  OGDataNoCacheManager.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2018/07/15.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

@objc public final class OGDataNoCacheManager: NSObject, OGDataCacheManagerProtocol {

    public var updateInterval: TimeInterval

    public override init() {
        updateInterval = 0
        super.init()
    }

    public func fetchOrInsertOGCacheData(url: String, completion: @escaping (OGCacheData) -> ()) {
        let ogData = OpenGraph.Data(imageUrl: nil,
                                    pageDescription: nil,
                                    pageTitle: nil,
                                    pageType: nil,
                                    siteName: nil,
                                    sourceUrl: URL(string: url),
                                    url: nil)
        let cache = OGCacheData(ogData: ogData, createDate: Date(), updateDate: nil)
        completion(cache)
    }

    public func fetchOGCacheData(url: String, completion: @escaping (OGCacheData?) -> ()) {
        completion(nil)
    }

    public func updateIfNeeded(cache: OGCacheData) {
        // do nothing
    }

    public func deleteOGCacheDate(cache: OGCacheData, completion: ((Error?) -> Void)?) {
        completion?(nil)
    }
}
