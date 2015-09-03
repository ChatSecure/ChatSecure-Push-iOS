//
//  Token.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

public class Token: NSObject {
    public let tokenString: String
    public let registrationID: String
    public var name: String?
    
    public init (tokenString: String, deviceID: String) {
        self.tokenString = tokenString
        self.registrationID = deviceID
    }
}