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
    case results = "results"
}

public enum ErrorDomain: String {
    case ChatsecurePush = "chatsecure.push"
}

public enum ErrorStatusCode: NSInteger {
    case NoData = 101
    case BadJSON = 102
    case NoTokenType = 103
}

public class Client: NSObject {
    public let baseUrl: NSURL
    public let urlSession: NSURLSession
    public var callbackQueue = NSOperationQueue()
    public var account: Account?
    
    private var appleDeviceEndpoint: APNSDeviceEndpoint
    private var accountEndpoint: AccountEnpoint
    private var tokenEndpoint: TokenEndpoint
    private var messageEndpoint: MessageEndpoint
    
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
        
        let request = self.accountEndpoint.postRequest(username , password: password, email: email)
        self.startDataTask(request, completionHandler: { (data, response, error) -> Void in
            var account:Account? = nil
            var error:NSError? = nil
            do {
                account = try self.accountEndpoint.accountFromResponse(data, response: response, error: error)
            } catch let err as NSError {
                error = err
            }
            
            self.callbackQueue .addOperationWithBlock({ () -> Void in
                completion(account: account,error: error)
            })
        })
    }
    
// MARK: Device
    public func registerDevice(APNSToken: String, name: String?, deviceID: String?, completion: (device: Device?, error: NSError?) -> Void) {
        
        let request = self.appleDeviceEndpoint.postRequest(APNSToken, name: name, deviceID: deviceID, serverID: nil)
        self.startDataTask(request, completionHandler: { (responseData, response, responseError) -> Void in
            var device:Device? = nil
            var error:NSError? = nil
            do {
                device = try self.appleDeviceEndpoint.deviceFromResponse(responseData, response: response, error: responseError)
            } catch let err as NSError {
                error = err
            }
            
            
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(device: device, error: error)
            })
        })
    }
    
    public func updateDevice(serverID: String?, APNSToken: String, name: String?, deviceID: String?, completion: (device: Device?, error: NSError?) -> Void) {
        
        let request = self.appleDeviceEndpoint.putRequest(APNSToken, name: name, deviceID: deviceID, serverID: serverID)
        self.startDataTask(request, completionHandler: { (responseData, response, responseError) -> Void in
            var device:Device? = nil
            var error:NSError? = nil
            do {
                device = try self.appleDeviceEndpoint.deviceFromResponse(responseData, response: response, error: responseError)
            } catch let err as NSError {
                error = err
            }
            
            
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(device: device, error: error)
            })
        })
    }

// MARK: Token
    public func createToken(id:String ,name:String?, completion: (token: Token?, error: NSError?) -> Void ) {
        
        let request = self.tokenEndpoint.postRequest(id , name: name)
        self.startDataTask(request, completionHandler: { (responseData, response, responseError) -> Void in
            var token:Token? = nil
            var error:NSError? = nil
            do {
                token = try self.tokenEndpoint.tokenFromResponse(responseData , response: response, error: responseError)
            } catch let err as NSError {
                error = err
            }
            
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(token: token, error: error)
            })
        })
    }
    
    public func tokens(id:String?, completion:(tokens: [Token]?, error: NSError?) -> Void) {
        let request = self.tokenEndpoint.getRequest(id)
        self.startDataTask(request, completionHandler: { (responseData, response, responseError) -> Void in
            var tokens:[Token]? = nil
            var error:NSError? = nil
            do {
                tokens = try self.tokenEndpoint.tokensFromResponse(responseData , response: response, error: responseError)
            } catch let err as NSError {
                error = err
            }
            
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(tokens: tokens, error: error)
            })
        })
    }

// MARK: Message
    public func messageEndpont() -> NSURL {
        return self.baseUrl.URLByAppendingPathComponent(Endpoint.Messages.rawValue)
    }
    
    public func sendMessage(message:Message, completion: (message: Message?, error: NSError?) -> Void ) {
        do {
            let request = try self.messageEndpoint.postRequest(message)
            self.startDataTask(request, completionHandler: { (responseData, response, responseError) -> Void in
                var message:Message? = nil
                var error:NSError? = nil
                do {
                    message = try self.messageEndpoint.messageFromResponse(responseData , response: response, error: responseError)
                } catch let err as NSError {
                    error = err
                }
                
                self.callbackQueue.addOperationWithBlock({ () -> Void in
                    completion(message: message, error: error)
                })
            })
        } catch let error as NSError {
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(message: nil, error: error)
            })
        }
    }
    
    
// MARK: Data Task
    func startDataTask(request: NSMutableURLRequest, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void))
    {
        request.setValue("gzip;q=1.0,compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = self.account?.token {
            request.setValue("Token "+token, forHTTPHeaderField:"Authorization")
        }
        
        let dataTask = self.urlSession.dataTaskWithRequest(request, completionHandler: completionHandler)
        dataTask.resume()
    }
}