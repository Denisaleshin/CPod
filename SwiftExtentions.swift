//
//  Test.swift
//  NetworkLayer
//
//  Created by Denis Aleshin on 8/3/19.
//


public extension Optional {
    
    func expectedToBe(_ logMessage: String? = nil, line: Int = #line, file: StaticString = #file) -> Wrapped? {
        switch self {
        case let .some(some): return some
        case .none:
            print("[OPTIONAL] \(#function) \(file):\(line) message \(String(describing: logMessage))")
            return .none
        }
    }
}

public extension Optional where Wrapped == String {
    var orEmpty: String {
        switch self {
        case let .some(value):
            return value
        case .none:
            return ""
        }
    }
}
