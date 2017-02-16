//
//  File.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation


open class Message: NSObject, NSCoding, NSCopying {
    /// The token string
    open var token: String
    open var url: URL?
    
    /// Data needs to be a dictionary that can be serialized as JSON
    open var data: [String:Any]?
    
    public init(token: String, url:URL?, data: [String:Any]?){
        self.token = token
        self.url = url
        self.data = data
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.token = ""
        super.init()
        
        guard let token = aDecoder.decodeObject(forKey: "token") as? String else  {
            return nil
        }
        self.url = aDecoder.decodeObject(forKey: "url") as? URL
        self.data = aDecoder.decodeObject(forKey: "data") as? [String:AnyObject]
        self.token = token
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: "token")
        aCoder.encode(self.data, forKey: "data")
        aCoder.encode(self.url, forKey: "url")
    }
    
    open func copy(with zone: NSZone?) -> Any {
        return Message(token: self.token, url: self.url, data: self.data)
    }
}
