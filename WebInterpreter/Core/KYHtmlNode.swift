//
//  KYNode.swift
//  WebInterpreter
//
//  Created by keyon on 2022/9/14.
//

import UIKit

class KYHtmlNode {
    var tagName: String = ""
    var attribute: [String: String] = [:]
    var text: String = ""
    var child: [KYHtmlNode] = []
}
