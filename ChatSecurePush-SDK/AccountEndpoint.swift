//
//  AccountEndpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation


class AccountEnpoint: APIEndpoint {
    
    func postRequest(username: String, password: String, email: String?) -> NSMutableURLRequest {
        
        var parameters = [
            jsonKeys.username.rawValue : username,
            jsonKeys.password.rawValue : password,
        ]
        
        parameters[jsonKeys.email.rawValue] = email
        
        let request = self.request(.POST, endpoint:.Accounts, jsonDictionary:parameters).0
        return request
    }
    
    func accountFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> Account {
        
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: errorDomain.chatsecurePush.rawValue, code: errorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.account(withData: data)
    }
}