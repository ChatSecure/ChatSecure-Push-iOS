//
//  TestObjects.swift
//  ChatSecurePushExample
//
//  Created by David Chiles on 9/2/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

import Foundation
import ChatSecure_Push_iOS

func uuid() -> String {
    return UUID().uuidString
}

extension Token {
    class func randomToken() -> Token {
        let kindInt = Int(arc4random_uniform(1) + 1)
        let kind = DeviceKind(rawValue: kindInt) ?? DeviceKind.unknown
        return Token(tokenString: uuid(), type: kind, deviceID: uuid())
    }
}
