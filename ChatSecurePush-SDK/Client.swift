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
    case GCM = "device/gcm"
    case Tokens = "tokens"
    case Messages = "messages"
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
    case apnsDeviceKey = "apns_device"
    case gcmDeviceKey = "gcm_device"
    case dataKey = "data"
    case messageKey = "message"
    case apsKey = "aps"
    case alertKey = "alert"
    case id = "id"
}

public enum errorDomain: String {
    case chatsecurePush = "chatsecure.push"
}

public enum errorStatusCode: NSInteger {
    case noData = 101
}

public class Client: NSObject {
    public let baseUrl: NSURL
    public let urlSession: NSURLSession
    public var callbackQueue = NSOperationQueue()
    public var account: Account?
    
    var appleDeviceEndpoint: APNSDeviceEndpoint
    var accountEndpoint: AccountEnpoint
    var tokenEndpoint: TokenEndpoint
    var messageEndpoint: MessageEndpoint
    
    public init (baseUrl: NSURL, urlSessionConfiguration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),account: Account?) {
        self.baseUrl = baseUrl
        self.urlSession = NSURLSession(configuration: urlSessionConfiguration)
        self.account = account
        self.appleDeviceEndpoint = APNSDeviceEndpoint(baseUrl: self.baseUrl)
        self.accountEndpoint = AccountEnpoint(baseUrl: self.baseUrl)
        self.tokenEndpoint = TokenEndpoint(baseUrl: self.baseUrl)
        self.messageEndpoint = MessageEndpoint(baseUrl: self.baseUrl)
    }
    
// MARK: User
    public func registerNewUser(username: String, password: String, email: String?, completion: (account: Account?,error: NSError?) -> Void) {
        
        var request = self.accountEndpoint.postRequest(username , password: password, email: email)
        self.startDataTask(request, completionHandler: { (data, response, error) -> Void in
            var result = self.accountEndpoint.accountFromResponse(data, response: response, error: error)
            self.callbackQueue .addOperationWithBlock({ () -> Void in
                completion(account: result.0,error: result.1)
            })
        })
    }
    
// MARK: Device
    public func registerDevice(APNSToken: String, name: String?, deviceID: String?, completion: (device: Device?, error: NSError?) -> Void) {
        
        var request = self.appleDeviceEndpoint.postRequest(APNSToken, name: name, deviceID: deviceID)
        self.startDataTask(request, completionHandler: { (responseData, response, responseError) -> Void in
            var result = self.appleDeviceEndpoint.deviceFromResponse(responseData, response: response, error: responseError)
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(device: result.0, error: result.1)
            })
        })
    }

// MARK: Token
    public func createToken(id:String ,name:String?, completion: (token: Token?, error: NSError?) -> Void ) {
        
        var request = self.tokenEndpoint.postRequest(id , name: name)
        self.startDataTask(request, completionHandler: { (responseData, response, responseError) -> Void in
            var result = self.tokenEndpoint.tokenFromResponse(responseData , response: response, error: responseError)
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(token: result.0, error: result.1)
            })
        })
    }

// MARK: Message
    public func sendMessage(message:Message, completion: (message: Message?, error: NSError?) -> Void ) {
        var request = self.messageEndpoint.postRequest(message)
        self.startDataTask(request, completionHandler: { (responseData, response, responseError) -> Void in
            var result = self.messageEndpoint.messageFromResponse(responseData , response: response, error: responseError)
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(message: result.0, error: result.1)
            })
        })
    }
    
    
// MARK: Data Task
    func startDataTask(request: NSMutableURLRequest, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?)
    {
        request.setValue("gzip;q=1.0,compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = self.account?.token {
            request.setValue("Token "+token, forHTTPHeaderField:"Authorization")
        }
        
        var dataTask = self.urlSession.dataTaskWithRequest(request, completionHandler: completionHandler)
        dataTask.resume()
    }
}