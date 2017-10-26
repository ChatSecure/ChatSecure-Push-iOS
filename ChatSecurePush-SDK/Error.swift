//
//  Error.swift
//  Pods
//
//  Created by David Chiles on 3/9/16.
//
//

import Foundation


public enum ErrorDomain: String {
    case chatsecurePush = "org.chatsecure.push"
}

///Enum of all the status codes used in the SDK for erros
public enum ErrorStatusCode: NSInteger {
    case noData = 601
    case badJSON = 602
    case noTokenType = 603
    case missingURL = 604
    case creatingRequest = 605
}

extension NSError {
    
    /**
     Returns an default NSError using the correct domain and enum status code
     
     - Parameter code: The status code
     - Parameter userInfo: The userinfo dictionary including kyes NSLocalized string
     
     - Returns: A ChatSecure push error
     */
    public class func error(_ code:ErrorStatusCode, userInfo: [String: Any]) -> NSError {
        return NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: code.rawValue, userInfo: userInfo)
    }
}
