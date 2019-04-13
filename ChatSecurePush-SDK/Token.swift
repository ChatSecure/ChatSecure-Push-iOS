//
//  Token.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

private enum TokenCodingSrings:String {
    case tokenString = "tokenString"
    case registrationID = "registrationID"
    case deviceType = "type"
    case name = "name"
    case expires = "expires"
}

@objc open class Token: NSObject, NSCoding, NSCopying {
    @objc public let tokenString: String
    @objc open var expires:Date?
    @objc open var registrationID: String?
    @objc open var name: String?
    @objc open var type:DeviceKind = .unknown
    
    @objc public init (tokenString: String, type:DeviceKind, deviceID: String?) {
        self.tokenString = tokenString
        self.registrationID = deviceID
        self.type = type
    }
    
    public required init(coder aDecoder: NSCoder) {
        if let tokenString = aDecoder.decodeObject(forKey: TokenCodingSrings.tokenString.rawValue) as? String {
            self.tokenString = tokenString
        } else {
            self.tokenString = ""
        }
        
        if let registrationID = aDecoder.decodeObject(forKey: TokenCodingSrings.registrationID.rawValue) as? String {
            self.registrationID = registrationID
        }
        
        if let type = DeviceKind(rawValue: aDecoder.decodeInteger(forKey: TokenCodingSrings.deviceType.rawValue)) {
            self.type = type
        }
        
        self.name = aDecoder.decodeObject(forKey: TokenCodingSrings.name.rawValue) as? String
        self.expires = aDecoder.decodeObject(forKey: TokenCodingSrings.expires.rawValue) as? Date
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.tokenString, forKey: TokenCodingSrings.tokenString.rawValue)
        aCoder.encode(self.registrationID, forKey: TokenCodingSrings.registrationID.rawValue)
        aCoder.encode(self.name, forKey: TokenCodingSrings.name.rawValue)
        aCoder.encode(self.type.rawValue, forKey: TokenCodingSrings.deviceType.rawValue)
        aCoder.encode(self.expires, forKey: TokenCodingSrings.expires.rawValue)
    }
    
    open func copy(with zone: NSZone?) -> Any {
        let newToken = Token(tokenString: self.tokenString, type: self.type, deviceID: self.registrationID)
        newToken.name = self.name
        newToken.expires = self.expires
        return newToken
    }
}
