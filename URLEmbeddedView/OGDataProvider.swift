//
//  OGDataProvider.swift
//  URLEmbeddedView
//
//  Created by 鈴木大貴 on 2016/03/06.
//
//

import Foundation
import Kanna

public class OGDataProvider {
    public static let sharedInstance = OGDataProvider()
    private static let OGMetaPattern = "<meta.*?(?:content=\"(.*)?\").*?(?:property=\"(og:.*)?\")>"
    
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    public func fetchOGData(URL URL: NSURL, completion: ((OGData?, NSError?) -> Void)?) {
        session.dataTaskWithURL(URL) { [weak self] data, response, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            guard let data = data,
                  let html = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding),
                  let header = html.head else {
                completion?(nil, nil)
                return
            }
            var ogData = OGData()
            for value in header.xpath("meta") {
                guard let html = value.toHTML, metaTagData = self?.getOGMetaTagData(html) else { continue }
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
                    let value = (html as NSString).substringWithRange(match.rangeAtIndex(i))
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