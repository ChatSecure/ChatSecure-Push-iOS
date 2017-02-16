//
//  Deserializer.swift
//  Pods
//
//  Created by David Chiles on 7/14/15.
//
//

import Foundation


open class Serializer {
    
    open class func jsonValue(_ object:AnyObject) throws -> [String:AnyObject]? {
        
        var json: [String: AnyObject]? = nil
        
        if let message = object as? Message {
            json = [jsonKeys.token.rawValue: message.token as AnyObject]
            if let data = message.data {
                json?.updateValue(data as AnyObject, forKey: jsonKeys.dataKey.rawValue)
            }
        }
        
        if let token = object as? Token {
            json = [jsonKeys.token.rawValue: token.tokenString as AnyObject]
            
            if let name = token.name {
                json?.updateValue(name as AnyObject, forKey: jsonKeys.name.rawValue)
            }
            
            
            
            if let deviceID = token.registrationID {
                switch token.type {
                case .iOS:
                    json?.updateValue(deviceID as AnyObject, forKey: jsonKeys.apnsDeviceKey.rawValue)
                case .android:
                    json?.updateValue(deviceID as AnyObject, forKey: jsonKeys.gcmDeviceKey.rawValue)
                default:
                    throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.noTokenType.rawValue, userInfo: nil)
                }
                
            }
        }
        
        return json
        
    }
}
