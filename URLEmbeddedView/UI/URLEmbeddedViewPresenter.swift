//
//  URLEmbeddedViewPresenter.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2018/07/14.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

final class URLEmbeddedViewPresenter {

    private struct Const {
        static let faviconURL = "http://www.google.com/s2/favicons?domain="
    }

    private weak var view: URLEmbeddedViewProtocol?
    private let dataProvider = OGDataProvider.shared
    private var task: Task?

    private(set) var url: URL?
    var shouldContinueDownloadingWhenCancel = true

    init(view: URLEmbeddedViewProtocol) {
        self.view = view
    }

    func setURLString(_ urlString: String) {
        self.url = URL(string: urlString)
    }

    func load(urlString: String, completion: ((Result<Void>) -> Void)?) {
        guard let url = URL(string: urlString) else {
            completion?(.failure(URLEmbeddedViewError.invalidURLString(urlString)))
            return
        }
        self.url = url
        load(completion)
    }

    func load(_ completion: ((Result<Void>) -> Void)?) {
        guard let url = url else {
            return
        }

        view?.prepareViewsForReuse()
        view?.updateActivityView(isHidden: false)

        task = dataProvider.fetchOGData(withURLString: url.absoluteString) { [weak view, url] ogData, error in
            DispatchQueue.main.async {
                view?.updateActivityView(isHidden: true)
                view?.layoutIfNeeded()
                if let error = error {
                    view?.updateViewAsEmpty(with: url)
                    completion?(.failure(error))
                    return
                }

                view?.updateLinkIconView(isHidden: true)

                if let pageTitle = ogData.pageTitle {
                    view?.updateTitleLabel(pageTitle: pageTitle)
                } else {
                    view?.updateTitleLabel(pageTitle: url.absoluteString)
                }

                view?.updateDescriptionLabel(pageDescription: ogData.pageDescription)
                view?.updateImageView(urlString: ogData.imageUrl?.absoluteString)

                let host = url.host ?? ""
                view?.updateDomainLabel(host: host)

                let faciconURLString = Const.faviconURL + host
                view?.updateDomainImageView(urlString: faciconURLString)

                view?.layoutIfNeeded()
                completion?(.success(()))
            }
        }
    }

    func cancelLoading() {
        view?.updateActivityView(isHidden: true)
        guard let task = task else {
            return
        }
        dataProvider.cancelLoading(task, shouldContinueDownloading: shouldContinueDownloadingWhenCancel)
    }
}
