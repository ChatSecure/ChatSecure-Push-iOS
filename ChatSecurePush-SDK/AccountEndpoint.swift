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
        
        var request = self.request(.POST, endpoint:.Accounts, jsonDictionary:parameters).0
        return request
    }
    
    func accountFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) -> (Account?, NSError?){
        var account: Account?
        var err = self.handleError(responseData, response: response, error: error)
        if  err != nil {
            return (nil,err)
        } else if let data = responseData {
            var serialized = Deserializer.account(data)
            account = serialized.0
            err = serialized.1
        } else {
            err = NSError(domain: errorDomain.chatsecurePush.rawValue, code: errorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return (account,err)

    }
}