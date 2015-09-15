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
        let jsonDictionary = Serializer.jsonValue(message)
        let request = self.request(.POST, endpoint: .Messages, jsonDictionary: jsonDictionary).0
        return request
    }
    
    func messageFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> Message {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: errorDomain.chatsecurePush.rawValue, code: errorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.message(data)
    }
}