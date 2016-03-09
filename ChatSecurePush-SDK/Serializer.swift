//
//  Deserializer.swift
//  Pods
//
//  Created by David Chiles on 7/14/15.
//
//

import Foundation


public class Serializer {
    
    public class func jsonValue(object:AnyObject) throws -> [String:AnyObject]? {
        
        var json: [String: AnyObject]? = nil
        
        if let message = object as? Message {
            json = [jsonKeys.token.rawValue: message.token]
            if let data = message.data {
                json?.updateValue(data, forKey: jsonKeys.dataKey.rawValue)
            }
        }
        
        if let token = object as? Token {
            json = [jsonKeys.token.rawValue: token.tokenString]
            
            if let name = token.name {
                json?.updateValue(name, forKey: jsonKeys.name.rawValue)
            }
            
            
            
            if let deviceID = token.registrationID {
                switch token.type {
                case .iOS:
                    json?.updateValue(deviceID, forKey: jsonKeys.apnsDeviceKey.rawValue)
                case .Android:
                    json?.updateValue(deviceID, forKey: jsonKeys.gcmDeviceKey.rawValue)
                default:
                    throw NSError(domain: ErrorDomain.ChatsecurePush.rawValue, code: ErrorStatusCode.NoTokenType.rawValue, userInfo: nil)
                }
                
            }
        }
        
        return json
        
    }
}