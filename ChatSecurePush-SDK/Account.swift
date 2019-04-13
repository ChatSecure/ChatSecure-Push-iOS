//
//  Account.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation


@objc open class Account: NSObject, NSCoding, NSCopying {
    @objc public let username: String
    @objc open var token: String?
    @objc open var email: String?
    
    @objc public init (username: String) {
        self.username = username
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let username = aDecoder.decodeObject(forKey: "username") as? String {
            self.username = username
        } else {
            self.username = ""
        }
        self.token = aDecoder.decodeObject(forKey: "token") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.token, forKey: "token")
        aCoder.encode(self.email, forKey: "email")
    }
    
    open func copy(with zone: NSZone?) -> Any {
        let newAccount = Account(username: self.username)
        newAccount.token = self.token
        newAccount.email = self.email
        return newAccount
    }
}
