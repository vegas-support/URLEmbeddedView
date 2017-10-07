//
//  OpenGraph.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2017/10/08.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import Kanna

/// name space
enum OpenGraph {}

extension OpenGraph {
    struct HTML {
        private enum Const {
            static let metaTagKey = "meta"
            static let propertyKey = "property"
            static let contentKey = "content"
            static let propertyPrefix = "og:"
        }
        
        struct Metadata {
            let property: String
            let content: String
        }
        let metaList: [Metadata]
        
        init?(element: XMLElement) {
            let metaTags = element.xpath(Const.metaTagKey)
            let metaList = metaTags.enumerated().flatMap { _, metaTag -> Metadata? in
                guard
                    let property = metaTag[Const.propertyKey],
                    let content = metaTag[Const.contentKey],
                    property.hasPrefix(Const.propertyPrefix)
                else { return nil }
                return Metadata(property: property, content: content)
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
