//
//  HtmlRequest.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2017/10/08.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import Kanna

struct HtmlRequest: OGRequest {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    static func response(data: Data) throws -> OpenGraph.HTML {
        guard
            let html = Kanna.HTML(html: data, encoding: String.Encoding.utf8),
            let header = html.head
        else {
            throw OGSession.Error.castFaild
        }
        return try OpenGraph.HTML(element: header) ?? { throw OGSession.Error.htmlDecodeFaild }()
    }
}
