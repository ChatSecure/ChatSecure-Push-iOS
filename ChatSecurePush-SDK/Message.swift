//
//  File.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation


public class Message: NSObject {
    public var token: Token
    public var payload: String?
    
    init (token: Token, payload: String?) {
        self.token = token
        self.payload = payload
    }
}