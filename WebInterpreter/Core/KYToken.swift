//
//  KYToken.swift
//  WebInterpreter
//
//  Created by keyon on 2022/9/14.
//

import UIKit

enum KYTokenType {
    case begin
    case openTagStart
    case tagName
    case openTagEnd
    case closeTagStart
    case closeTagEnd
    case attributeKey
    case attributeValue
    case eof
}

struct KYHtmlToken {
    let type: KYTokenType
    let value: String?
}

