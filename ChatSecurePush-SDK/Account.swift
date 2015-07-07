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
    public let token: String
    public var email: String?
    
    init (username: String, token: String) {
        self.username = username
        self.token = token
    }
}