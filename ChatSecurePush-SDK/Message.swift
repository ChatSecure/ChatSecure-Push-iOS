//
//  File.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation


public class Message: NSObject, NSCoding, NSCopying {
    public var token: String
    
    /** Data needs to be a dictionary that can be serialized as JSON */
    public var data: [String:AnyObject]?
    
    public init(token: String, data: [String:AnyObject]?){
        self.token = token
        self.data = data
    }
    
    public required init(coder aDecoder: NSCoder) {
        if let token = aDecoder.decodeObjectForKey("token") as? String {
            self.token = token
        } else {
            self.token = ""
        }
        self.data = aDecoder.decodeObjectForKey("data") as? [String:AnyObject]
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.token, forKey: "token")
        aCoder.encodeObject(self.data, forKey: "data")
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        return Message(token: self.token, data: self.data)
    }
}