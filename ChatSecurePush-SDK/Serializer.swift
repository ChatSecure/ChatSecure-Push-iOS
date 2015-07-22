//
//  Deserializer.swift
//  Pods
//
//  Created by David Chiles on 7/14/15.
//
//

import Foundation


public class Deserializer {
    
    public class func jsonValue(object:AnyObject) -> [String:AnyObject]? {
        
        var json: [String: AnyObject]? = nil
        
        if let message = object as? Message {
            json = [jsonKeys.token.rawValue: message.token]
            if let data = message.data {
                json?.updateValue(data, forKey: jsonKeys.dataKey.rawValue)
            }
        }
        
        return json
        
    }
}