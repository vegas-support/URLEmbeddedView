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
    //MARK: - Properties
    private var URL: NSURL?
    private let privateImageView = URLImageView()
    public var imageView: UIImageView {
        return privateImageView
    }
    public let mainTextLabel = UILabel()
    public let subTextLabel = UILabel()
    public let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    @IBInspectable public var cornerRaidus: CGFloat {
        set {
            layer.masksToBounds = newValue > 0
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    @IBInspectable public var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.CGColor
            privateImageView.layer.borderColor = layer.borderColor
        }
        get {
            guard let cgColor = layer.borderColor else { return nil }
            return UIColor(CGColor: cgColor)
        }
    }
    @IBInspectable public var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
            privateImageView.layer.borderWidth = layer.borderWidth
        }
        get {
            return layer.borderWidth
        }
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
    
    private func setInitialiValues() {
        borderColor = .lightGrayColor()
        borderWidth = 1
        cornerRaidus = 8
    }
    
    private func configureViews() {
        setNeedsDisplay()
        layoutIfNeeded()
        
        activityView.hidesWhenStopped = true
        addLayoutSubview(activityView, andConstraints:
            activityView.Width |=| 30,
            activityView.Height |=| 30,
            activityView.CenterX,
            activityView.CenterY
        )
        
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        addLayoutSubview(imageView, andConstraints:
            imageView.Top,
            imageView.Left,
            imageView.Bottom,
            imageView.Width |==| imageView.Height
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
                if !ogData.imageUrl.isEmpty {
                    self?.privateImageView.loadImage(ogData.imageUrl)
                }
            }
        }
    }
}
