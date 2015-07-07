//
//  Client.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

public enum Method: String {
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

public enum Endpoint: String {
    case Accounts = "accounts"
}

public enum jsonKeys: String {
    case username = "username"
    case password = "password"
    case email = "email"
    case token = "token"
}

public class Client: NSObject {
    public let baseUrl: NSURL
    public let urlSession: NSURLSession
    public var callbackQueue = NSOperationQueue()
    
    public init (baseUrl: NSURL, urlSessionConfiguration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()) {
        self.baseUrl = baseUrl
        self.urlSession = NSURLSession(configuration: urlSessionConfiguration)
    }
    
    public func registerNewUser(username: String, password: String, email: String?, completion: (Account?, NSError?) -> Void) {
        
        var parameters = [
            jsonKeys.username.rawValue : username,
            jsonKeys.password.rawValue : password
        ]
        
        parameters[jsonKeys.email.rawValue] = email
        
        var dataTask = self.urlSession.dataTaskWithRequest(self.request(.POST, endpoint:.Accounts, jsonDictionary:parameters).0, completionHandler: { (responseData, response, responseError) -> Void in
            
            if responseError != nil {
                self.callbackQueue.addOperationWithBlock({
                    completion(nil,responseError)
                })
                return
            }
            
            if let data = responseData {
                var serialized = AccountSerializer.account(data)
                self.callbackQueue.addOperationWithBlock({ () -> Void in
                    completion(serialized.0,serialized.1)
                })
            } else {
                //Error
            }
        })
        
        dataTask.resume()
    }
    
    func request(method: Method, endpoint: Endpoint, jsonDictionary:[String: AnyObject]?) -> (NSURLRequest, NSError?) {
        var request = NSMutableURLRequest(URL: self.url(endpoint))
        request.HTTPMethod = method.rawValue
        request.setValue("gzip;q=1.0,compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
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
        return self.baseUrl.URLByAppendingPathComponent(endPoint.rawValue)
    }
    
}