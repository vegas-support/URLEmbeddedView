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
    private let alphaView = UIView()
    
    let imageView = URLImageView()
    private var imageViewWidthConstraint: NSLayoutConstraint?
    
    private let titleLabel = UILabel()
    private var titleLabelHeightConstraint: NSLayoutConstraint?
    private let descriptionLabel = UILabel()
    
    private let domainConainter = UIView()
    private var domainContainerHeightConstraint: NSLayoutConstraint?
    private let domainLabel = UILabel()
    private let domainImageView = UIImageView()
    private var domainImageViewToDomainLabelConstraint: NSLayoutConstraint?
    private var domainImageViewWidthConstraint: NSLayoutConstraint?
    
    private let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private var linkIconView: LinkIconView?
    
    private var URL: NSURL?
    public let textProvider = AttributedTextProvider.sharedInstance
    
    public var didTapHandler: ((URLEmbeddedView, NSURL?) -> Void)?
    
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
            case .Title: self?.changeDomainContainerHeightConstraint()
            case .Domain: break
            case .Description: break
            case .NoDataTitle: break
            }
            
            print("style = \(style)")
            print("attribute = \(attribute)")
            print("value = \(value)")
        }
        
        let linkIconView = LinkIconView(frame: bounds)
        addLayoutSubview(linkIconView, andConstraints:
            linkIconView.Top,
            linkIconView.Left,
            linkIconView.Bottom,
            linkIconView.Width |==| linkIconView.Height
        )
        linkIconView.clipsToBounds = true
        linkIconView.hidden = true
        self.linkIconView = linkIconView
        
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        addLayoutSubview(imageView, andConstraints:
            imageView.Top,
            imageView.Left,
            imageView.Bottom
        )
        changeImageViewWidthConstrain(nil)
        
        titleLabel.numberOfLines = textProvider[.Title].numberOfLines
        addLayoutSubview(titleLabel, andConstraints:
            titleLabel.Top    |+| 8,
            titleLabel.Right  |-| 12,
            titleLabel.Left   |==| imageView.Right |+| 12
        )
        changeTitleLabelHeightConstraint()
        
        addLayoutSubview(domainConainter, andConstraints:
            domainConainter.Right  |-| 12,
            domainConainter.Bottom |-| 10,
            domainConainter.Left   |==| imageView.Right |+| 12
        )
        changeDomainContainerHeightConstraint()
        
        descriptionLabel.numberOfLines = textProvider[.Description].numberOfLines
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
            domainImageView.Bottom
        )
        changeDomainImageViewWidthConstraint(nil)
        
        domainLabel.numberOfLines = textProvider[.Domain].numberOfLines
        domainConainter.addLayoutSubview(domainLabel, andConstraints:
            domainLabel.Top,
            domainLabel.Right,
            domainLabel.Bottom
        )
        changeDomainImageViewToDomainLabelConstraint(nil)
        
        activityView.hidesWhenStopped = true
        addLayoutSubview(activityView, andConstraints:
            activityView.CenterX,
            activityView.CenterY,
            activityView.Width  |=| 30,
            activityView.Height |=| 30
        )
        
        alphaView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        alphaView.alpha = 0
        addLayoutSubview(alphaView, andConstraints:
            alphaView.Top,
            alphaView.Right,
            alphaView.Bottom,
            alphaView.Left
        )
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        alphaView.alpha = 1
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        alphaView.alpha = 0
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        alphaView.alpha = 0
        didTapHandler?(self, URL)
    }
}

extension URLEmbeddedView {
    private func changeImageViewWidthConstrain(constant: CGFloat?) {
        if let constraint = imageViewWidthConstraint {
            removeConstraint(constraint)
        }
        let misterFusion: MisterFusion
        if let constant = constant {
            misterFusion = imageView.Width |=| constant
        } else {
            misterFusion = imageView.Width |==| imageView.Height
        }
        imageViewWidthConstraint = addLayoutConstraint(misterFusion)
    }
    
    private func changeDomainImageViewWidthConstraint(constant: CGFloat?) {
        if let constraint = domainImageViewWidthConstraint {
            removeConstraint(constraint)
        }
        let misterFusion: MisterFusion
        if let constant = constant {
            misterFusion = domainImageView.Width |=| constant
        } else {
            misterFusion = domainImageView.Width |==| domainConainter.Height
        }
        domainImageViewWidthConstraint = addLayoutConstraint(misterFusion)
    }
    
    private func changeDomainImageViewToDomainLabelConstraint(constant: CGFloat?) {
        let constant = constant ?? (textProvider[.Domain].font.lineHeight / 5)
        if let constraint = domainImageViewToDomainLabelConstraint {
            if constant == constraint.constant { return }
            removeConstraint(constraint)
        }
        let misterFusion = domainLabel.Left |==| domainImageView.Right |+| constant
        domainImageViewToDomainLabelConstraint = addLayoutConstraint(misterFusion)
    }
    
    private func changeTitleLabelHeightConstraint() {
        let constant = textProvider[.Title].font.lineHeight
        if let constraint = titleLabelHeightConstraint {
            if constant == constraint.constant { return }
            removeConstraint(constraint)
        }
        titleLabelHeightConstraint = addLayoutConstraint(titleLabel.Height |>=| constant)
    }
    
    private func changeDomainContainerHeightConstraint() {
        let constant = textProvider[.Domain].font.lineHeight
        if let constraint = domainContainerHeightConstraint {
            if constant == constraint.constant { return }
            removeConstraint(constraint)
        }
        domainContainerHeightConstraint = addLayoutConstraint(domainConainter.Height |=| constant)
    }
}

extension URLEmbeddedView {
    public func loadURL(url: String, completion: ((NSError?) -> Void)? = nil) {
        guard let URL = NSURL(string: url) else {
            completion?(nil)
            return
        }
        self.URL = URL
        load(completion)
    }
    
    public func load(completion: ((NSError?) -> Void)? = nil) {
        guard let URL = URL else { return }
        activityView.startAnimating()
        OGDataProvider.sharedInstance.fetchOGData(URL: URL) { [weak self] ogData, error in
            dispatch_async(dispatch_get_main_queue()) {
                self?.activityView.stopAnimating()
                if let error = error {
                    self?.imageView.image = nil
                    self?.titleLabel.attributedText = self?.textProvider[.NoDataTitle].attributedText(URL.absoluteString)
                    self?.descriptionLabel.attributedText = nil
                    self?.domainLabel.attributedText = self?.textProvider[.Domain].attributedText(URL.host ?? "")
                    self?.changeDomainImageViewWidthConstraint(0)
                    self?.changeDomainImageViewToDomainLabelConstraint(0)
                    self?.changeImageViewWidthConstrain(nil)
                    self?.linkIconView?.hidden = false
                    self?.layoutIfNeeded()
                    completion?(error)
                    return
                }
                
                self?.linkIconView?.hidden = true
                if ogData.pageTitle.isEmpty {
                    self?.titleLabel.attributedText = self?.textProvider[.NoDataTitle].attributedText(URL.absoluteString)
                } else {
                    self?.titleLabel.attributedText = self?.textProvider[.Title].attributedText(ogData.pageTitle)
                }
                self?.descriptionLabel.attributedText = self?.textProvider[.Description].attributedText(ogData.pageDescription)
                if !ogData.imageUrl.isEmpty {
                    self?.imageView.loadImage(ogData.imageUrl) { image, error in
                        if let _ = image where error == nil {
                            self?.changeImageViewWidthConstrain(nil)
                        } else {
                            self?.changeImageViewWidthConstrain(0)
                            self?.imageView.image = nil
                        }
                    }
                } else {
                    self?.changeImageViewWidthConstrain(0)
                    self?.imageView.image = nil
                }
                let host = URL.host ?? ""
                self?.domainLabel.attributedText = self?.textProvider[.Domain].attributedText(host)
                self?.domainImageView.loadImage((self?.dynamicType.FaviconURL ?? "") + host, completion: nil)
                self?.changeDomainImageViewWidthConstraint(nil)
                self?.changeDomainImageViewToDomainLabelConstraint(nil)
                self?.layoutIfNeeded()
                completion?(nil)
            }
        }
    }
}
