//
//  OGData.swift
//  URLEmbeddedView
//
//  Created by 鈴木大貴 on 2016/03/07.
//
//

import Foundation

struct OGData {
    private enum PropertyName: String {
        case Description = "og:description"
        case Image       = "og:image"
        case SiteName    = "og:site_name"
        case Title       = "og:title"
        case Type        = "og:type"
        case Url         = "og:url"
    }
    
    private(set) var siteName        : String = ""
    private(set) var pageType        : String = ""
    private(set) var url             : String = ""
    private(set) var pageTitle       : String = ""
    private(set) var imageUrl        : String = ""
    private(set) var pageDescription : String = ""
    
    private let URL: NSURL
    
    init(URL: NSURL) {
        self.URL = URL
    }
    
    mutating func setProperty(metaTagData metaTagData: OGMetaTagData) {
        guard let propertyName = PropertyName(rawValue: metaTagData.property) else { return }
        switch propertyName  {
        case .SiteName    : siteName        = metaTagData.content
        case .Type        : pageType        = metaTagData.content
        case .Title       : pageTitle       = metaTagData.content
        case .Image       : imageUrl        = metaTagData.content
        case .Url         : url             = metaTagData.content
        case .Description : pageDescription = metaTagData.content
        }
    }
}

struct OGMetaTagData {
    var property: String = ""
    var content: String = ""
}