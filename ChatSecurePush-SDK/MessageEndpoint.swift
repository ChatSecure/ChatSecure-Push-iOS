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
    func postRequest(_ message:Message) throws -> URLRequest {
        let jsonDictionary = try Serializer.jsonValue(message)
        
        if let url = message.url {
            return try APIEndpoint.request(Method.post.rawValue, URL: url, jsonDictionary: jsonDictionary)
        } else {
            return try self.request(.post, endpoint: Endpoint.messages.rawValue, jsonDictionary: jsonDictionary)
        }
    }
    
    func messageFromResponse(_ responseData: Data?, response: URLResponse?, error: Error?) throws -> Message {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        guard let url = response?.url else {
            throw NSError.error(.missingURL, userInfo: [NSLocalizedDescriptionKey:"Required to have a url inorder to create a Message object"])
        }
        
        return try Deserializer.message(data, url: url)
    }
}
