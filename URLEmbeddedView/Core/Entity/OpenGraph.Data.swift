//
//  OpenGraph.Data.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2018/07/14.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

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

extension OpenGraph.Data: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = OpenGraphData

    private init(source: OpenGraphData) {
        self.createdAt = source.createdAt
        self.imageUrl = source.imageUrl
        self.pageDescription = source.pageDescription
        self.pageTitle = source.pageTitle
        self.pageType = source.pageType
        self.siteName = source.siteName
        self.sourceUrl = source.sourceUrl
        self.updatedAt = source.updatedAt
        self.url = source.url
    }

    private init() {
        self.createdAt = Date()
        self.imageUrl = nil
        self.pageDescription = nil
        self.pageTitle = nil
        self.pageType = nil
        self.siteName = nil
        self.sourceUrl = nil
        self.updatedAt = Date()
        self.url = nil
    }

    public func _bridgeToObjectiveC() -> OpenGraphData {
        return .init(source: self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: OpenGraphData, result: inout OpenGraph.Data?) {
        result = .init(source: source)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: OpenGraphData, result: inout OpenGraph.Data?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: OpenGraphData?) -> OpenGraph.Data {
        return .init()
    }
}
