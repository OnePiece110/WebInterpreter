//
//  ViewController.swift
//  WebInterpreter
//
//  Created by keyon on 2022/9/14.
//

import UIKit
import SnapKit
import Combine

class ViewController: UIViewController {

    var html: String = #"""
    <html>
        <div id="head" class="border"></div>
        <div class="body">
            <div class="center border bottom"></div>
            <div class="center border bottom"></div>
        </div>
    </html>
    """#

    var css: String = #"""
    html {
        width: 300px;
        padding: 20px;
        margin-left: 10px;
        margin-top: 60px;
        background: #ff0000;
    }

    #head {
        height: 40px;
        background: #ffa500;
    }

    .body {
        background: #ffff00;
    }

    .border {
        border-width: 4px;
        border-color: #008000;
    }

    .center {
        margin: auto;
        margin-top: 20px;
        width: 100px;
        height: 80px;
        background: #0000ff;
    }

    .bottom {
        margin-bottom: 20px;
        background: #00ffff;
    }
    """#

    let test = CurrentValueSubject<String, Never>("")
    var cancelAble: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let htmlParse = try KYHtmlParser(text: html)
            let node = try htmlParse.parse()
            let cssParser = try KYCssParser(text: css)
            let cssNode = try cssParser.parse()
            _ = render(superView: self.view, htmlNode: node, cssNode: cssNode, relateView: nil, padding: .zero, parentNode: nil)
        } catch {
            debugPrint(error)
        }
        let test2 = test
        cancelAble = test2.sink { string in
            debugPrint(string)
        }
        test.send("1")
        test.send("2")

    }

    func render(superView: UIView,htmlNode: KYHtmlNode, cssNode: KYCssNode, relateView: UIView?, padding: UIEdgeInsets, parentNode: KYHtmlNode?) -> UIView {
        let view = cssNode.buildViews(parentView: superView, htmlNode: htmlNode, relateView: relateView, padding: padding, parentNode: parentNode)
        renderList(superView: view, htmlNode: htmlNode.child, cssNode: cssNode, relateView: relateView, padding: cssNode.getPadding(htmlNode: htmlNode), parentNode: htmlNode)
        return view
    }

    func renderList(superView: UIView, htmlNode: [KYHtmlNode], cssNode: KYCssNode, relateView: UIView?, padding: UIEdgeInsets,parentNode: KYHtmlNode?) {
        var preView: UIView?
        htmlNode.forEach {
            preView = render(superView: superView, htmlNode: $0, cssNode: cssNode, relateView: preView, padding: padding, parentNode: parentNode)
        }
    }


}

