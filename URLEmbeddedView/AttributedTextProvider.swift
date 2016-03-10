//
//  AttributedTextProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import Foundation

public final class AttributedTextProvider {
    static let sharedInstance = AttributedTextProvider()
    
    private let TitleAttributeManager       = AttributeManager(style: .Title)
    private let DomainAttributeManager      = AttributeManager(style: .Domain)
    private let DescriptionAttributeManager = AttributeManager(style: .Description)
    private let NoDataTitleAttributeManager = AttributeManager(style: .NoDataTitle)
    
    var didChangeValue: ((AttributeManager.Style, AttributeManager.Attribute, Any) -> Void)?
    
    private init() {
        self[.Title].didChangeValue       = { [weak self] in self?.didChangeValue?($0, $1, $2) }
        self[.Domain].didChangeValue      = { [weak self] in self?.didChangeValue?($0, $1, $2) }
        self[.Description].didChangeValue = { [weak self] in self?.didChangeValue?($0, $1, $2) }
        self[.NoDataTitle].didChangeValue = { [weak self] in self?.didChangeValue?($0, $1, $2) }
    }
    
    public subscript(style: AttributeManager.Style) -> AttributeManager {
        switch style {
        case .Title       : return TitleAttributeManager
        case .Domain      : return DomainAttributeManager
        case .Description : return DescriptionAttributeManager
        case .NoDataTitle : return NoDataTitleAttributeManager
        }
    }
    
    func didChangeValue(closure: ((AttributeManager.Style, AttributeManager.Attribute, Any) -> Void)?) {
        self[.Title].didChangeValue       = { closure?($0, $1, $2) }
        self[.Domain].didChangeValue      = { closure?($0, $1, $2) }
        self[.Description].didChangeValue = { closure?($0, $1, $2) }
        self[.NoDataTitle].didChangeValue = { closure?($0, $1, $2) }
    }
}

