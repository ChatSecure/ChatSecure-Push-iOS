//
//  MessageEndpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation


class MessageEndpoint:APIEndpoint {
    
    /**
     Creates a mutable post reqeust from a message object. If there is an url in the message that is used instead of the base URL.
     
     - Parameter message: The message to be serialized and add to the mutableURLRequest
     - Returns: A mutableURLRequest that can be used to post to the message endpoint
     */
    func postRequest(message:Message) throws -> NSMutableURLRequest {
        let jsonDictionary = try Serializer.jsonValue(message)
        
        if let url = message.url {
            return try APIEndpoint.request(Method.POST.rawValue, URL: url, jsonDictionary: jsonDictionary)
        } else {
            return try self.request(.POST, endpoint: Endpoint.Messages.rawValue, jsonDictionary: jsonDictionary)
        }
    }
    
    func messageFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> Message {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.ChatsecurePush.rawValue, code: ErrorStatusCode.NoData.rawValue, userInfo: nil)
        }
        
        guard let url = response?.URL else {
            throw NSError.error(.MissingURL, userInfo: [NSLocalizedDescriptionKey:"Required to have a url inorder to create a Message object"])
        }
        
        return try Deserializer.message(data, url: url)
    }
}