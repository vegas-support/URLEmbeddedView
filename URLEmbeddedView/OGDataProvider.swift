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

public final class OGDataProvider {
    //MARK: Static constants
    public static let sharedInstance = OGDataProvider()
    private static let UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Safari/601.1.42"
    private static let MetaTagKey = "meta"
    private static let PropertyKey = "property"
    private static let ContentKey = "content"
    private static let PropertyPrefix = "og:"
    
    //MARK: - Properties
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    public func fetchOGData(URL URL: NSURL, completion: ((OGData, NSError?) -> Void)? = nil) {
        let url = URL.absoluteString
        let ogData = OGData.fetchOrInsertOGData(url: url)
        if !ogData.sourceUrl.isEmpty {
            completion?(ogData, nil)
        }
        ogData.sourceUrl = url
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
}