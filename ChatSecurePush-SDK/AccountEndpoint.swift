//
//  AccountEndpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation


class AccountEnpoint: APIEndpoint {
    
    func postRequest(username: String, password: String, email: String?) throws -> NSMutableURLRequest {
        
        var parameters = [
            jsonKeys.username.rawValue : username,
            jsonKeys.password.rawValue : password,
        ]
        
        parameters[jsonKeys.email.rawValue] = email
        
        return try self.request(.POST, endpoint:Endpoint.Accounts.rawValue, jsonDictionary:parameters)
    }
    
    func accountFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> Account {
        
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.ChatsecurePush.rawValue, code: ErrorStatusCode.NoData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.account(withData: data)
    }
}