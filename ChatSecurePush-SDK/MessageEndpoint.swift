//
//  MessageEndpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation


class MessageEndpoint:APIEndpoint {
    
    
    func postRequest(message:Message) -> NSMutableURLRequest {
        var jsonDictionary = Serializer.jsonValue(message)
        var request = self.request(.POST, endpoint: .Messages, jsonDictionary: jsonDictionary).0
        return request
    }
    
    func messageFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) -> (Message?, NSError?) {
        var message: Message?
        var err = self.handleError(responseData, response: response, error: error)
        if err != nil {
            return (nil, err)
        } else if let data = responseData {
            var serialized = Deserializer.message(data)
            message =  serialized.0
            err = serialized.1
        } else {
            err = NSError(domain: errorDomain.chatsecurePush.rawValue, code: errorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return (message,err)
        
    }
}