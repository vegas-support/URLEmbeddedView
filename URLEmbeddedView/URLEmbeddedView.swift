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
    private let domainImageView = URLImageView()
    private var domainImageViewToDomainLabelConstraint: NSLayoutConstraint?
    private var domainImageViewWidthConstraint: NSLayoutConstraint?
    
    private let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private lazy var linkIconView: LinkIconView = {
        return LinkIconView(frame: self.bounds)
    }()
    
    private var URL: NSURL?
    private var uuidString: String?
    public let textProvider = AttributedTextProvider.sharedInstance
    
    public var didTapHandler: ((URLEmbeddedView, NSURL?) -> Void)?
    public var stopTaskWhenCancel = false {
        didSet {
            domainImageView.stopTaskWhenCancel = stopTaskWhenCancel
            imageView.stopTaskWhenCancel = stopTaskWhenCancel
        }
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setInitialiValues()
        configureViews()
    }
    
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
    
    public func prepareViewsForReuse() {
        cancelLoad()
        imageView.image = nil
        titleLabel.attributedText = nil
        descriptionLabel.attributedText = nil
        domainLabel.attributedText = nil
        domainImageView.image = nil
        linkIconView.hidden = true
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
            self?.handleTextProviderChanged(style, attribute: attribute, value: value)
        }
        
        addLayoutSubview(linkIconView, andConstraints:
            linkIconView.Top,
            linkIconView.Left,
            linkIconView.Bottom,
            linkIconView.Width |==| linkIconView.Height
        )
        linkIconView.clipsToBounds = true
        linkIconView.hidden = true
        
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
        
        domainImageView.activityViewHidden = true
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
            activityView.Width  |==| 30,
            activityView.Height |==| 30
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
            misterFusion = imageView.Width |==| constant
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
            misterFusion = domainImageView.Width |==| constant
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
        domainContainerHeightConstraint = addLayoutConstraint(domainConainter.Height |==| constant)
    }
}

extension URLEmbeddedView {
    private func handleTextProviderChanged(style: AttributeManager.Style, attribute: AttributeManager.Attribute, value: Any) {
        switch style {
        case .Title:       didChangeTitleAttirbute(attribute, value: value)
        case .Domain:      didChangeDomainAttirbute(attribute, value: value)
        case .Description: didChangeDescriptionAttirbute(attribute, value: value)
        case .NoDataTitle: didChangeNoDataTitleAttirbute(attribute, value: value)
        }
    }
    
    private func didChangeTitleAttirbute(attribute: AttributeManager.Attribute, value: Any) {
        switch attribute {
        case .Font: changeDomainContainerHeightConstraint()
        case .FontColor: break
        case .NumberOfLines: break
        }
    }
    
    private func didChangeDomainAttirbute(attribute: AttributeManager.Attribute, value: Any) {
        switch attribute {
        case .Font: changeDomainContainerHeightConstraint()
        case .FontColor: break
        case .NumberOfLines: break
        }
    }
    
    private func didChangeDescriptionAttirbute(attribute: AttributeManager.Attribute, value: Any) {
        switch attribute {
        case .Font: break
        case .FontColor: break
        case .NumberOfLines: break
        }
    }
    
    private func didChangeNoDataTitleAttirbute(attribute: AttributeManager.Attribute, value: Any) {
        switch attribute {
        case .Font: changeTitleLabelHeightConstraint()
        case .FontColor: break
        case .NumberOfLines: break
        }
    }
}

extension URLEmbeddedView {
    public func loadURL(urlString: String, completion: ((NSError?) -> Void)? = nil) {
        guard let URL = NSURL(string: urlString) else {
            completion?(nil)
            return
        }
        self.URL = URL
        load(completion)
    }
    
    public func load(completion: ((NSError?) -> Void)? = nil) {
        guard let URL = URL else { return }
        prepareViewsForReuse()
        activityView.startAnimating()
        uuidString = OGDataProvider.sharedInstance.fetchOGData(urlString: URL.absoluteString) { [weak self] ogData, error in
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
                    self?.linkIconView.hidden = false
                    self?.layoutIfNeeded()
                    completion?(error)
                    return
                }
                
                self?.linkIconView.hidden = true
                if ogData.pageTitle.isEmpty {
                    self?.titleLabel.attributedText = self?.textProvider[.NoDataTitle].attributedText(URL.absoluteString)
                } else {
                    self?.titleLabel.attributedText = self?.textProvider[.Title].attributedText(ogData.pageTitle)
                }
                self?.descriptionLabel.attributedText = self?.textProvider[.Description].attributedText(ogData.pageDescription)
                if !ogData.imageUrl.isEmpty {
                    self?.imageView.loadImage(urlString: ogData.imageUrl) {
                        if let _ = $0 where $1 == nil {
                            self?.changeImageViewWidthConstrain(nil)
                        } else {
                            self?.changeImageViewWidthConstrain(0)
                        }
                        self?.layoutIfNeeded()
                    }
                } else {
                    self?.changeImageViewWidthConstrain(0)
                    self?.imageView.image = nil
                }
                let host = URL.host ?? ""
                self?.domainLabel.attributedText = self?.textProvider[.Domain].attributedText(host)
                let faciconURL = (self?.dynamicType.FaviconURL ?? "") + host
                self?.domainImageView.loadImage(urlString: faciconURL) {
                    if let _ = $0 where $1 == nil {
                        self?.changeDomainImageViewWidthConstraint(nil)
                        self?.changeDomainImageViewToDomainLabelConstraint(nil)
                    } else {
                        self?.changeDomainImageViewWidthConstraint(0)
                        self?.changeDomainImageViewToDomainLabelConstraint(0)
                    }
                    self?.layoutIfNeeded()
                }
                self?.layoutIfNeeded()
                completion?(nil)
            }
        }
    }
    
    public func cancelLoad() {
        domainImageView.cancelLoadImage()
        imageView.cancelLoadImage()
        activityView.stopAnimating()
        guard let uuidString = uuidString else { return }
        OGDataProvider.sharedInstance.cancelLoad(uuidString, stopTask: stopTaskWhenCancel)
    }
}
