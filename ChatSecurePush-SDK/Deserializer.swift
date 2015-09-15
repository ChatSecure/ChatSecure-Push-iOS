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
    
    public class func account(withData data: NSData) throws -> Account {
        
        guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: String] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        guard let username = json[jsonKeys.username.rawValue] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        let account = Account(username: username)
        if let token = json[jsonKeys.token.rawValue] {
            account.token = token
        }
        
        if let email = json[jsonKeys.email.rawValue] {
            account.email = email
        }
        return account
    }
    
    public class func device(data: NSData, kind: DeviceKind) throws -> Device {
        
        guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        guard let registrationID = json[jsonKeys.registrationID.rawValue] as? String else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        guard let dateCreatedString = json[jsonKeys.dateCreated.rawValue] as? String else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        guard let dateCreated = self.dateFormatter().dateFromString(dateCreatedString) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        let deviceName = json[jsonKeys.name.rawValue] as? String
        let deviceID = json[jsonKeys.deviceID.rawValue] as? String
        let id = json[jsonKeys.id.rawValue] as? String
        
        return Device(registrationID: registrationID, dateCreated: dateCreated, name: deviceName, deviceID: deviceID, id: id)
    }
    
    public class func token(jsonDictionary:[String:AnyObject]) throws -> Token {
        guard let tokenString = jsonDictionary[jsonKeys.token.rawValue] as? String else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        if let registrationId = jsonDictionary[jsonKeys.apnsDeviceKey.rawValue] as? String {
            let token = Token(tokenString: tokenString, deviceID: registrationId)
            token.name = jsonDictionary[jsonKeys.name.rawValue] as? String
            return token
        } else if let registrationId = jsonDictionary[jsonKeys.gcmDeviceKey.rawValue] as? String {
            let token = Token(tokenString: tokenString, deviceID: registrationId)
            token.name = jsonDictionary[jsonKeys.name.rawValue] as? String
            return token
        }
        else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }
    
    public class func token(data: NSData) throws -> Token {
        
        guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        return try self.token(json)
    }
    
    public class func tokens(data: NSData) throws -> [Token] {
        
        guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        guard let resultsArray = json[jsonKeys.results.rawValue] as? [[String: AnyObject]] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        var tokenArray : [Token] = []
        for (_,dict) in resultsArray.enumerate() {
            let token = try self.token(dict)
            tokenArray.append(token)
        }
        
        return tokenArray
    }
    
    public class func messageFromPushDictionary(userInfo:[NSObject: AnyObject]) throws -> Message {
        guard let aps = userInfo[jsonKeys.apsKey.rawValue] as? [String:AnyObject] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        guard let alert = aps[jsonKeys.alertKey.rawValue] as? [String:AnyObject] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        guard let message = alert[jsonKeys.messageKey.rawValue] as? [String: AnyObject] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        guard let tokenString = message[jsonKeys.token.rawValue] as? String else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        let dataDictionary = message[jsonKeys.dataKey.rawValue] as? [String: AnyObject];
        return Message(token: tokenString, data: dataDictionary)
    }
    
    public class func messageFromServerDictionary(userInfo:[String: AnyObject]) throws -> Message {
        guard let tokenString = userInfo[jsonKeys.token.rawValue] as? String else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        let dataDictionary = userInfo[jsonKeys.dataKey.rawValue] as? [String: AnyObject];
        return Message(token: tokenString, data: dataDictionary)
    }
    
    public class func message(data: NSData) throws -> Message {
  
        guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject] else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        return try self.messageFromServerDictionary(json)
    }
}