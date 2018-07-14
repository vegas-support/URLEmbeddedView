//
//  OGDataProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/06.
//
//

import Foundation

@objc public final class OGDataProvider: NSObject {
    //MARK: Static constants
    @objc(sharedInstance)
    public static let shared = OGDataProvider()
        
    //MARK: - Properties
    private let downloader: OpenGraphDataDownloader
    
    init(downloader: OpenGraphDataDownloader = .init(session: OGSession(configuration: .default))) {
        self.downloader = downloader
        super.init()
    }
    
    @objc public var updateInterval: TimeInterval {
        get { return OGDataCacheManager.shared.updateInterval }
        set { OGDataCacheManager.shared.updateInterval = newValue }
    }
    
    @discardableResult
    @objc public func fetchOGDataWithURLString(_ urlString: String, completion: ((OpenGraphData, Error?) -> Void)? = nil) -> Task {
        return fetchOGData(withURLString: urlString) { completion?($0 as OpenGraphData, $1) }
    }
    
    @discardableResult
    @nonobjc public func fetchOGData(withURLString urlString: String, completion: ((OpenGraph.Data, Error?) -> Void)? = nil) -> Task {
        let task = Task()
        OGData.fetchOrInsertOGData(url: urlString) { [weak self] ogData in
            guard let me = self else { return }
            if !ogData.sourceUrl.isEmpty {
                completion?(.init(ogData: ogData), nil)
                if fabs(ogData.updateDate.timeIntervalSinceNow) < me.updateInterval {
                    return
                }
            }
            ogData.sourceUrl = urlString

            me.downloader.fetchOGData(urlString: urlString, task: task) { result in
                ogData.managedObjectContext?.perform {
                    switch result {
                    case let .success(data, isExpired):
                        if ogData.update(with: data) {
                            ogData.save()
                        }
                        if !isExpired { completion?(data, nil) }
                    case let .failure(_, isExpired):
                        if !isExpired { completion?(.init(ogData: ogData), nil) }
                    }
                }
            }
        }
        return task
    }
    
    @objc public func deleteOGData(urlString: String, completion: ((NSError?) -> Void)? = nil) {
        OGData.fetchOGData(url: urlString) { [weak self] ogData in
            guard let ogData = ogData else {
                completion?(NSError(domain: "no object matches with \"\(urlString)\"", code: 9999, userInfo: nil))
                return
            }
            self?.deleteOGData(ogData, completion: completion)
        }
    }
    
    @objc public func deleteOGData(_ ogData: OGData, completion: ((NSError?) -> Void)? = nil) {
        OGDataCacheManager.shared.delete(ogData, completion: completion)
    }
    
    func cancelLoading(_ task: Task, shouldContinueDownloading: Bool) {
        task.expire(shouldContinueDownloading: shouldContinueDownloading)
    }
}
