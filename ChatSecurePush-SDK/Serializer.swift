//
//  Serializer.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

var token: dispatch_once_t = 0
var defaultDateFormatter = NSDateFormatter()

class Serializer {
    
    //Unsure if this is the most 'Swift' way to do this
    class func dateFormatter() -> NSDateFormatter {
        dispatch_once(&token, { () -> Void in
            defaultDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z"
        })
        return defaultDateFormatter
    }
    
    class func account(data: NSData) -> (Account?, NSError?) {
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
    
    class func device(data: NSData, kind: DeviceKind) -> (Device?, NSError?) {
        var error: NSError? = nil
        var device: Device? = nil
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? [String: AnyObject] {
            if let registrationID = json[jsonKeys.registrationID.rawValue] as? String {
                var deviceName = json[jsonKeys.name.rawValue] as? String
                var deviceID = json[jsonKeys.deviceID.rawValue] as? String
                if let dateCreatedString = json[jsonKeys.dateCreated.rawValue] as? String {
                    if let dateCreated = self.dateFormatter().dateFromString(dateCreatedString) {
                        device = Device(registrationID: registrationID, dateCreated: dateCreated, name: deviceName, deviceID: deviceID)
                    }
                }
            }
        }
        return (device, error)
    }
}