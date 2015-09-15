//
//  TokenEndpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation


class TokenEndpoint: APIEndpoint {
    func postRequest(id:String ,name:String?) -> NSMutableURLRequest {
        var parameters = [
            jsonKeys.apnsDeviceKey.rawValue: id
        ]
        parameters[jsonKeys.name.rawValue] = name
        
        let request = self.request(Method.POST, endpoint: Endpoint.Tokens, jsonDictionary: parameters).0
        return request
    }
    
    func getRequest(id:String?) -> NSMutableURLRequest {
        let request = self.request(.GET, endpoint: .Tokens, jsonDictionary: nil).0
        if let tokenID = id {
            request.URL = request.URL?.URLByAppendingPathComponent(tokenID)
        }
        
        return request
    }
    
    func tokenFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> Token {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: errorDomain.chatsecurePush.rawValue, code: errorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.token(data)
    }
    
    func tokensFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> [Token] {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: errorDomain.chatsecurePush.rawValue, code: errorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.tokens(data)
    }
}