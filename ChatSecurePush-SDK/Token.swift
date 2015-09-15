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
    public let registrationID: String
    public var name: String?
    
    public init (tokenString: String, deviceID: String) {
        self.tokenString = tokenString
        self.registrationID = deviceID
    }
    
    public required init(coder aDecoder: NSCoder) {
        if let tokenString = aDecoder.decodeObjectForKey("tokenString") as? String {
            self.tokenString = tokenString
        } else {
            self.tokenString = ""
        }
        
        if let registrationID = aDecoder.decodeObjectForKey("registrationID") as? String {
            self.registrationID = registrationID
        } else {
            self.registrationID = ""
        }
        
        self.name = aDecoder.decodeObjectForKey("name") as? String
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.tokenString, forKey: "tokenString")
        aCoder.encodeObject(self.registrationID, forKey: "registrationID")
        aCoder.encodeObject(self.name, forKey: "name")
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let newToken = Token(tokenString: self.tokenString, deviceID: self.registrationID)
        newToken.name = self.name
        return newToken
    }
}