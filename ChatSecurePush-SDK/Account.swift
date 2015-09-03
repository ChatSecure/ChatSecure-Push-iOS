//
//  Account.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation


public class Account: NSObject, NSCoding, NSCopying {
    public let username: String
    public var token: String?
    public var email: String?
    
    public init (username: String) {
        self.username = username
    }
    
    public required init(coder aDecoder: NSCoder) {
        if let username = aDecoder.decodeObjectForKey("username") as? String {
            self.username = username
        } else {
            self.username = ""
        }
        self.token = aDecoder.decodeObjectForKey("token") as? String
        self.email = aDecoder.decodeObjectForKey("email") as? String
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.username, forKey: "username")
        aCoder.encodeObject(self.token, forKey: "token")
        aCoder.encodeObject(self.email, forKey: "email")
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        var newAccount = Account(username: self.username)
        newAccount.token = self.token
        newAccount.email = self.email
        return newAccount
    }
}