//
//  OGDataProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/06.
//
//

import Foundation

protocol OGDataProviderProtocol: class {
    var cacheManager: OGDataCacheManagerProtocol { get set }
    var updateInterval: TimeInterval { get set }
    func fetchOGData(urlString: String, completion: ((OpenGraph.Data, Error?) -> Void)?) -> Task
    func deleteOGData(urlString: String, completion: ((Error?) -> Void)?)
    func deleteOGData(_ ogData: OpenGraphData, completion: ((Error?) -> Void)?)
    func cancelLoading(_ task: Task, shouldContinueDownloading: Bool)
}

@objc public final class OGDataProvider: NSObject, OGDataProviderProtocol {
    //MARK: Static constants
    @objc(sharedInstance)
    public static let shared = OGDataProvider()
        
    //MARK: - Properties
    private let downloader: OpenGraphDataDownloaderProtocol

    @objc public lazy var cacheManager: OGDataCacheManagerProtocol = OGDataCacheManager()
    
    init(downloader: OpenGraphDataDownloaderProtocol = OpenGraphDataDownloader(session: OGSession(configuration: .default))) {
        self.downloader = downloader
        super.init()
    }
    
    @objc public var updateInterval: TimeInterval {
        get { return cacheManager.updateInterval }
        set { cacheManager.updateInterval = newValue }
    }
    
    @discardableResult
    @objc public func fetchOGData(withURLString urlString: String, completion: ((OpenGraphData, Error?) -> Void)? = nil) -> Task {
        return fetchOGData(urlString: urlString) { completion?($0 as OpenGraphData, $1) }
    }
    
    @discardableResult
    @nonobjc public func fetchOGData(urlString: String, completion: ((OpenGraph.Data, Error?) -> Void)? = nil) -> Task {
        let task = Task()

        cacheManager.fetchOrInsertOGCacheData(url: urlString) { [weak self] cache in
            guard let me = self else { return }

            if let updateDate = cache.updateDate {
                completion?(cache.ogData, nil)
                if fabs(updateDate.timeIntervalSinceNow) < me.updateInterval {
                    return
                }
            }

            _ = me.downloader.fetchOGData(urlString: urlString, task: task) { [weak self] result in
                switch result {
                case let .success(data, isExpired):
                    if let me = self {
                        let cache = OGCacheData(ogData: data,
                                                createDate: cache.createDate,
                                                updateDate: Date())
                        me.cacheManager.updateIfNeeded(cache: cache)
                    }
                    if !isExpired {
                        completion?(data, nil)
                    }
                case let .failure(error, isExpired):
                    let ogData = cache.ogData
                    if case .htmlDecodeFaild? = error as? OGSession.Error, let me = self {
                        let newCache = OGCacheData(ogData: ogData,
                                                   createDate: cache.createDate,
                                                   updateDate: Date())
                        me.cacheManager.updateIfNeeded(cache: newCache)
                    }
                    if !isExpired {
                        completion?(ogData, nil)
                    }
                }
            }
        }

        return task
    }
    
    @objc public func deleteOGData(urlString: String, completion: ((Error?) -> Void)? = nil) {
        cacheManager.fetchOGCacheData(url: urlString) { [weak self] cache in
            guard let cache = cache else {
                completion?(NSError(domain: "no object matches with \"\(urlString)\"", code: 9999, userInfo: nil))
                return
            }
            self?.deleteOGData(cache.ogData, completion: completion)
        }
    }

    @objc public func deleteOGData(_ ogData: OpenGraphData, completion: ((Error?) -> Void)? = nil) {
        deleteOGData(ogData as OpenGraph.Data, completion: completion)
    }
    
    @nonobjc public func deleteOGData(_ ogData: OpenGraph.Data, completion: ((Error?) -> Void)? = nil) {
        let cache = OGCacheData(ogData: ogData, createDate: Date(), updateDate: nil)
        cacheManager.deleteOGCacheDate(cache: cache, completion: completion)
    }
    
    @objc public func cancelLoading(_ task: Task, shouldContinueDownloading: Bool) {
        task.expire(shouldContinueDownloading: shouldContinueDownloading)
    }
}
