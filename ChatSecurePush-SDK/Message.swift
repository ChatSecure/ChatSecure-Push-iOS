//
//  File.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation


public class Message: NSObject {
    public var token: String
    
    /**Data needs to be a dictionary that can be serialized as JSON */
    public var data: [String:AnyObject]?
    
    public init(token: String, data: [String:AnyObject]?){
        self.token = token
        self.data = data
    }
}