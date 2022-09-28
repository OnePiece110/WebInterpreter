//
//  KYWrapper.swift
//  WebInterpreter
//
//  Created by keyon on 2022/9/28.
//

import Foundation

public struct KYWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol KYCompatible: AnyObject { }

extension KYCompatible {
    public var ky: KYWrapper<Self> {
        get { return KYWrapper(self) }
        set { }
    }

    public static var ky: KYWrapper<Self>.Type {
        get { KYWrapper<Self>.self }
        set { }
    }
}

extension NSObject: KYCompatible { }
