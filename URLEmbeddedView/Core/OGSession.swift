//
//  File.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2017/10/08.
//

import Foundation

final class OGSession {
    struct Task {
        let uuidString: String
        let task: URLSessionDataTask
    }
    
    enum Error: Swift.Error {
        case castFaild
        case jsonDecodeFaild
        case htmlDecodeFaild
        case other(Swift.Error)
    }
    
    private let session: URLSession
    
    init(configuration: URLSessionConfiguration = .default) {
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    func send<T: OGRequest>(_ request: T, completion: @escaping (T.Response?, Error?) -> Void) -> Task {
        let task = session.dataTask(with: request.urlRequest) { data, response, error in
            guard let data = data else {
                let e = error.map { Error.other($0) }
                completion(nil, e)
                return
            }
            do {
                let response = try T.response(data: data)
                completion(response, nil)
            } catch let e as Error {
                completion(nil, e)
            } catch let e {
                completion(nil, .other(e))
            }
        }
        return Task(uuidString: UUID().uuidString, task: task)
    }
}
