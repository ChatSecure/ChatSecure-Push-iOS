//
//  Serializer.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

var dispatchToken: Int = 0
var defaultDateFormatter = DateFormatter()

open class Deserializer {
    
    private static var __once: () = { () -> Void in
            defaultDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z"
        }()
    
    //Unsure if this is the most 'Swift' way to do this
    open class func dateFormatter() -> DateFormatter {
        _ = Deserializer.__once
        return defaultDateFormatter
    }
    
    open class func account(withData data: Data) throws -> Account {
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: String] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"Unable to deserialize JSON as String:String"])
        }
        
        guard let username = json[jsonKeys.username.rawValue] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing username"])
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
    
    open class func device(_ data: Data, kind: DeviceKind) throws -> Device {
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"Unable to deserialize JSON as String:AnyObject"])
        }
        
        guard let registrationID = json[jsonKeys.registrationID.rawValue] as? String else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing registartion ID"])
        }
        
        guard let dateCreatedString = json[jsonKeys.dateCreated.rawValue] as? String else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing date created"])
        }
        
        guard let dateCreated = self.dateFormatter().date(from: dateCreatedString) else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON date wrong format"])
        }
        
        let deviceName = json[jsonKeys.name.rawValue] as? String
        let deviceID = json[jsonKeys.deviceID.rawValue] as? String
        let id = json[jsonKeys.id.rawValue] as? String
        
        return Device(registrationID: registrationID, dateCreated: dateCreated, name: deviceName, deviceID: deviceID, id: id)
    }
    
    open class func token(_ jsonDictionary:[String:AnyObject]) throws -> Token {
        guard let tokenString = jsonDictionary[jsonKeys.token.rawValue] as? String else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing token string"])
        }
        
        var dateExpires:Date? = nil
        if let dateExpiresString = jsonDictionary[jsonKeys.dateExpires.rawValue] as? String {
            dateExpires = self.dateFormatter().date(from: dateExpiresString)
        }
        
        if let registrationId = jsonDictionary[jsonKeys.apnsDeviceKey.rawValue] as? String {
            let token = Token(tokenString: tokenString, type: DeviceKind.iOS, deviceID: registrationId)
            token.name = jsonDictionary[jsonKeys.name.rawValue] as? String
            token.expires = dateExpires
            return token
        } else if let registrationId = jsonDictionary[jsonKeys.gcmDeviceKey.rawValue] as? String {
            let token = Token(tokenString: tokenString, type: DeviceKind.android, deviceID: registrationId)
            token.name = jsonDictionary[jsonKeys.name.rawValue] as? String
            token.expires = dateExpires
            return token
        }
        else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing registration ID"])
        }
    }
    
    open class func token(_ data: Data) throws -> Token {
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"Unable to deserialize JSON as String:AnyObject"])
        }
        
        return try self.token(json)
    }
    
    open class func tokens(_ data: Data) throws -> [Token] {
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"Unable to deserialize JSON as String:AnyObject"])
        }
        
        guard let resultsArray = json[jsonKeys.results.rawValue] as? [[String: AnyObject]] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing results Dictionary"])
        }
        var tokenArray : [Token] = []
        for (_,dict) in resultsArray.enumerated() {
            let token = try self.token(dict)
            tokenArray.append(token)
        }
        
        return tokenArray
    }
    
    open class func messageFromPushDictionary(_ userInfo:[AnyHashable: Any]) throws -> Message {
        guard let aps = userInfo[jsonKeys.apsKey.rawValue] as? [String:AnyObject] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"Unable to deserialize JSON as [String:AnyObject]"])
        }
        
        guard let alert = aps[jsonKeys.alertKey.rawValue] as? [String:AnyObject] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing alert dictionary"])
        }
        
        guard let message = alert[jsonKeys.messageKey.rawValue] as? [String: AnyObject] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing message dictionary"])
        }
        
        guard let tokenString = message[jsonKeys.token.rawValue] as? String else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing token string"])
        }
        
        let dataDictionary = message[jsonKeys.dataKey.rawValue] as? [String: AnyObject];
        return Message(token: tokenString, url:nil, data: dataDictionary)
    }
    
    open class func messageFromServerDictionary(_ userInfo:[String: AnyObject], url:URL) throws -> Message {
        guard let tokenString = userInfo[jsonKeys.token.rawValue] as? String else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing token string"])
        }
        
        let dataDictionary = userInfo[jsonKeys.dataKey.rawValue] as? [String: AnyObject];
        return Message(token: tokenString, url:url, data: dataDictionary)
    }
    
    open class func message(_ data: Data, url:URL) throws -> Message {
  
        guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"Unable to deserialize JSON as String:AnyObject"])
        }
        return try self.messageFromServerDictionary(json, url: url)
    }
    
    public class func pubsub(data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"Unable to deserialize JSON as String:AnyObject"])
        }
        
        guard let pubsub = json[jsonKeys.jid.rawValue] as? String else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.badJSON.rawValue, userInfo: [NSLocalizedDescriptionKey:"JSON missing pubsub string"])
        }
        return pubsub
    }
}
