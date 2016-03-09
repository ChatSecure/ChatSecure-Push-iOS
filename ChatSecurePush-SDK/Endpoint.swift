//
//  Endpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation

class APIEndpoint {
    
    var baseURL: NSURL
    var token: String?
    
    init (baseUrl: NSURL) {
        self.baseURL = baseUrl
    }
    
    func request(method: Method, endpoint: String, jsonDictionary:[String: AnyObject]?) -> (NSMutableURLRequest, NSError?) {
        let request = NSMutableURLRequest(URL: self.url(endpoint))
        request.HTTPMethod = method.rawValue
        
        var error: NSError? = nil
        if let json = jsonDictionary {
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
            } catch let error1 as NSError {
                error = error1
                request.HTTPBody = nil
            }
            if request.HTTPBody?.length > 0 {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        return (request,error)
    }
    
    func url(endPoint: String) -> NSURL {
        return self.baseURL.URLByAppendingPathComponent(endPoint+"/")
    }
    
    func handleError(data: NSData?, response: NSURLResponse?, error: NSError?) throws {
        
        if let err = error {
            throw err
        }
        
        if let httpResponse = response as? NSHTTPURLResponse {
            try self.validate(httpResponse, responseData:data)
        }
    }
    
    func validate(response: NSHTTPURLResponse, responseData:NSData?) throws {
        var acceptable = false
        if response.statusCode > 199 && response.statusCode < 300 {
            acceptable = true
        }
        
        if(!acceptable) {
            var userInfo : [NSObject:AnyObject]?
            if let data = responseData {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    userInfo = [NSLocalizedDescriptionKey:string]
                }
            }
            
            throw NSError(domain: ErrorDomain.ChatsecurePush.rawValue, code: response.statusCode, userInfo: userInfo)
        }
    }
}