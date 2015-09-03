//
//  Deserializer.swift
//  Pods
//
//  Created by David Chiles on 7/14/15.
//
//

import Foundation


public class Serializer {
    
    public class func jsonValue(object:AnyObject) -> [String:AnyObject]? {
        
        var json: [String: AnyObject]? = nil
        
        if let message = object as? Message {
            json = [jsonKeys.token.rawValue: message.token]
            if let data = message.data {
                json?.updateValue(data, forKey: jsonKeys.dataKey.rawValue)
            }
        }
        
        if let token = object as? Token {
            json = [jsonKeys.token.rawValue: token.tokenString, jsonKeys.apnsDeviceKey.rawValue: token.registrationID]
            
            if let name = token.name {
                json?.updateValue(name, forKey: jsonKeys.name.rawValue)
            }
        }
        
        return json
        
    }
}