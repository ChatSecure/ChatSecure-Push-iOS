//
//  Account.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation


public class Account: NSObject {
    public let username: String
    public var token: String?
    public var email: String?
    
    init (username: String) {
        self.username = username
    }
}

class AccountSerializer {
    class func account(data: NSData) -> (Account?, NSError?) {
        var error: NSError? = nil
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? [String: String] {
            
            if let username = json[jsonKeys.username.rawValue] {
                var account = Account(username: username)
                if let token = json[jsonKeys.token.rawValue] {
                    account.token = token
                }
                
                if let email = json[jsonKeys.email.rawValue] {
                    account.email = email
                }
                return (account, nil)
            } else {
                //error
            }
        }
        
        return (nil, error)
    }
}