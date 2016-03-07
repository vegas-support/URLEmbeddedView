//
//  AttributeManager.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/08.
//
//

import Foundation

public class AttributeManager {
    public enum Style {
        case Title, Description, Domain, NoDataTitle
        
        var font: UIFont {
            switch self {
            case .Title       : return .boldSystemFontOfSize(16)
            case .Description : return .systemFontOfSize(14)
            case .Domain      : return .systemFontOfSize(10)
            case .NoDataTitle : return .systemFontOfSize(16)
            }
        }
        
        var numberOfLines: Int {
            switch self {
            case .Title, .NoDataTitle : return 2
            case .Description         : return 1
            case .Domain              : return 1
            }
        }
    }
    
    enum Attribute {
        case Font, NumberOfLines
    }
    
    var didChangeValue: ((Style, Attribute, Any) -> Void)?
    private let style: Style
    
    public var font: UIFont {
        didSet { didChangeValue?(style, .Font, font) }
    }
    public var numberOfLines: Int {
        didSet { didChangeValue?(style, .NumberOfLines, numberOfLines) }
    }
    
    init(style: Style) {
        self.style = style
        self.font = style.font
        self.numberOfLines = style.numberOfLines
    }
    
    func attributedText(string: String) -> NSAttributedString {
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : font
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
}