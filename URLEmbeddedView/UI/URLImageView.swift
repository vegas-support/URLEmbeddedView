//
//  URLImageView.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import UIKit

final class URLImageView: UIImageView {
    private let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var currentTask: Task?
    var activityViewHidden: Bool = false
    var shouldContinueDownloadingWhenCancel = true
    
    private var imageManger: OGImageManager = .shared
    
    init() {
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        activityView.hidesWhenStopped = true
        addSubview(activityView)
        addConstraints(with: activityView, size: .init(width: 30, height: 30))
        addConstraints(with: activityView, center: .zero)
    }
    
    func loadImage(urlString: String, completion: ((Result<UIImage>) -> Void)? = nil) {
        cancelLoadingImage()
        if !activityViewHidden {
            activityView.startAnimating()
        }
        currentTask = imageManger.loadImage(withURLString: urlString) { [weak self] result in
            DispatchQueue.main.async {
                if self?.activityViewHidden == false {
                    self?.activityView.stopAnimating()
                }
                self?.image = result.value
                completion?(result)
            }
        }
    }
    
    func cancelLoadingImage() {
        if !activityViewHidden {
            activityView.stopAnimating()
        }
        if let task = currentTask {
            imageManger.cancelLoading(task, shouldContinueDownloading: shouldContinueDownloadingWhenCancel)
        }
    }
}

