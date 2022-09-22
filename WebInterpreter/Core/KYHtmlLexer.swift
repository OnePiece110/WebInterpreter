//
//  KYHtmlLexer.swift
//  WebInterpreter
//
//  Created by keyon on 2022/9/14.
//

import UIKit

class KYHtmlLexer {

    enum LexerError: Error {
        case unValid
    }

    let text: String
    private var currentChar: Character?
    private var pos = 0
    private var preTokenType: KYHtmlTokenType = .begin
    private var isOpenTag = false

    init(text: String) throws {
        self.text = text
        currentChar = text[text.index(text.startIndex, offsetBy: pos)]
        if currentChar != "<" {
            throw LexerError.unValid
        }
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

    private func isalpha(char: Character) -> Bool {
        let string = String(char)
        let result = string.trimmingCharacters(in: .letters)
        return !(result.count > 0)
    }

    private func peek() ->  Character? {
        let peekPos = pos + 1
        if peekPos > text.count - 1 {
            return nil
        } else {
            return text[text.index(text.startIndex, offsetBy: peekPos)]
        }
    }

    private func value() -> String {
        var result = ""
        while let currentChar = currentChar, isalpha(char: currentChar) {
            advance()
            result += "\(currentChar)"
        }
        return result
    }

    private func attributeValue(openQuote: Character) -> String {
        var result = ""
        while let currentChar = currentChar, currentChar != openQuote {
            advance()
            result += "\(currentChar)"
        }
        return result
    }

    func getNextNode() throws -> KYHtmlToken {
        while let currentChar = currentChar {
            if currentChar.isWhitespace {
                skipWhitespace()
                continue
            }
            if isalpha(char: currentChar) {
                if isOpenTag {
                    preTokenType = .attributeKey
                    return .init(type: .attributeKey, value: value())
                } else {
                    if preTokenType == .openTagStart {
                        isOpenTag = true
                    }
                    return .init(type: .tagName, value: value())
                }
            }
            if currentChar == "<" {
                if peek() == "/" {
                    preTokenType = .closeTagStart
                    advance()
                    advance()
                    return .init(type: .closeTagStart, value: "</")
                }
                preTokenType = .openTagStart
                advance()
                return .init(type: .openTagStart, value: "<")
            }
            if currentChar == ">" {
                isOpenTag = false
                advance()
                if preTokenType == .closeTagStart {
                    return .init(type: .closeTagEnd, value: ">")
                } else {
                    return .init(type: .openTagEnd, value: ">")
                }
            }
            if currentChar == "/" && peek() == ">" {
                isOpenTag = false
                advance()
                advance()
                return .init(type: .closeTagEnd, value: "/>")
            }
            if currentChar == "=", preTokenType == .attributeKey {
                advance()
                let openQuote = self.currentChar ?? "x"
                if !["\"", "'"].contains(openQuote) {
                    throw LexerError.unValid
                }
                advance()
                let value = attributeValue(openQuote: openQuote)
                if self.currentChar != openQuote {
                    throw LexerError.unValid
                }
                advance()
                return .init(type: .attributeValue, value: value)
            }
            advance()
        }
        return .init(type: .eof, value: nil)
    }
}
