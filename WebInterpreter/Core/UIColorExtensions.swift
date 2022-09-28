//
//  UIColorExtensions.swift
//  BMCore
//
//  Created by Chris on 2022/3/9.
//

import Foundation
import UIKit

public extension KYWrapper where Base: UIColor {
    /// 以一个16进制字符串和一个透明度值创建一个颜色
    ///
    /// - Parameters:
    ///   - hex: 一个16进制字符串 (例如: "EDE7F6", "0xEDE7F6", "#EDE7F6", "#0ff", "0xF0F")
    ///   - alpha: 一个可选的透明度值 (默认是 1)
    static func color(hex: String, alpha: CGFloat = 1.0) -> UIColor? {
        var string = ""
        if hex.lowercased().hasPrefix("0x") {
            string = hex.replacingOccurrences(of: "0x", with: "")
        } else if hex.hasPrefix("#") {
            string = hex.replacingOccurrences(of: "#", with: "")
        } else {
            string = hex
        }
        if string.count == 3 {
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }
        guard let hexValue = Int(string, radix: 16) else { return nil }
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    /// Create a UIColor from a UInt32 integer
    /// - Parameters:
    ///   - hex32: Hex Value
    ///   - alpha: Alpha
    static func color(hex: UInt32, alpha: CGFloat = 1) -> UIColor {
        let divisor = CGFloat(255)
        let red = CGFloat((hex & 0xFF0000) >> 16) / divisor
        let green = CGFloat((hex & 0x00FF00) >> 8) / divisor
        let blue = CGFloat(hex & 0x0000FF) / divisor
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// 返回颜色的十六进制字符串
    var hex: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        base.getRed(&r, green: &g, blue: &b, alpha: &a)

        if a == 1.0 {
            let rInt = Int(r * 255) << 16
            let gInt = Int(g * 255) << 8
            let bInt = Int(b * 255)
            let rgb = rInt | gInt | bInt
            return String(format: "#%06x", rgb)
        } else {
            let rInt = Int(r * 255) << 24
            let gInt = Int(g * 255) << 16
            let bInt = Int(b * 255) << 8
            let aInt = Int(a * 255)
            let rgba = rInt | gInt | bInt | aInt
            return String(format: "#%08x", rgba)
        }
    }
}

extension Dictionary {

    /// 通过指定key值，获取String类型的value
    /// - Parameters:
    ///   - key: 指定的key
    ///   - def: 获取不到，或者转换失败时返回的值（默认为空字符串）
    /// - Returns: String类型的value
    public func getString(forKey key: Key, defaultValue def: String = "") -> String {
        if let str = self[key] as? String {
            return str
        }
        return def
    }

    /// 通过指定key值，获取Float类型的value
    /// - Parameters:
    ///   - key: 指定的key
    ///   - def: 获取不到，或者转换失败时返回的值（默认为0）
    /// - Returns: Float类型的value
    public func getFloat(forKey key: Key, defaultValue def: Float = 0.0) -> Float {
        if let num = self[key] as? Float {
            return num
        } else if let str = self[key] as? String {
            if let val = Float(str) {
                return val
            }
        } else if let num = self[key] as? NSNumber {
            return Float(truncating: num)
        }
        return def
    }

    /// 通过指定key值，获取Double类型的value
    /// - Parameters:
    ///   - key: 指定的key
    ///   - def: 获取不到，或者转换失败时返回的值（默认为0）
    /// - Returns: Double类型的value
    public func getDouble(forKey key: Key, defaultValue def: Double = 0.0) -> Double {
        if let num = self[key] as? Double {
            return num
        } else if let str = self[key] as? String {
            if let val = Double(str) {
                return val
            }
        } else if let num = self[key] as? NSNumber {
            return Double(truncating: num)
        }
        return def
    }

    /// 通过指定key值，获取Int类型的value
    /// - Parameters:
    ///   - key: 指定的key
    ///   - def: 获取不到，或者转换失败时返回的值（默认为0）
    /// - Returns: Int类型的value
    public func getInt(forKey key: Key, defaultValue def: Int = 0) -> Int {
        if let num = self[key] as? Int {
            return num
        } else if let str = self[key] as? String {
            if let val = Int(str) {
                return val
            }
        } else if let num = self[key] as? NSNumber {
            return Int(truncating: num)
        }
        return def
    }

    /// 通过指定key值，获取Bool类型的value
    /// - Parameters:
    ///   - key: 指定的key
    ///   - def: 获取不到，或者转换失败时返回的值（默认为false）
    /// - Returns: Bool类型的value
    public func getBool(forKey key: Key, defaultValue def: Bool = false) -> Bool {
        if let val = self[key] as? Bool {
            return val
        } else if let num = self[key] as? NSNumber {
            if num == 0 {
                return false
            } else if num == 1 {
                return true
            }
        } else if let str = self[key] as? String {
            if str.lowercased() == "true" || str.lowercased() == "yes" {
                return true
            } else if str.lowercased() == "false" || str.lowercased() == "no" {
                return false
            }
        }
        return def
    }

    public func getPXCssValue(forKey key: Key, defaultValue def: CssValue) -> Double {
        if case let .length(value, _) = self[key] as? CssValue {
            return value
        }
        return def.px
    }

    public func getPXCssValue(forKey key: Key) -> Double? {
        if case let .length(value, _) = self[key] as? CssValue {
            return value
        }
        return nil
    }

    public func getColorCssValue(forKey key: Key, defaultValue def: CssValue) -> UIColor? {
        if case let .color(color) = self[key] as? CssValue {
            return color
        }
        return def.color
    }
}
