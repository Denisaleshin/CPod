//
//  TestFile.swift
//  Extentions
//
//  Created by Denis Aleshin on 8/5/19.
//

import Foundation

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
        let urlString = path
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

class ParameterEncoder {
    static func query(_ parameters: [String: Any]) -> String {
        guard let params = parameters as? [String: String] else {
            assertionFailure("Passing wrong type of parameters for GET: expected [String : String], passed: [String : Any]")
            return ""
        }
        var components: [(String, String)] = []
        for key in params.keys.sorted(by: <) {
            let value = params[key]!
            components += queryComponents(key, value)
        }
        return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
    }
    
    static func queryComponents(_ key: String, _ value: String) -> [(String, String)] {
        var components: [(String, String)] = []
        components.append((escape(key), escape("\(value)")))
        return components
    }
    
    static func escape(_ string: String) -> String {
        // Does not include "?" or "/".
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        let escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        return escaped
    }
}
