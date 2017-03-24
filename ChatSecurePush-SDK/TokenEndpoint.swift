//
//  TokenEndpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation


class TokenEndpoint: APIEndpoint {
    func postRequest(_ id:String ,name:String?) throws -> URLRequest {
        var parameters = [
            jsonKeys.apnsDeviceKey.rawValue: id
        ]
        parameters[jsonKeys.name.rawValue] = name
        
        let request = try self.request(.post, endpoint: Endpoint.tokens.rawValue, jsonDictionary: parameters)
        return request
    }
    
    func getRequest(_ id:String?) throws -> URLRequest {
        var request = try self.request(.get, endpoint: Endpoint.tokens.rawValue, jsonDictionary: nil)
        if let tokenID = id {
            request.url = request.url?.appendingPathComponent(tokenID)
        }
        
        return request
    }
    
    func deleteRequest(_ id:String) throws -> URLRequest {
        var request = try self.request(.delete, endpoint: Endpoint.tokens.rawValue, jsonDictionary: nil)
        request.url = request.url?.appendingPathComponent("\(id)/")
        return request
    }
    
    func tokenFromResponse(_ responseData: Data?, response: URLResponse?, error: Error?) throws -> Token {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.token(data)
    }
    
    func tokensFromResponse(_ responseData: Data?, response: URLResponse?, error: Error?) throws -> [Token] {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.tokens(data)
    }
}
