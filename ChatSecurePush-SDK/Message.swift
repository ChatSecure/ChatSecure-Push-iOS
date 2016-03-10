//
//  File.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation


public class Message: NSObject, NSCoding, NSCopying {
    /// The token string
    public var token: String
    public var url: NSURL?
    
    /// Data needs to be a dictionary that can be serialized as JSON
    public var data: [String:AnyObject]?
    
    public init(token: String, url:NSURL?, data: [String:AnyObject]?){
        self.token = token
        self.url = url
        self.data = data
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.token = ""
        super.init()
        
        guard let token = aDecoder.decodeObjectForKey("token") as? String else  {
            return nil
        }
        self.url = aDecoder.decodeObjectForKey("url") as? NSURL
        self.data = aDecoder.decodeObjectForKey("data") as? [String:AnyObject]
        self.token = token
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.token, forKey: "token")
        aCoder.encodeObject(self.data, forKey: "data")
        aCoder.encodeObject(self.url, forKey: "url")
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        return Message(token: self.token, url: self.url, data: self.data)
    }
}