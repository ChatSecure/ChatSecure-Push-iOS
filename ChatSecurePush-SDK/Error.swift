//
//  Error.swift
//  Pods
//
//  Created by David Chiles on 3/9/16.
//
//

import Foundation


public enum ErrorDomain: String {
    case ChatsecurePush = "org.chatsecure.push"
}

///Enum of all the status codes used in the SDK for erros
public enum ErrorStatusCode: NSInteger {
    case NoData = 101
    case BadJSON = 102
    case NoTokenType = 103
    case MissingURL = 104
    case CreatingRequest = 105
}

extension NSError {
    
    /**
     Returns an default NSError using the correct domain and enum status code
     
     - Parameter code: The status code
     - Parameter userInfo: The userinfo dictionary including kyes NSLocalized string
     
     - Returns: A ChatSecure push error
     */
    public class func error(code:ErrorStatusCode, userInfo: [NSObject : AnyObject]?) -> NSError {
        return NSError(domain: ErrorDomain.ChatsecurePush.rawValue, code: code.rawValue, userInfo: userInfo)
    }
}