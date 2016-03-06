//
//  OGDataProvider.swift
//  URLEmbeddedView
//
//  Created by 鈴木大貴 on 2016/03/06.
//
//

import Foundation
import Kanna
import WebKit

class OGDataProvider {
    static let sharedInstance = OGDataProvider()
    private static let OGMetaPattern = "(?:<meta.*(?:content=\"(.*)?\").*(?:property=\"(og:.*)?\").*>)|(?:<meta.*?(?:property=\"(og:.*)?\").*?(?:content=\"(.*)?\").*>)"
    private static let UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Safari/601.1.42"
    
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    func fetchOGData(URL URL: NSURL, completion: ((OGData, NSError?) -> Void)? = nil) {
        let request = NSMutableURLRequest(URL: URL)
        request.setValue(self.dynamicType.UserAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 5
        self.session.dataTaskWithRequest(request) { [weak self] data, response, error in
            var ogData = OGData(URL: URL)
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
            let metaTags = header.xpath("meta")
            for metaTag in metaTags {
                print(metaTag.toHTML)
                guard let html = metaTag.toHTML, metaTagData = self?.getOGMetaTagData(html) else { continue }
                ogData.setProperty(metaTagData: metaTagData)
            }
            completion?(ogData, nil)
        }.resume()
    }
    
    private func getOGMetaTagData(html: String) -> OGMetaTagData? {
        do {
            let regex = try NSRegularExpression(pattern: self.dynamicType.OGMetaPattern, options: [])
            let matches = regex.matchesInString(html, options: [], range: NSRange(location: 0, length: html.characters.count))
            var metaTag = OGMetaTagData()
            for match in matches {
                for i in 1..<match.numberOfRanges {
                    let range = match.rangeAtIndex(i)
                    if range.location == NSNotFound {
                        continue
                    }
                    let value = (html as NSString).substringWithRange(range)
                    if value.hasPrefix("og:") {
                        metaTag.property = value
                    } else {
                        metaTag.content = value
                    }
                }
            }
            if matches.count > 0 {
                return metaTag
            }
        } catch {
            return nil
        }
        return nil
    }
}