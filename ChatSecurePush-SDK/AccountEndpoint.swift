//
//  AccountEndpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation


class AccountEnpoint: APIEndpoint {
    
    func postRequest(_ username: String, password: String, email: String?) throws -> NSMutableURLRequest {
        
        var parameters = [
            jsonKeys.username.rawValue : username,
            jsonKeys.password.rawValue : password,
        ]
        
        parameters[jsonKeys.email.rawValue] = email
        
        return try self.request(.post, endpoint:Endpoint.accounts.rawValue, jsonDictionary:parameters)
    }
    
    func accountFromResponse(_ responseData: Data?, response: URLResponse?, error: NSError?) throws -> Account {
        
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.account(withData: data)
    }
}
