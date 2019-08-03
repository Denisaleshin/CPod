//
//  BuildAble.swift
//  Belavia
//
//  Created by Dzianis Alioshyn on 12/5/18.
//  Copyright © 2018 EPAM. All rights reserved.
//

import Foundation

let baseURLString = "https://api-cert.belavia.by"

public enum HTTPMethod: String {
    case GET
    case POST
}

public enum ContentTypes: String {
    case json = "application/json-patch+json"
    case urlEncoded = "application/x-www-form-urlencoded; charset=utf-8"
}

public enum HTTPHeaders: String {
    case Authorization
    case ContentType = "Content-Type"
}

public enum AuthorizationTypes: String {
    case Bearer
}

public protocol Buildable {
    // HTTP Method: GET or POST
    var httpMethod: HTTPMethod { get }

    // API Path for the request
    var path: String { get }

    // Converts properties into key-value parameters
    func paramsDictionary() -> [String: Any]

    // Optional - Defaults to .json
    var contentType: ContentTypes { get }

    // Optional - Defaults to nil
    var headers: [HTTPHeaders: String]? { get }
}

public extension Buildable {
    var contentType: ContentTypes {
        return .json
    }

    var headers: [HTTPHeaders: String]? {
        return nil
    }

    func build() -> URLRequest {
        // Building the Request object
        let urlString = baseURLString + path
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.populate(contentType: contentType, path: path)
        request.encode(paramsDictionary(), contentType: contentType, method: httpMethod)
        headers?.keys.forEach { key in
            request.setValue(headers?[key], forHTTPHeaderField: key.rawValue)
        }
        return request
    }
}

extension URLRequest {
    mutating func populate(contentType: ContentTypes, path _: String) {
        cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        if let token = AppSharedData.shared.authorisationToken {
            setValue(("Bearer \(token)"), forHTTPHeaderField: HTTPHeaders.Authorization.rawValue)
        }
        setValue(contentType.rawValue, forHTTPHeaderField: HTTPHeaders.ContentType.rawValue)
    }

    // Adds percent-escaped, URL encoded parameters into the URLRequest.
    mutating func encode(_ parameters: [String: Any],
                         contentType: ContentTypes,
                         method: HTTPMethod) {
        httpMethod = method.rawValue.uppercased()
        switch method {
        case .GET:
            var urlComponents = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
            let percentEncoded = urlComponents.percentEncodedQuery.map { $0 + "&" } ?? ""
            let percentEncodedQuery = percentEncoded + ParameterEncoder.query(parameters)
            if !percentEncodedQuery.isEmpty {
                urlComponents.percentEncodedQuery = percentEncodedQuery
            }
            url = urlComponents.url
        case .POST:
            switch contentType {
            case .urlEncoded:
                httpBody = ParameterEncoder.query(parameters).data(using: .utf8, allowLossyConversion: false)
            default:
                httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            }
        }
    }

    private mutating func setValue(_ value: String?, for httpHeader: HTTPHeaders) {
        setValue(value, forHTTPHeaderField: httpHeader.rawValue)
    }
}
