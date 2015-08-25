//
//  Serializer.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

var dispatchToken: dispatch_once_t = 0
var defaultDateFormatter = NSDateFormatter()

public class Deserializer {
    
    //Unsure if this is the most 'Swift' way to do this
    class func dateFormatter() -> NSDateFormatter {
        dispatch_once(&dispatchToken, { () -> Void in
            defaultDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z"
        })
        return defaultDateFormatter
    }
    
    public class func account(data: NSData) -> (Account?, NSError?) {
        var error: NSError? = nil
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? [String: String] {
            
            if let username = json[jsonKeys.username.rawValue] {
                var account = Account(username: username)
                if let token = json[jsonKeys.token.rawValue] {
                    account.token = token
                }
                
                if let email = json[jsonKeys.email.rawValue] {
                    account.email = email
                }
                return (account, nil)
            } else {
                //error
            }
        }
        return (nil, error)
    }
    
    public class func device(data: NSData, kind: DeviceKind) -> (Device?, NSError?) {
        var error: NSError? = nil
        var device: Device? = nil
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? [String: AnyObject] {
            if let registrationID = json[jsonKeys.registrationID.rawValue] as? String {
                var deviceName = json[jsonKeys.name.rawValue] as? String
                var deviceID = json[jsonKeys.deviceID.rawValue] as? String
                var id = json[jsonKeys.id.rawValue] as? String
                if let dateCreatedString = json[jsonKeys.dateCreated.rawValue] as? String {
                    if let dateCreated = self.dateFormatter().dateFromString(dateCreatedString) {
                        device = Device(registrationID: registrationID, dateCreated: dateCreated, name: deviceName, deviceID: deviceID, id: id)
                    }
                }
            }
        }
        return (device, error)
    }
    
    public class func token(data: NSData) -> (Token?, NSError?) {
        var error: NSError? = nil
        var token: Token? = nil
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? [String: AnyObject] {
            if let tokenString = json[jsonKeys.token.rawValue] as? String {
                if let registrationId = json[jsonKeys.apnsDeviceKey.rawValue] as? String {
                    token = Token(tokenString: tokenString, deviceID: registrationId)
                }
                
                if let registrationId = json[jsonKeys.gcmDeviceKey.rawValue] as? String {
                    token = Token(tokenString: tokenString, deviceID: registrationId)
                }
                
                token?.name = json[jsonKeys.name.rawValue] as? String
            }
        }
        
        return (token, error)
    }
    
    public class func messageFromDictionary(userInfo:[NSObject: AnyObject]) -> Message? {
        if let aps = userInfo[jsonKeys.apsKey.rawValue] as? [String:AnyObject] {
            if let alert = aps[jsonKeys.alertKey.rawValue] as? [String:AnyObject] {
                if let message = alert[jsonKeys.messageKey.rawValue] as? [String: AnyObject] {
                    if let tokenString = message[jsonKeys.token.rawValue] as? String {
                        var dataDictionary = message[jsonKeys.dataKey.rawValue] as? [String: AnyObject];
                        return Message(token: tokenString, data: dataDictionary)
                    }
                }
            }
        }
        return nil
    }
    
    public class func message(data: NSData) -> (Message?, NSError?) {
        var error: NSError? = nil
        var message: Message? = nil
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? [String: AnyObject] {
            message = self.messageFromDictionary(json)
        }
        return (message, error)
    }
}