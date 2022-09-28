//
//  KYCssLexer.swift
//  WebInterpreter
//
//  Created by keyon on 2022/9/15.
//

import UIKit

class KYCssLexer {

    enum LexerError: Error {
        case unValid
    }

    private let text: String
    private var pos: Int = 0
    private var currentChar: Character?
    private var isCssScope = false
    private var preTokenType: KYCssTokenType = .begin

    init(text: String) {
        self.text = text
        self.currentChar = text[text.index(text.startIndex, offsetBy: pos)]
    }

    private func advance() {
        pos += 1
        if pos > text.count - 1 {
            currentChar = nil
        } else {
            currentChar = text[text.index(text.startIndex, offsetBy: pos)]
        }
    }

    private func skipWhitespace() {
        while let currentChar = currentChar, currentChar.isWhitespace {
            advance()
        }
    }

    func consumeWhile(_ test: (Character) -> Bool) -> String {
        var chars = [Character]()
        while let currentChar = currentChar, test(currentChar) {
            chars.append(currentChar)
            advance()
        }
        return String(chars)
    }

    private func validIdentifierChar(_ ch: Character) -> Bool {
        switch ch {
        case "a"..."z":
            return true
        case "A"..."Z":
            return true
        case "0"..."9":
            return true
        case "-":
            return true
        case "_":
            return true
        case "#":
            return true
        default:
            return false
        }
    }

    func getNextToke() throws -> KYCssToken {
        while let currentChar = currentChar {
            if currentChar.isWhitespace {
                skipWhitespace()
                continue
            }

            if currentChar == ".", !isCssScope {
                advance()
                return .init(type: .classTag, value: .keyword(parseIdentifier()))
            }

            if currentChar == "#", !isCssScope {
                advance()
                return .init(type: .idTag, value: .keyword(parseIdentifier()))
            }

            if validIdentifierChar(currentChar) {
                if isCssScope {
                    preTokenType = .attributeKey
                    return .init(type: .attributeKey, value: .keyword(parseIdentifier()))
                } else {
                    return .init(type: .blockTag, value: .keyword(parseIdentifier()))
                }
            }

            if currentChar == "{" {
                isCssScope = true
                advance()
                return .init(type: .Lbracket, value: nil)
            }

            if currentChar == "}" {
                isCssScope = false
                advance()
                return .init(type: .Rbracket, value: nil)
            }

            if currentChar == ":", preTokenType == .attributeKey {
                advance()
                skipWhitespace()
                let value = try parseValue()
                skipWhitespace()
                if self.currentChar != ";" {
                    throw LexerError.unValid
                }
                advance()
                return .init(type: .attributeValue, value: value)
            }

            advance()
        }
        return .init(type: .eof, value: nil)
    }

    private func parseValue() throws -> CssValue {
        guard let currentChar = currentChar else { throw LexerError.unValid }
        switch currentChar {
        case "0"..."9":
            return parseLength()
        case "#":
            return .color(UIColor.ky.color(hex: parseIdentifier()))
        default:
            return .keyword(parseIdentifier())
        }
    }

    private func parseLength() -> CssValue {
        return .length(parseFloat(), parseUnit())
    }

    private func parseFloat() -> Double {

        let s = consumeWhile {
            ($0 >= "0" && $0 <= "9") ||
                $0 == "."
        }
        return Double(s)!
    }

   private func parseUnit() -> CssUnit {

        let id = parseIdentifier().lowercased()
        if id == "px" {

            return .px
        }
        fatalError("unrecognized unit")
    }

    private func parseIdentifier() -> String {
        return consumeWhile(validIdentifierChar)
    }
}
