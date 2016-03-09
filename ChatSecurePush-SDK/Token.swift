//
//  Token.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

public class Token: NSObject, NSCoding, NSCopying {
    public let tokenString: String
    public var registrationID: String?
    public var name: String?
    public var type:DeviceKind = .unknown
    
    public init (tokenString: String, type:DeviceKind, deviceID: String?) {
        self.tokenString = tokenString
        self.registrationID = deviceID
        self.type = type
    }
    
    public required init(coder aDecoder: NSCoder) {
        if let tokenString = aDecoder.decodeObjectForKey("tokenString") as? String {
            self.tokenString = tokenString
        } else {
            self.tokenString = ""
        }
        
        if let registrationID = aDecoder.decodeObjectForKey("registrationID") as? String {
            self.registrationID = registrationID
        }
        
        if let type = DeviceKind(rawValue: aDecoder.decodeIntegerForKey("type")) {
            self.type = type
        }
        
        self.name = aDecoder.decodeObjectForKey("name") as? String
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.tokenString, forKey: "tokenString")
        aCoder.encodeObject(self.registrationID, forKey: "registrationID")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeInteger(self.type.rawValue, forKey: "type")
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let newToken = Token(tokenString: self.tokenString, type: self.type, deviceID: self.registrationID)
        newToken.name = self.name
        return newToken
    }
}