//
//  Token.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

private enum TokenCodingSrings:String {
    case TokenString = "tokenString"
    case RegistrationID = "registrationID"
    case DeviceType = "type"
    case Name = "name"
    case Expires = "expires"
}

public class Token: NSObject, NSCoding, NSCopying {
    public let tokenString: String
    public var expires:NSDate?
    public var registrationID: String?
    public var name: String?
    public var type:DeviceKind = .unknown
    
    public init (tokenString: String, type:DeviceKind, deviceID: String?) {
        self.tokenString = tokenString
        self.registrationID = deviceID
        self.type = type
    }
    
    public required init(coder aDecoder: NSCoder) {
        if let tokenString = aDecoder.decodeObjectForKey(TokenCodingSrings.TokenString.rawValue) as? String {
            self.tokenString = tokenString
        } else {
            self.tokenString = ""
        }
        
        if let registrationID = aDecoder.decodeObjectForKey(TokenCodingSrings.RegistrationID.rawValue) as? String {
            self.registrationID = registrationID
        }
        
        if let type = DeviceKind(rawValue: aDecoder.decodeIntegerForKey(TokenCodingSrings.DeviceType.rawValue)) {
            self.type = type
        }
        
        self.name = aDecoder.decodeObjectForKey(TokenCodingSrings.Name.rawValue) as? String
        self.expires = aDecoder.decodeObjectForKey(TokenCodingSrings.Expires.rawValue) as? NSDate
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.tokenString, forKey: TokenCodingSrings.TokenString.rawValue)
        aCoder.encodeObject(self.registrationID, forKey: TokenCodingSrings.RegistrationID.rawValue)
        aCoder.encodeObject(self.name, forKey: TokenCodingSrings.Name.rawValue)
        aCoder.encodeInteger(self.type.rawValue, forKey: TokenCodingSrings.DeviceType.rawValue)
        aCoder.encodeObject(self.expires, forKey: TokenCodingSrings.Expires.rawValue)
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let newToken = Token(tokenString: self.tokenString, type: self.type, deviceID: self.registrationID)
        newToken.name = self.name
        newToken.expires = self.expires
        return newToken
    }
}