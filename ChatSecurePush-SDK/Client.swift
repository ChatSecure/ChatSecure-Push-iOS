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
    case APNS = "device/apns"
}

public enum jsonKeys: String {
    case username = "username"
    case password = "password"
    case email = "email"
    case token = "token"
    case registrationID = "registration_id"
    case name = "name"
    case deviceID = "device_id"
    case active = "active"
    case dateCreated = "date_created" //ISO-8601
}

public class Client: NSObject {
    public let baseUrl: NSURL
    public let urlSession: NSURLSession
    public var callbackQueue = NSOperationQueue()
    public var account: Account?
    
    public init (baseUrl: NSURL, urlSessionConfiguration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),account: Account?) {
        self.baseUrl = baseUrl
        self.urlSession = NSURLSession(configuration: urlSessionConfiguration)
        self.account = account
    }
    
    public func registerNewUser(username: String, password: String, email: String?, completion: (account: Account?,error: NSError?) -> Void) {
        
        var parameters = [
            jsonKeys.username.rawValue : username,
            jsonKeys.password.rawValue : password,
        ]
        
        parameters[jsonKeys.email.rawValue] = email
        
        var dataTask = self.urlSession.dataTaskWithRequest(self.request(.POST, endpoint:.Accounts, jsonDictionary:parameters).0, completionHandler: { (responseData, response, responseError) -> Void in
            
            if responseError != nil {
                self.callbackQueue.addOperationWithBlock({
                    completion(account:nil,error:responseError)
                })
                return
            }
            
            if let data = responseData {
                var serialized = Serializer.account(data)
                self.callbackQueue.addOperationWithBlock({ () -> Void in
                    completion(account:serialized.0,error:serialized.1)
                })
            } else {
                //Error
            }
        })
        
        dataTask.resume()
    }
    
    public func registerDevice(APNSToken: String, name: String?, deviceID: String?, completion: (device: Device?, error: NSError?) -> Void) {
        var parameters = [
            jsonKeys.registrationID.rawValue: APNSToken,
        ]
        
        parameters[jsonKeys.name.rawValue] = name
        parameters[jsonKeys.deviceID.rawValue] = deviceID
        
        var request = self.request(Method.POST, endpoint: Endpoint.APNS, jsonDictionary: parameters).0
        
        var dataTask = self.urlSession.dataTaskWithRequest(request, completionHandler: { (responseData, response, responseError) -> Void in
            if responseError != nil {
                self.callbackQueue.addOperationWithBlock({
                    completion(device:nil,error:responseError)
                })
                return
            }
            
            if let data = responseData {
                var serialized = Serializer.device(data, kind: .iOS)
                self.callbackQueue.addOperationWithBlock({ () -> Void in
                    completion(device:serialized.0,error:serialized.1)
                })
            } else {
                //error
            }
        })
        
        dataTask.resume()
    }
    
    func request(method: Method, endpoint: Endpoint, jsonDictionary:[String: AnyObject]?) -> (NSURLRequest, NSError?) {
        var request = NSMutableURLRequest(URL: self.url(endpoint))
        request.HTTPMethod = method.rawValue
        request.setValue("gzip;q=1.0,compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = self.account?.token {
            request.setValue("Token "+token, forHTTPHeaderField:"Authorization")
        }
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
        return self.baseUrl.URLByAppendingPathComponent(endPoint.rawValue+"/")
    }
    
}