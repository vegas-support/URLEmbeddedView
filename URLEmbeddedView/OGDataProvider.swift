//
//  OGDataProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/06.
//
//

import Foundation
import Kanna
import WebKit

public final class OGDataProvider: NSObject {
    //MARK: Static constants
    public static let sharedInstance = OGDataProvider()
    private static let UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Safari/601.1.42"
    private static let MetaTagKey = "meta"
    private static let PropertyKey = "property"
    private static let ContentKey = "content"
    private static let PropertyPrefix = "og:"
    
    //MARK: - Properties
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    private override init() {
        super.init()
    }
}

extension OGDataProvider {
    public func fetchOGData(url url: String, completion: ((OGData, NSError?) -> Void)? = nil) {
        let ogData = OGData.fetchOrInsertOGData(url: url)
        if !ogData.sourceUrl.isEmpty {
            completion?(ogData, nil)
        }
        ogData.sourceUrl = url
        guard let URL = NSURL(string: url) else {
            completion?(ogData, NSError(domain: "can not create NSURL with \"\(url)\"", code: 9999, userInfo: nil))
            return
        }
        let request = NSMutableURLRequest(URL: URL)
        request.setValue(self.dynamicType.UserAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 5
        session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                completion?(ogData, error)
                return
            }
            guard let data = data,
                  let html = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding),
                  let header = html.head else {
                completion?(ogData, nil)
                return
            }
            let metaTags = header.xpath(self.dynamicType.MetaTagKey)
            for metaTag in metaTags {
                guard let property = metaTag[self.dynamicType.PropertyKey],
                      let content = metaTag[self.dynamicType.ContentKey]
                      where property.hasPrefix(self.dynamicType.PropertyPrefix) else {
                    continue
                }
                ogData.setValue(property: property, content: content)
            }
            ogData.save()
            completion?(ogData, nil)
        }.resume()
    }
    
    public func deleteOGData(urlString urlString: String, completion: ((NSError?) -> Void)? = nil) {
        guard let ogData = OGData.fetchOGData(url: urlString) else {
            completion?(NSError(domain: "no object matches with \"\(urlString)\"", code: 9999, userInfo: nil))
            return
        }
        deleteOGData(ogData, completion: completion)
    }
    
    public func deleteOGData(ogData: OGData, completion: ((NSError?) -> Void)? = nil) {
        OGDataCacheManager.sharedInstance.delete(ogData, completion: completion)
    }
}