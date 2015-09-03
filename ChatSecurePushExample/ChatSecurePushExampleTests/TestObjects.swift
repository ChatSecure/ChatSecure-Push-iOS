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
    return NSUUID().UUIDString
}

extension Token {
    class func randomToken() -> Token {
        return Token(tokenString: uuid(), deviceID: uuid())
    }
}