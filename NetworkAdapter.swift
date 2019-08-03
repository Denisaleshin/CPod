//
//  NetworkAdapter.swift
//  Belavia
//
//  Created by Dzianis Alioshyn on 12/5/18.
//  Copyright © 2018 EPAM. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

public struct DataResource<Decodable> {
    let buildable: Buildable

    public init(with params: Buildable) {
        buildable = params
    }
}

open class NetworkAdapter {
    public init() {}

    let network = NetworkEngine()

    open func fetch<T>(_ resource: DataResource<T>, completion: @escaping ([T]?) -> Void) where T: Decodable {
        network.fetch(resource.buildable) { [weak self] result in
            guard case let Result.success(data) = result,
                let totalResult = self?.buildModel(of: T.self, fromData: data) else {
                completion(nil)
                return
            }
            completion(totalResult)
            // it would be useful to add error handling here
        }
    }

    func buildModel<T: Decodable>(of _: T.Type, fromData data: Data) -> [T]? {
        do {
            let decoder = JSONDecoder()
            let modelFromData = try decoder.decode([T].self, from: data)
            print("\(modelFromData)")
            return modelFromData
        } catch {
            return nil
        }
    }
}
