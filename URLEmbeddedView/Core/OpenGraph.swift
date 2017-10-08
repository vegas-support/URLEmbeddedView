//
//  OpenGraph.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2017/10/08.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

/// name space
enum OpenGraph {}

extension OpenGraph {
    struct HTML {
        private enum Const {
            static let metaTagKey = "meta"
            static let propertyKey = "property"
            static let contentKey = "content"
            static let propertyPrefix = "og:"
            static let regex: NSRegularExpression? = {
                let pattern = "meta\\s*(?:content\\s*=\\s*\"([^>]*)\"\\s*property\\s*=\\s*\"([^>]*)\")|(?:property\\s*=\\s*\"([^>]*)\"\\s*content\\s*=\\s*\"([^>]*)\")\\s*/?>"
                return try? NSRegularExpression(pattern: pattern, options: [])
            }()
        }
        
        struct Metadata {
            let property: String
            let content: String
            fileprivate var isValid: Bool {
                return !property.isEmpty && !content.isEmpty
            }
        }
        
        let metaList: [Metadata]
        
        init?(htmlString: String) {
            guard let regex = Const.regex else { return nil }
            let range = NSRange(htmlString.startIndex..<htmlString.endIndex, in: htmlString)
            let results = regex.matches(in: htmlString, options: [], range: range)
            let metaList: [Metadata] = results.flatMap { result in
                guard result.numberOfRanges > 2 else { return nil }
                let initial = Metadata(property: "", content: "")
                let metaData = (0..<result.numberOfRanges).reduce(initial) { metadata, index in
                    if index == 0 { return metadata }
                    let range = result.range(at: index)
                    if range.location == NSNotFound { return metadata }
                    let substring = (htmlString as NSString).substring(with: range)
                    if substring.contains(Const.propertyPrefix) {
                        return Metadata(property: substring, content: metadata.content)
                    }
                    return Metadata(property: metadata.property, content: substring)
                }
                return metaData.isValid ? metaData : nil
            }
            if metaList.isEmpty { return nil }
            self.metaList = metaList
        }
    }
}

extension OpenGraph {
    struct Youtube {
        let title: String
        let type: String
        let providerName: String
        let thumbnailUrl: String
        
        init?(json: [AnyHashable : Any]) {
            guard let title = json["title"] as? String else { return nil }
            self.title = title
            
            guard let type = json["type"] as? String else { return nil }
            self.type = type
            
            guard let providerName = json["provider_name"] as? String else { return nil }
            self.providerName = providerName
            
            guard let thumbnailUrl = json["thumbnail_url"] as? String else { return nil }
            self.thumbnailUrl = thumbnailUrl
        }
    }
}
