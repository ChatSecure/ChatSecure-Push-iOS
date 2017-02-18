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

let baseURl = URL(string: "http://push.chatsecure/api/1/")!
let otherMessageURL = URL(string: "http://example.com/api/1/messages/")!
let username = "test"
let password = "password"
let email = "email@email.com"
let authToken = "f96197bfcf724523cb95626786d8c3baf8d16ada"
let apnsToken = "c8631d1938f161cae7539b9692fd85ddd4fda5398c0ef5dc5e208b86612c322a"
let dateCreatedSring = "2015-07-07T22:59:33.909289Z"
let dateExpires = "2016-07-11T20:01:14.126Z"
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
    
    let accountURL = baseURl.appendingPathComponent("accounts/")
    
    
    ///Create Account Request
    let createAccountRequest = UMKMockURLProtocol.expectMockHTTPPostRequest(with: accountURL, requestJSON: ["username":username,
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
    let deviceURL = baseURl.appendingPathComponent("device/apns/")
    let deviceRequest = UMKMockURLProtocol.expectMockHTTPPostRequest(with: deviceURL, requestJSON: ["name":deviceName,
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
    let tokenURL = baseURl.appendingPathComponent("tokens/")
    
    let tokenRequest = UMKMockURLProtocol.expectMockHTTPPostRequest(with: tokenURL, requestJSON: [
        "name":tokenName,
        "apns_device":apnsToken],
        responseStatusCode: 200,
        responseJSON: [
            "name": tokenName,
            "token": whitelistToken,
            "apns_device": apnsToken,
            "date_expires":dateExpires
        ])
    
    tokenRequest.headers = postHeader
    tokenRequest.headers.updateValue("110", forKey: "Content-Length")
    tokenRequest.checksHeadersWhenMatching = true
    
    let getSingleTokenRequest = UMKPatternMatchingMockRequest(urlPattern: tokenURL.absoluteString + ":id")
    
    getSingleTokenRequest.httpMethods = Set(["GET","DELETE"])
    getSingleTokenRequest.responderGenerationBlock = {request, parameters in
        
        if (request.httpMethod == "DELETE") {
            return UMKMockHTTPResponder(statusCode: 204, body: nil);
        }
        
        assert(request.value(forHTTPHeaderField: "Authorization") != nil)
        
        var data:Data?
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
            json = ["count": count as AnyObject, "results": results as AnyObject]
            
        }
        
        if let j = json {
            do {
               data = try JSONSerialization.data(withJSONObject: j, options: JSONSerialization.WritingOptions())
            } catch {
                print("JSON Error")
            }
            
        }
        
        return UMKMockHTTPResponder(statusCode: 200, body: data);
    }
    let allTokenRequest = UMKPatternMatchingMockRequest(urlPattern: tokenURL.absoluteString)
    allTokenRequest.httpMethods = getSingleTokenRequest.httpMethods
    allTokenRequest.responderGenerationBlock = getSingleTokenRequest.responderGenerationBlock

    
    UMKMockURLProtocol.expectMockRequest(allTokenRequest)
    UMKMockURLProtocol.expectMockRequest(getSingleTokenRequest)
    
    
    /// Message Request
    let messageURL = baseURl.appendingPathComponent("messages/")
    
    let request = UMKPatternMatchingMockRequest(urlPattern: messageURL.absoluteString)
    let block:UMKParameterizedResponderGenerationBlock = {request, parameters in
        
        assert(request.value(forHTTPHeaderField: "Authorization") == nil)
        
        let data = (request as NSURLRequest).umk_HTTPBodyData()!
        let jsonDict = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String : AnyObject]
        let message = try! Deserializer.messageFromServerDictionary(jsonDict, url: request.url!)
        
        if (message.token == errorToken) {
            return UMKMockHTTPResponder(statusCode: 404)
        } else {
            //Return post data back to client
            return UMKMockHTTPResponder(statusCode: 200, body: (request as NSURLRequest).umk_HTTPBodyData());
        }
        
        
    }
    request.responderGenerationBlock = block
    UMKMockURLProtocol.expectMockRequest(request)
    
    let otherServerRequest = UMKPatternMatchingMockRequest(urlPattern: otherMessageURL.absoluteString)
    otherServerRequest.responderGenerationBlock = block
    UMKMockURLProtocol.expectMockRequest(otherServerRequest)
}

