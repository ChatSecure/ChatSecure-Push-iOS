//
//  TokenEndpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation


class TokenEndpoint: APIEndpoint {
    func postRequest(id:String ,name:String?) throws -> NSMutableURLRequest {
        var parameters = [
            jsonKeys.apnsDeviceKey.rawValue: id
        ]
        parameters[jsonKeys.name.rawValue] = name
        
        let request = try self.request(Method.POST, endpoint: Endpoint.Tokens.rawValue, jsonDictionary: parameters)
        return request
    }
    
    func getRequest(id:String?) throws -> NSMutableURLRequest {
        let request = try self.request(.GET, endpoint: Endpoint.Tokens.rawValue, jsonDictionary: nil)
        if let tokenID = id {
            request.URL = request.URL?.URLByAppendingPathComponent(tokenID)
        }
        
        return request
    }
    
    func tokenFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> Token {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.ChatsecurePush.rawValue, code: ErrorStatusCode.NoData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.token(data)
    }
    
    func tokensFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> [Token] {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.ChatsecurePush.rawValue, code: ErrorStatusCode.NoData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.tokens(data)
    }
}