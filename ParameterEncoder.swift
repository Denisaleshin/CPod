//
//  ParameterEncoder.swift
//  Belavia
//
//  Created by Dzianis Alioshyn on 12/5/18.
//  Copyright © 2018 EPAM. All rights reserved.
//

import Foundation

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
