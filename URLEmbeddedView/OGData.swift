//
//  OGData.swift
//  URLEmbeddedView
//
//  Created by 鈴木大貴 on 2016/03/07.
//
//

import Foundation

struct OGData {
    //MARK: Inner enum
    private enum PropertyName: String {
        case Description = "og:description"
        case Image       = "og:image"
        case SiteName    = "og:site_name"
        case Title       = "og:title"
        case Type        = "og:type"
        case Url         = "og:url"
    }
    
    //MARKL - Properties
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
    
    mutating func setValue(property property: String, content: String) {
        guard let propertyName = PropertyName(rawValue: property) else { return }
        switch propertyName  {
        case .SiteName    : siteName        = content
        case .Type        : pageType        = content
        case .Title       : pageTitle       = content
        case .Image       : imageUrl        = content
        case .Url         : url             = content
        case .Description : pageDescription = content
        }
    }
}