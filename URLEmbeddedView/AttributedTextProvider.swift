//
//  AttributedTextProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import Foundation

class AttributedTextProvider {
    static let sharedInstance = AttributedTextProvider()
    
    private let TitleAttributeTextManager       = AttributedTextManager(attribute: .Title)
    private let DescriptionAttributeTextManager = AttributedTextManager(attribute: .Description)
    private let DomainAttributeTextManager      = AttributedTextManager(attribute: .Domain)
    
    subscript(attribute: AttributedTextManager.Attribute) -> AttributedTextManager {
        switch attribute {
        case .Title       : return TitleAttributeTextManager
        case .Description : return DescriptionAttributeTextManager
        case .Domain      : return DomainAttributeTextManager
        }
    }
}

class AttributedTextManager {
    enum Attribute {
        case Title, Description, Domain
        
        var font: UIFont {
            switch self {
            case .Title:       return .boldSystemFontOfSize(16)
            case .Description: return .systemFontOfSize(14)
            case .Domain:      return .systemFontOfSize(10)
            }
        }
        
        var numberOfLines: Int {
            switch self {
            case .Title:       return 2
            case .Description: return 1
            case .Domain:      return 1
            }
        }
    }
    
    var font: UIFont
    var numberOfLines: Int
    
    private init(attribute: Attribute) {
        font = attribute.font
        numberOfLines = attribute.numberOfLines
    }
    
    func attributedText(string: String) -> NSAttributedString {
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : font
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
}