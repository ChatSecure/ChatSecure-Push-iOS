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
    
    public init (username: String) {
        self.username = username
    }
}