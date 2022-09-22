//
//  KYCssToken.swift
//  WebInterpreter
//
//  Created by keyon on 2022/9/15.
//

import UIKit

enum KYCssTokenType {
    case begin
    case idTag
    case classTag
    case blockTag
    case Lbracket
    case Rbracket
    case attributeKey
    case attributeValue
    case eof
}

struct KYCssToken {
    let type: KYCssTokenType
    let value: CssValue?
}
