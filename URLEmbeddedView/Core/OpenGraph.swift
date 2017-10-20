//
//  OpenGraph.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2017/10/08.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

/// name space
public enum OpenGraph {}

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

extension OpenGraph {
    public struct Data {
        public let createdAt: Date
        public let imageUrl: URL?
        public let pageDescription: String?
        public let pageTitle: String?
        public let pageType: String?
        public let siteName: String?
        public let sourceUrl: URL?
        public let updatedAt: Date
        public let url: URL?
        
        init(ogData: OGData) {
            createdAt = ogData.createDate
            imageUrl = URL(string: ogData.imageUrl)
            pageDescription = ogData.pageDescription.isEmpty ? nil : ogData.pageDescription
            pageTitle = ogData.pageTitle.isEmpty ? nil : ogData.pageTitle
            pageType = ogData.pageType.isEmpty ? nil : ogData.pageType
            siteName = ogData.siteName.isEmpty ? nil : ogData.siteName
            sourceUrl = URL(string: ogData.sourceUrl)
            updatedAt = ogData.updateDate
            url = URL(string: ogData.url)
        }
    }
}
