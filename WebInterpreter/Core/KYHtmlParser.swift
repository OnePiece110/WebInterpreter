//
//  KYHtmlParser.swift
//  WebInterpreter
//
//  Created by keyon on 2022/9/14.
//

import UIKit

class KYHtmlParser {

    enum ParserError: Error {
        case unValid
    }

    let lexer: KYHtmlLexer
    private var currentToken: KYHtmlToken
    private var root = [KYHtmlNode]()


    init(text: String) throws {
        self.lexer = try KYHtmlLexer(text: text)
        self.currentToken = try lexer.getNextNode()
    }

    private func eat(type: KYHtmlTokenType) throws {
        if currentToken.type == type {
            currentToken = try lexer.getNextNode()
        } else {
            throw ParserError.unValid
        }
    }

    private func compoundStatement() throws -> KYHtmlNode {
        try eat(type: .openTagStart)
        let node = KYHtmlNode()
        guard let tagName = currentToken.value else {
            throw ParserError.unValid
        }
        node.tagName = tagName
        try eat(type: .tagName)
        node.attribute = try parseAttribute()
        if currentToken.type == .openTagEnd {
            try eat(type: .openTagEnd)
            node.child = try compoundStatementList(tagName: node.tagName)
        } else if currentToken.type == .closeTagEnd {
            try eat(type: .closeTagEnd)
        } else {
            throw ParserError.unValid
        }
        return node
    }

    private func parseAttribute() throws -> [String: String] {
        var map = [String: String]()
        while currentToken.type == .attributeKey {
            guard let key = currentToken.value else { throw ParserError.unValid }
            try eat(type: .attributeKey)
            guard let value = currentToken.value else { throw ParserError.unValid }
            try eat(type: .attributeValue)
            map[key] = value
        }
        return map
    }

    private func compoundStatementList(tagName: String) throws -> [KYHtmlNode] {
        var nodes = [KYHtmlNode]()
        while currentToken.type != .eof {
            if currentToken.type == .closeTagStart {
                try eat(type: .closeTagStart)
                if  tagName == currentToken.value {
                    try eat(type: .tagName)
                    try eat(type: .closeTagEnd)
                    break
                } else {
                    throw ParserError.unValid
                }
            }

            if currentToken.type == .openTagStart {
                let node = try compoundStatement()
                nodes.append(node)
            }
        }
        return nodes
    }

    func parse() throws -> KYHtmlNode {
        var node = KYHtmlNode()
        do {
            node = try compoundStatement()
        } catch {
            debugPrint(error)
        }
        if currentToken.type != .eof {
            throw ParserError.unValid
        }
        return node
    }
}
