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

var firstBuild = true

class KYCssNode {
    var blockTags = [String : [String: CssValue]]()
    var idTags = [String : [String: CssValue]]()
    var classTags = [String : [String: CssValue]]()

    func getPadding(htmlNode: KYHtmlNode) -> UIEdgeInsets {
        let resultAtt = getAttribute(htmlNode: htmlNode)
        let paddingValue = resultAtt.getPXCssValue(forKey: "padding", defaultValue: .length(0, .px))
        var padding = UIEdgeInsets(top: paddingValue, left: paddingValue, bottom: paddingValue, right: paddingValue)
        padding.left = resultAtt.getPXCssValue(forKey: "padding-left", defaultValue: .length(paddingValue, .px))
        padding.top = resultAtt.getPXCssValue(forKey: "padding-top", defaultValue: .length(paddingValue, .px))
        padding.right = resultAtt.getPXCssValue(forKey: "padding-right", defaultValue: .length(paddingValue, .px))
        padding.bottom = resultAtt.getPXCssValue(forKey: "padding-bottom", defaultValue: .length(paddingValue, .px))
        return padding
    }

    func getAttribute(htmlNode: KYHtmlNode) -> [String: CssValue] {
        var resultAtt = [String: CssValue]()
        let blockAtt = blockTags[htmlNode.tagName]
        let idAtt = htmlNode.attribute["id"]?.components(separatedBy: .whitespacesAndNewlines).compactMap { idTags[$0] }
        let classAtt = htmlNode.attribute["class"]?.components(separatedBy: .whitespacesAndNewlines).compactMap { classTags[$0] }
        if let blockAtt = blockAtt {
            resultAtt.merge(blockAtt) { _, param in
                param
            }
        }
        if let idAtt = idAtt {
            resultAtt.merge(idAtt.flatMap { $0 }) { _, param in
                param
            }
        }
        if let classAtt = classAtt {
            resultAtt.merge(classAtt.flatMap{ $0 }) { _, param in
                param
            }
        }
        return resultAtt
    }

    func buildViews(parentView: UIView, htmlNode: KYHtmlNode, relateView: UIView?, padding: UIEdgeInsets, parentNode: KYHtmlNode?) -> UIView {
        let view = UIView()
        let resultAtt = getAttribute(htmlNode: htmlNode)

        var marginEdge: UIEdgeInsets?

        if case let .keyword(text) = resultAtt["margin"], text == "auto" {
            // 暂时不用处理
        } else {
            let marginValue = resultAtt.getPXCssValue(forKey: "margin", defaultValue: .length(0, .px))
            marginEdge = UIEdgeInsets(top: marginValue, left: marginValue, bottom: marginValue, right: marginValue)
        }

        var isFirst = true
        var isLast = true
        if let parentNode = parentNode {
            let index = parentNode.child.firstIndex(where: { $0 == htmlNode}) ?? -1
            isFirst = index == 0
            isLast = index == parentNode.child.count - 1
        }

        var marginLeft: Double?
        var marginRight: Double?
        var marginTop: Double = 0
        var marginBottom: Double = 0

        if let marginEdge = marginEdge {
            marginLeft = resultAtt.getPXCssValue(forKey: "margin-left", defaultValue: .length(marginEdge.left, .px)) + padding.left
            marginTop = resultAtt.getPXCssValue(forKey: "margin-top", defaultValue: .length(marginEdge.top, .px)) + (isFirst ? padding.top : 0)
            marginRight = resultAtt.getPXCssValue(forKey: "margin-right", defaultValue: .length(marginEdge.right, .px)) + padding.right
            marginBottom = resultAtt.getPXCssValue(forKey: "margin-bottom", defaultValue: .length(marginEdge.bottom, .px)) + (isLast ? padding.bottom : 0)
        } else {
            if let value = resultAtt.getPXCssValue(forKey: "margin-left") {
                marginLeft = value + padding.left
            }
            marginTop = resultAtt.getPXCssValue(forKey: "margin-top", defaultValue: .length(0, .px)) + (isFirst ? padding.top : 0)
            if let value = resultAtt.getPXCssValue(forKey: "margin-left") {
                marginRight = value + padding.right
            }
            marginBottom = resultAtt.getPXCssValue(forKey: "margin-bottom", defaultValue: .length(0, .px)) + (isLast ? padding.bottom : 0)
        }


        var size: CGSize = .zero
        size.width = resultAtt.getPXCssValue(forKey: "width", defaultValue: .length(0, .px))
        size.height = resultAtt.getPXCssValue(forKey: "height", defaultValue: .length(0, .px))

        view.backgroundColor = resultAtt.getColorCssValue(forKey: "background", defaultValue: .color(.clear))
        view.layer.borderWidth = resultAtt.getPXCssValue(forKey: "border-width", defaultValue: .length(0, .px))
        view.layer.borderColor = resultAtt.getColorCssValue(forKey: "border-color", defaultValue: .color(.clear))?.cgColor

        parentView.addSubview(view)

        view.snp.makeConstraints { make in
            if marginLeft == nil && marginRight == nil {
                make.centerX.equalToSuperview()
            }
            if let marginLeft = marginLeft {
                make.left.equalTo(parentView.snp.left).offset(marginLeft)
            }

            if let relateView = relateView {
                make.top.equalTo(relateView.snp.bottom).offset(marginTop)
            } else {
                make.top.equalTo(parentView.snp.top).offset(marginTop)
            }
            if size.width != 0 {
                make.width.equalTo(size.width)
            } else if !firstBuild, let marginRight = marginRight {
                make.right.equalTo(parentView.snp.right).offset(-marginRight)
            }
            if size.height != 0 {
                make.height.equalTo(size.height)
            }
            if !firstBuild && isLast {
                make.bottom.equalTo(parentView.snp.bottom).offset(-marginBottom)
            }
        }

        firstBuild = false
        return view
    }
    
}
