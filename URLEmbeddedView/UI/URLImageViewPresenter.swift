//
//  URLImageViewPresenter.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2018/07/14.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

final class URLImageViewPresenter {

    private let imageManager = OGImageManager.shared
    private var currentTask: Task?
    private weak var view: URLImageViewProtocol?

    var shouldContinueDownloadingWhenCancel = true

    init(view: URLImageViewProtocol) {
        self.view = view
    }

    func loadImage(urlString: String, completion: ((Result<UIImage>) -> Void)?) {
        cancelLoadingImage()
        view?.updateActivityView(isHidden: false)
        currentTask = imageManager.loadImage(withURLString: urlString) { [weak view] result in
            DispatchQueue.main.async {
                view?.updateActivityView(isHidden: true)
                view?.updateImage(result.value)
                completion?(result)
            }
        }
    }

    func cancelLoadingImage() {
        view?.updateActivityView(isHidden: true)

        guard let task = currentTask else {
            return
        }
        imageManager.cancelLoading(task,
                                   shouldContinueDownloading: shouldContinueDownloadingWhenCancel)
    }
}
