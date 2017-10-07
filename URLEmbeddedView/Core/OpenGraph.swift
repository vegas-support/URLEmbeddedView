//
//  OpenGraph.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2017/10/08.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
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
