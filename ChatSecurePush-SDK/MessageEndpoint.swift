//
//  MessageEndpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation


class MessageEndpoint:APIEndpoint {
    
    
    func postRequest(message:Message) throws -> NSMutableURLRequest {
        let jsonDictionary = try Serializer.jsonValue(message)
        let request = self.request(.POST, endpoint: Endpoint.Messages.rawValue, jsonDictionary: jsonDictionary).0
        return request
    }
    
    func messageFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> Message {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.ChatsecurePush.rawValue, code: ErrorStatusCode.NoData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.message(data)
    }
}