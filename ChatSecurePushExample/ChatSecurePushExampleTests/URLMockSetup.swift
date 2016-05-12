//
//  URLMockSetup.swift
//  ChatSecurePushExample
//
//  Created by David Chiles on 7/7/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

import Foundation
import URLMock
import ChatSecure_Push_iOS

let baseURl = NSURL(string: "http://push.chatsecure/api/1/")!
let otherMessageURL = NSURL(string: "http://example.com/api/1/messages/")!
let username = "test"
let password = "password"
let email = "email@email.com"
let authToken = "f96197bfcf724523cb95626786d8c3baf8d16ada"
let apnsToken = "c8631d1938f161cae7539b9692fd85ddd4fda5398c0ef5dc5e208b86612c322a"
let dateCreatedSring = "2015-07-07T22:59:33.909289Z"
let deviceName = "Great big iPad"
let tokenName = "This awesome token"
let whitelistToken = "e6a73da924cfcf41d4a422e115e65d6f3e64fe3d"
let errorToken = "errorToken"

func setupURLMock() {
    
    
    
    var baseHeader = [
        "Accept-Encoding":"gzip;q=1.0,compress;q=0.5",
        "Accept":"application/json",
    ]
    
    var createAccountHeader = baseHeader
    createAccountHeader["Content-Type"] = "application/json"
    
    var postHeader = createAccountHeader
    postHeader["Authorization"] = "Token "+authToken
    baseHeader["Authorization"] = postHeader["Authorization"]
    
    let accountURL = baseURl.URLByAppendingPathComponent("accounts/")
    
    
    ///Create Account Request
    let createAccountRequest = UMKMockURLProtocol.expectMockHTTPPostRequestWithURL(accountURL, requestJSON: ["username":username,
        "password":password,
        "email":email],
        responseStatusCode: 200,
        responseJSON: [
        "username": username,
        "email": email,
        "token": authToken
    ])
    createAccountRequest.headers = createAccountHeader
    createAccountRequest.headers.updateValue("67", forKey: "Content-Length")
    //Need to figure out way to include "Content-Length" which is added by Apple
    createAccountRequest.checksHeadersWhenMatching = true
    
    
    
    
    ///Create Device Request
    let deviceURL = baseURl.URLByAppendingPathComponent("device/apns/")
    let deviceRequest = UMKMockURLProtocol.expectMockHTTPPostRequestWithURL(deviceURL, requestJSON: ["name":deviceName,
        "registration_id":apnsToken],
        responseStatusCode: 200,
        responseJSON: [
                "name": deviceName,
                "registration_id": apnsToken,
                "active": true,
                "date_created": dateCreatedSring
        ])
    deviceRequest.headers = postHeader
    deviceRequest.headers.updateValue("110", forKey: "Content-Length")
    deviceRequest.checksHeadersWhenMatching = true
    
    
    ///Create Token Request
    let tokenURL = baseURl.URLByAppendingPathComponent("tokens/")
    
    let tokenRequest = UMKMockURLProtocol.expectMockHTTPPostRequestWithURL(tokenURL, requestJSON: [
        "name":tokenName,
        "apns_device":apnsToken],
        responseStatusCode: 200,
        responseJSON: [
            "name": tokenName,
            "token": whitelistToken,
            "apns_device": apnsToken
        ])
    
    tokenRequest.headers = postHeader
    tokenRequest.headers.updateValue("110", forKey: "Content-Length")
    tokenRequest.checksHeadersWhenMatching = true
    
    let getSingleTokenRequest = UMKPatternMatchingMockRequest(URLPattern: tokenURL.absoluteString.stringByAppendingString(":id"))
    
    getSingleTokenRequest.HTTPMethods = Set(["GET","DELETE"])
    getSingleTokenRequest.responderGenerationBlock = {request, parameters in
        
        if (request.HTTPMethod == "DELETE") {
            return UMKMockHTTPResponder(statusCode: 204, body: nil);
        }
        
        assert(request.valueForHTTPHeaderField("Authorization") != nil)
        
        var data:NSData?
        var json:[String:AnyObject]?
        if let id = parameters["id"] {
            var t = Token.randomToken()
            t = Token(tokenString: id, type:t.type, deviceID: t.registrationID)
            json = try! Serializer.jsonValue(t)
        } else {
            var results: [[String:AnyObject]] = []
            let count = 3
            for _ in 1...count {
                let t = Token.randomToken()
                if let json = try! Serializer.jsonValue(t) {
                    results.append(json)
                }
            }
            json = ["count": count, "results": results]
            
        }
        
        if let j = json {
            do {
               data = try NSJSONSerialization.dataWithJSONObject(j, options: NSJSONWritingOptions())
            } catch {
                print("JSON Error")
            }
            
        }
        
        return UMKMockHTTPResponder(statusCode: 200, body: data);
    }
    let allTokenRequest = UMKPatternMatchingMockRequest(URLPattern: tokenURL.absoluteString)
    allTokenRequest.HTTPMethods = getSingleTokenRequest.HTTPMethods
    allTokenRequest.responderGenerationBlock = getSingleTokenRequest.responderGenerationBlock

    
    UMKMockURLProtocol.expectMockRequest(allTokenRequest)
    UMKMockURLProtocol.expectMockRequest(getSingleTokenRequest)
    
    
    /// Message Request
    let messageURL = baseURl.URLByAppendingPathComponent("messages/")
    
    let request = UMKPatternMatchingMockRequest(URLPattern: messageURL.absoluteString)
    let block:UMKParameterizedResponderGenerationBlock = {request, parameters in
        
        assert(request.valueForHTTPHeaderField("Authorization") == nil)
        
        let data = request.umk_HTTPBodyData()!
        let jsonDict = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! [String : AnyObject]
        let message = try! Deserializer.messageFromServerDictionary(jsonDict, url: request.URL!)
        
        if (message.token == errorToken) {
            return UMKMockHTTPResponder(statusCode: 404)
        } else {
            //Return post data back to client
            return UMKMockHTTPResponder(statusCode: 200, body: request.umk_HTTPBodyData());
        }
        
        
    }
    request.responderGenerationBlock = block
    UMKMockURLProtocol.expectMockRequest(request)
    
    let otherServerRequest = UMKPatternMatchingMockRequest(URLPattern: otherMessageURL.absoluteString)
    otherServerRequest.responderGenerationBlock = block
    UMKMockURLProtocol.expectMockRequest(otherServerRequest)
}

