//
//  KYCssNode.swift
//  WebInterpreter
//
//  Created by keyon on 2022/9/15.
//

import UIKit

public enum CssUnit {
    case px
}

public enum CssValue {
    case keyword(String)
    case length(Double, CssUnit)
    case color(UIColor?)

    func getKeyWord() -> String {
        switch self {
        case .keyword(let string):
            return string
        case .length(_, _):
            return ""
        case .color(_):
            return ""
        }
    }

    var px: Double {
        switch self {
        case .length(let val, _):
            return val
        default:
            return 0
        }
    }

    var color: UIColor? {
        switch self {
        case .color(let uIColor):
            return uIColor
        default:
            return .clear
        }
    }
}

class KYCssNode {
    var blockTags = [String : [String: CssValue]]()
    var idTags = [String : [String: CssValue]]()
    var classTags = [String : [String: CssValue]]()
    
}
