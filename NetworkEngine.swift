//
//  NetworkEngine.swift
//  Belavia
//
//  Created by Dzianis Alioshyn on 12/5/18.
//  Copyright © 2018 EPAM. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error?)

    var value: T? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
}

enum NetworkError: Error {
    case commonError
}

typealias FetchResultCompletion = (Result<Data>) -> Void

class NetworkEngine {
    func fetch(_ buildable: Buildable, completion: @escaping FetchResultCompletion) {
        let request = buildable.build()
        let currentTask = URLSession.shared.dataTask(with: request) { data, _, _ in
            //            if let err = self?.errorFor(URLResponse: response, error: error) {
            //                completion(.Failure(err))
            //            }
            guard let validData = data else {
                completion(.failure(nil))
                return
            }
            completion(.success(validData))
        }
        currentTask.resume()
    }

    fileprivate func errorFor(URLResponse _: URLResponse?,
                              error: Error?) -> Error? {
        // Error handling should be here.
        let error = NetworkError.commonError
        return error
    }
}
