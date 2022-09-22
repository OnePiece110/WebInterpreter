//
//  KYCssParser.swift
//  WebInterpreter
//
//  Created by keyon on 2022/9/15.
//

import UIKit

class KYCssParser {
    let lexer: KYCssLexer
    private var currentToken: KYCssToken
    private var preTokenType: (type: KYCssTokenType, name: String) = (.begin, "")

    enum ParserError: Error {
        case unValid
    }

    init(text: String) throws {
        self.lexer = KYCssLexer(text: text)
        self.currentToken = try lexer.getNextToke()
    }

    private func eat(type: KYCssTokenType) throws {
        if currentToken.type == type {
            currentToken = try lexer.getNextToke()
        } else {
            throw ParserError.unValid
        }
    }

    func parse() throws -> KYCssNode {
        let node = KYCssNode()
        while currentToken.type != .eof {
            switch currentToken.type {
            case .idTag:
                preTokenType = (type: .idTag, name: currentToken.value?.getKeyWord() ?? "")
                currentToken = try lexer.getNextToke()
            case .classTag:
                preTokenType = (type: .classTag, name: currentToken.value?.getKeyWord() ?? "")
                currentToken = try lexer.getNextToke()
            case .blockTag:
                preTokenType = (type: .blockTag, name: currentToken.value?.getKeyWord() ?? "")
                currentToken = try lexer.getNextToke()
            case .attributeKey:
                let key = currentToken.value?.getKeyWord() ?? ""
                try eat(type: .attributeKey)
                let value = currentToken.value ?? .keyword("")
                try eat(type: .attributeValue)
                if preTokenType.type == .idTag {
                    if node.idTags[preTokenType.name] == nil {
                        node.idTags[preTokenType.name] = [String: CssValue]()
                    }
                    node.idTags[preTokenType.name]?[key] = value
                } else if preTokenType.type == .classTag {
                    if node.classTags[preTokenType.name] == nil {
                        node.classTags[preTokenType.name] = [String: CssValue]()
                    }
                    node.classTags[preTokenType.name]?[key] = value
                } else if preTokenType.type == .blockTag {
                    if node.blockTags[preTokenType.name] == nil {
                        node.blockTags[preTokenType.name] = [String: CssValue]()
                    }
                    node.blockTags[preTokenType.name]?[key] = value
                }
                break
            default:
                currentToken = try lexer.getNextToke()
                break
            }
        }
        return node
    }

    
}
