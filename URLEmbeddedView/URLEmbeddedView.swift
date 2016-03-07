//
//  URLEmbeddedView.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/06.
//
//

import UIKit
import MisterFusion

public class URLEmbeddedView: UIView {
    private typealias ATP = AttributedTextProvider
    //MARK: - Static constants
    private static let FaviconURL = "http://www.google.com/s2/favicons?domain="
    
    //MARK: - Properties
    let imageView = URLImageView()
    private var imageViewWidthConstraint: NSLayoutConstraint?
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let domainConainter = UIView()
    private let domainLabel = UILabel()
    private let domainImageView = UIImageView()
    private var domainImageViewToDomainLabelConstraint: NSLayoutConstraint?
    private var domainImageViewWidthConstraint: NSLayoutConstraint?
    
    private let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    private var URL: NSURL?
    public let textProvider = AttributedTextProvider.sharedInstance
    
    public convenience init(url: String) {
        self.init(url: url, frame: .zero)
    }
    
    public init(url: String, frame: CGRect) {
        super.init(frame: frame)
        URL = NSURL(string: url)
        setInitialiValues()
        configureViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setInitialiValues()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    private func setInitialiValues() {
        borderColor = .lightGrayColor()
        borderWidth = 1
        cornerRaidus = 8
    }
    
    private func configureViews() {
        setNeedsDisplay()
        layoutIfNeeded()
        
        textProvider.didChangeValue = { [weak self] style, attribute, value in
            switch style {
            case .Title: break
            case .Domain: break
            case .Description: break
            case .NoDataTitle: break
            }
            
            print("style = \(style)")
            print("attribute = \(attribute)")
            print("value = \(value)")
        }
        
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        addLayoutSubview(imageView, andConstraints:
            imageView.Top,
            imageView.Left,
            imageView.Bottom,
            imageView.Width |==| imageView.Height
        )
        
        titleLabel.numberOfLines = textProvider[.Title].numberOfLines
        titleLabel.backgroundColor = .grayColor()
        addLayoutSubview(titleLabel, andConstraints:
            titleLabel.Top    |+| 8,
            titleLabel.Right  |-| 12,
            titleLabel.Left   |==| imageView.Right |+| 12,
            titleLabel.Height |>=| textProvider[.Title].font.lineHeight
        )
        
        domainConainter.backgroundColor = .grayColor()
        addLayoutSubview(domainConainter, andConstraints:
            domainConainter.Right  |-| 12,
            domainConainter.Bottom |-| 10,
            domainConainter.Left   |==| imageView.Right |+| 12,
            domainConainter.Height |=|  textProvider[.Domain].font.lineHeight
        )
        
        descriptionLabel.numberOfLines = textProvider[.Description].numberOfLines
        descriptionLabel.backgroundColor = .grayColor()
        addLayoutSubview(descriptionLabel, andConstraints:
            descriptionLabel.Right  |-| 12,
            descriptionLabel.Height |>=| 0,
            descriptionLabel.Top    |==| titleLabel.Bottom   |+| 2,
            descriptionLabel.Bottom |<=| domainConainter.Top |+| 4,
            descriptionLabel.Left   |==| imageView.Right     |+| 12
        )
        
        domainConainter.addLayoutSubview(domainImageView, andConstraints:
            domainImageView.Top,
            domainImageView.Left,
            domainImageView.Bottom,
            domainImageView.Width |==| domainConainter.Height
        )
        
        domainLabel.numberOfLines = textProvider[.Domain].numberOfLines
        domainConainter.addLayoutSubview(domainLabel, andConstraints:
            domainLabel.Top,
            domainLabel.Right,
            domainLabel.Bottom,
            domainLabel.Left |==| domainImageView.Right |+| (textProvider[.Domain].font.lineHeight / 5)
        )
        
        activityView.hidesWhenStopped = true
        addLayoutSubview(activityView, andConstraints:
            activityView.CenterX,
            activityView.CenterY,
            activityView.Width  |=| 30,
            activityView.Height |=| 30
        )
    }
}

extension URLEmbeddedView {
    public func loadURL(url: String) {
        guard let URL = NSURL(string: url) else { return }
        self.URL = URL
        load()
    }
    
    public func load() {
        guard let URL = URL else { return }
        activityView.startAnimating()
        OGDataProvider.sharedInstance.fetchOGData(URL: URL) { [weak self] ogData, error in
            dispatch_async(dispatch_get_main_queue()) {
                self?.activityView.stopAnimating()
                if let _ = error {
                    self?.titleLabel.attributedText = self?.textProvider[.NoDataTitle].attributedText(URL.absoluteString)
                    self?.descriptionLabel.attributedText = nil
                    self?.domainLabel.attributedText = self?.textProvider[.Domain].attributedText(URL.host ?? "")
                    return
                }
                self?.titleLabel.attributedText = self?.textProvider[.Title].attributedText(ogData.pageTitle)
                self?.descriptionLabel.attributedText = self?.textProvider[.Description].attributedText(ogData.pageDescription)
                if !ogData.imageUrl.isEmpty {
                    self?.imageView.loadImage(ogData.imageUrl, completion: nil)
                    let host = URL.host ?? ""
                    self?.domainLabel.attributedText = self?.textProvider[.Domain].attributedText(host)
                    self?.domainImageView.loadImage((self?.dynamicType.FaviconURL ?? "") + host, completion: nil)
                }
            }
        }
    }
}
