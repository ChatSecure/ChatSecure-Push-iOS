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

/// An API client that performs calls to the [ChatSecure-Push-Server](https://github.com/chatsecure/chatsecure-push-server)
public class Client: NSObject {
    /// The API URL in the format in the format `https://example.com/api/v1/`
    public let baseUrl: NSURL
    /// The url session to be used for calls to the server
    public let urlSession: NSURLSession
    /// This is the queue where callbacks from the `Client` are executed on
    public var callbackQueue = NSOperationQueue()
    /// The account containing the data need for server authentication. This needs to be set after `registerNewUser` with the returned account.
    public var account: Account?
    
    private var appleDeviceEndpoint: APNSDeviceEndpoint
    private var accountEndpoint: AccountEnpoint
    private var tokenEndpoint: TokenEndpoint
    private var messageEndpoint: MessageEndpoint
    
    
    /**
     Initializes an API Client with the URL to use in future methods.
     
     - Parameters: 
        - baseUrl: The URL for the API server in the format `https://example.com/api/v1/`
        - urlSessionConfiguration: A valid session configuration default is `NSURLSessionConfiguration.defaultSessionConfiguration()`
        - account: If there is an already existsing account (possibly persisted to disk) it should be passed in here. It should have a valid token that is to be used to authenticate against the server
     
     - Returns: A new `Client`
     */
    public init(baseUrl: NSURL, urlSessionConfiguration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),account: Account?) {
        self.baseUrl = baseUrl
        self.urlSession = NSURLSession(configuration: urlSessionConfiguration)
        self.account = account
        self.appleDeviceEndpoint = APNSDeviceEndpoint(baseUrl: self.baseUrl)
        self.accountEndpoint = AccountEnpoint(baseUrl: self.baseUrl)
        self.tokenEndpoint = TokenEndpoint(baseUrl: self.baseUrl)
        self.messageEndpoint = MessageEndpoint(baseUrl: self.baseUrl)
    }
    
// MARK: User
    
    /**
    Creates a new user on the remote server.
    
    - Parameters:
        - username: The desiered username for the new account
        - password: The desiered password for the new account
        - email: Optional email address. Useful for future password resets
        - completion: called once an account is created or an error occurs.
    */
    public func registerNewUser(username: String, password: String, email: String?, completion: (account: Account?,error: NSError?) -> Void) {
        do {
            let request = try self.accountEndpoint.postRequest(username , password: password, email: email)
            self.startDataTask(request, completionHandler: { (data, response, error) -> Void in
                var account:Account? = nil
                var error:NSError? = nil
                do {
                    account = try self.accountEndpoint.accountFromResponse(data, response: response, error: error)
                } catch let err as NSError {
                    error = err
                }
                
                self.callbackQueue.addOperationWithBlock({ () -> Void in
                    completion(account: account,error: error)
                })
            })
        } catch let err as NSError {
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(account: nil, error: err)
            })
        }
        
    }
    
// MARK: Device
    
    /**
    Register a new device.
    
    - Parameters:
        - APNSToken: This is the token received from Apple for 'this' device
        - name: Optional name for the device to make managing devices easier for the user
        - deviceID: Optional id to identify the device by
        - compltion: The completion closure called once a device is returned or there is an error
    */
    public func registerDevice(APNSToken: String, name: String?, deviceID: String?, completion: (device: Device?, error: NSError?) -> Void) {
        do {
            let request = try self.appleDeviceEndpoint.postRequest(APNSToken, name: name, deviceID: deviceID, serverID: nil)
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
        } catch let err as NSError {
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(device: nil, error: err)
            })
        }
        
    }
    /**
     Update an existing device. Only updates fields that are present.
     
     - Parameters:
        - serverID: The id from the server to identify the device
        - APNSToken: The new or existing APNS token is required
        - name: Optional new name for the device
        - deviceID: Optional other id to call the device
        - completion: Called once the update is complete or there is an error
    */
    public func updateDevice(serverID: String, APNSToken: String, name: String?, deviceID: String?, completion: (device: Device?, error: NSError?) -> Void) {
        
        do {
            let request = try self.appleDeviceEndpoint.putRequest(APNSToken, name: name, deviceID: deviceID, serverID: serverID)
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
        } catch let err as NSError {
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(device: nil, error: err)
            })
        }
        
    }

// MARK: Token
    
    /**
    Creates a new 'whitelist' token to give to others you want to allow to send push notifications to this account
    
    - Parameters: 
        - id: The id of this APNS device
        - name: Optional name of the token for managing tokens later
        - completion: Called once there is a valid token or there is an error
    */
    public func createToken(id:String ,name:String?, completion: (token: Token?, error: NSError?) -> Void ) {
        do {
            let request = try self.tokenEndpoint.postRequest(id , name: name)
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
        } catch let err as NSError {
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(token: nil, error: err)
            })
        }
        
    }
    
    /** 
     Fetches token(s) from the server. If an id is passed then the resulting array will contain at most one token
     
     - Parameters:
        - id: Optional id. Pass if you want only a specific token. If none is passed it fetches all tokens
        - completion: The tokens from the server or an error
     */
    public func tokens(id:String?, completion:(tokens: [Token]?, error: NSError?) -> Void) {
        do {
            let request = try self.tokenEndpoint.getRequest(id)
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
        } catch let err as NSError {
            self.callbackQueue.addOperationWithBlock({ () -> Void in
                completion(tokens: nil, error: err)
            })
        }
        
    }

// MARK: Message
    /// The url for the message endpoint for this client
    public func messageEndpont() -> NSURL {
        return self.baseUrl.URLByAppendingPathComponent("\(Endpoint.Messages.rawValue)/")
    }
    /**
     Sends a message object to initiate a push. If the message does not have a url then it will be sent to this client's message endpoint otherwise that url is used.
     
     - Parameters:
        - message: The message object to be sent
        - completion: Called once the message object is returned from teh the server or an error
     */
    public func sendMessage(message:Message, completion: (message: Message?, error: NSError?) -> Void ) {
        do {
            let request = try self.messageEndpoint.postRequest(message)
            
            self.startDataTask(request,authenticate: false, completionHandler: { (responseData, response, responseError) -> Void in
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
    func startDataTask(request: NSMutableURLRequest, authenticate:Bool = false, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void))
    {
        request.setValue("gzip;q=1.0,compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("application/json", forHTTPHeaderField:"Accept")
        if let token = self.account?.token where authenticate {
            request.setValue("Token "+token, forHTTPHeaderField:"Authorization")
        }
        
        let dataTask = self.urlSession.dataTaskWithRequest(request, completionHandler: completionHandler)
        dataTask.resume()
    }
}