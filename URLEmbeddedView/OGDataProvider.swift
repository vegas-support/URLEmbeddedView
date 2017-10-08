//
//  OGDataProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/06.
//
//

import Foundation

public final class OGDataProvider: NSObject {
    //MARK: Static constants
    @objc(sharedInstance)
    public static let shared = OGDataProvider()
        
    //MARK: - Properties
    private let session = OGSession(configuration: .default)
    
    private override init() {
        super.init()
    }
    
    @objc public var updateInterval: TimeInterval {
        get { return OGDataCacheManager.shared.updateInterval }
        set { OGDataCacheManager.shared.updateInterval = newValue }
    }
    
    @discardableResult
    @objc public func fetchOGData(urlString: String, completion: ((OGData, Error?) -> Void)? = nil) -> String? {
        let ogData = OGData.fetchOrInsertOGData(url: urlString)
        if !ogData.sourceUrl.isEmpty {
            completion?(ogData, nil)
            if fabs(ogData.updateDate.timeIntervalSinceNow) < updateInterval {
                return nil
            }
        }
        ogData.sourceUrl = urlString
        guard let url = URL(string: urlString) else {
            completion?(ogData, NSError(domain: "can not create NSURL with \"\(urlString)\"", code: 9999, userInfo: nil))
            return nil
        }

        let uuid: UUID
        let failure: (OGSession.Error, Bool) -> Void = { error, isExpired in
            if !isExpired { completion?(ogData, error) }
        }
        if url.host?.contains("www.youtube.com") == true {
            guard let request = YoutubeEmbedRequest(url: url) else {
                completion?(ogData, NSError(domain: "can not create NSURL with \"\(urlString)\"", code: 9999, userInfo: nil))
                return nil
            }
            uuid = session.send(request, success: { youtube, isExpired in
                ogData.setValue(youtube)
                DispatchQueue.global().async { ogData.save() }
                if !isExpired { completion?(ogData, nil) }
            }, failure: failure)
        } else {
            let request = HtmlRequest(url: url)
            uuid = session.send(request, success: { html, isExpired in
                ogData.setValue(html)
                DispatchQueue.global().async { ogData.save() }
                if !isExpired { completion?(ogData, nil) }
            }, failure: failure)
        }
        return uuid.uuidString
    }
    
    @objc public func deleteOGData(urlString: String, completion: ((NSError?) -> Void)? = nil) {
        guard let ogData = OGData.fetchOGData(url: urlString) else {
            completion?(NSError(domain: "no object matches with \"\(urlString)\"", code: 9999, userInfo: nil))
            return
        }
        deleteOGData(ogData, completion: completion)
    }
    
    @objc public func deleteOGData(_ ogData: OGData, completion: ((NSError?) -> Void)? = nil) {
        OGDataCacheManager.shared.delete(ogData, completion: completion)
    }
    
    func cancelLoad(_ uuidString: String, stopTask: Bool) {
        session.cancelLoad(withUUIDString: uuidString, stopTask: stopTask)
    }
}
