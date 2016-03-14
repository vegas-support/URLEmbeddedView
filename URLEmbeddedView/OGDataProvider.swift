//
//  OGDataProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/06.
//
//

/*
 * In this file, Kanna is used to parse "og:" from meta tags.
 * Kanna is created by Atsushi Kiwaki.
 * https://github.com/tid-kijyun/Kanna
 * The original copyright is here.
 */

/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 - 2015 Atsushi Kiwaki (@_tid_)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation
import Kanna

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
    public func fetchOGData(urlString urlString: String, completion: ((OGData, NSError?) -> Void)? = nil) -> NSURLSessionDataTask? {
        let ogData = OGData.fetchOrInsertOGData(url: urlString)
        if !ogData.sourceUrl.isEmpty {
            completion?(ogData, nil)
        }
        ogData.sourceUrl = urlString
        guard let URL = NSURL(string: urlString) else {
            completion?(ogData, NSError(domain: "can not create NSURL with \"\(urlString)\"", code: 9999, userInfo: nil))
            return nil
        }
        let request = NSMutableURLRequest(URL: URL)
        request.setValue(self.dynamicType.UserAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 5
        let task = session.dataTaskWithRequest(request) { data, response, error in
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
        }
        task.resume()
        return task
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