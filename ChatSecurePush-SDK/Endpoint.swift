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
    
    func request(method: Method, endpoint: Endpoint, jsonDictionary:[String: AnyObject]?) -> (NSMutableURLRequest, NSError?) {
        var request = NSMutableURLRequest(URL: self.url(endpoint))
        request.HTTPMethod = method.rawValue
        
        var error: NSError? = nil
        if let json = jsonDictionary {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.allZeros, error: &error)
            if request.HTTPBody?.length > 0 {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        return (request,error)
    }
    
    func url(endPoint: Endpoint) -> NSURL {
        return self.baseURL.URLByAppendingPathComponent(endPoint.rawValue+"/")
    }
    
    func handleError(data: NSData?, response: NSURLResponse?, error: NSError?) -> NSError?{
        
        if error != nil {
            return error
        }
        
        var err :NSError?;
        if let httpResponse = response as? NSHTTPURLResponse {
            err = self.validate(httpResponse, responseData:data)
        }
        
        return err
    }
    
    func validate(response: NSHTTPURLResponse, responseData:NSData?) -> NSError? {
        let acceptableStatusCodes: Range<Int> = 200..<300
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
            
            return NSError(domain: errorDomain.chatsecurePush.rawValue, code: response.statusCode, userInfo: userInfo)
        }
        
        return nil
    }
}