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
        
        var request = self.request(Method.POST, endpoint: Endpoint.Tokens, jsonDictionary: parameters).0
        return request
    }
    
    func tokenFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) -> (Token?, NSError?) {
        var token: Token?
        var err = self.handleError(responseData, response: response, error: error)
        if err != nil {
            return (nil, err)
        } else if let data = responseData {
            var serialized = Deserializer.token(data)
            token =  serialized.0
            err = serialized.1
        } else {
            err = NSError(domain: errorDomain.chatsecurePush.rawValue, code: errorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return (token,err)
    }
}