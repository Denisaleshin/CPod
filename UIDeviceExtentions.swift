//
//  Test.swift
//  NetworkLayer
//
//  Created by Denis Aleshin on 8/3/19.
//

import Foundation

public extension UIDevice {
    static var isLandscapeOrientation: Bool {
        guard current.orientation.isValidInterfaceOrientation else {
            return UIScreen.main.bounds.width > UIScreen.main.bounds.height
        }
        return current.orientation.isLandscape
    }
}

public extension UIDevice {
    enum `Type` {
        case iPad
        case iPhone_unknown
        case iPhone_5_5S_5C
        case iPhone_6_6S_7_8
        case iPhone_6_6S_7_8_PLUS
        case iPhone_X_Xs
        case iPhone_Xs_Max
        case iPhone_Xr
    }
    
    var hasHomeButton: Bool {
        switch type {
        case .iPhone_X_Xs, .iPhone_Xr, .iPhone_Xs_Max:
            return false
        default:
            return true
        }
    }
    
    var type: Type {
        if userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                return .iPhone_5_5S_5C
            case 1334:
                return .iPhone_6_6S_7_8
            case 1920, 2208:
                return .iPhone_6_6S_7_8_PLUS
            case 2436:
                return .iPhone_X_Xs
            case 2688:
                return .iPhone_Xs_Max
            case 1792:
                return .iPhone_Xr
            default:
                return .iPhone_unknown
            }
        }
        return .iPad
    }
    
    var isSmall: Bool {
        return type == .iPhone_5_5S_5C
    }
}

