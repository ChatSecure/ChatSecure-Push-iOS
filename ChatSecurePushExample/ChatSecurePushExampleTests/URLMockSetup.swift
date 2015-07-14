//
//  URLMockSetup.swift
//  ChatSecurePushExample
//
//  Created by David Chiles on 7/7/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

import Foundation
import URLMock

let baseURl = NSURL(string: "http://push.chatsecure/api/1/")!
let username = "test"
let password = "password"
let email = "email@email.com"
let authToken = "f96197bfcf724523cb95626786d8c3baf8d16ada"
let apnsToken = "c8631d1938f161cae7539b9692fd85ddd4fda5398c0ef5dc5e208b86612c322a"
let dateCreatedSring = "2015-07-07T22:59:33.909289Z"
let deviceName = "Great big iPad"
let tokenName = "This awesome token"
let whitelistToken = "e6a73da924cfcf41d4a422e115e65d6f3e64fe3d"

func setupURLMock() {
    
    
    
    var getHeader = [
        "Accept-Encoding":"gzip;q=1.0,compress;q=0.5",
        "Accept":"application/json",
    ]
    
    var createAccountHeader = getHeader
    createAccountHeader["Content-Type"] = "application/json"
    
    var postHeader = createAccountHeader
    postHeader["Authorizatoin"] = "Token "+authToken
    getHeader["Authorizatoin"] = postHeader["Authorizatoin"]
    
    var accountURL = baseURl.URLByAppendingPathComponent("accounts/")
    
    var createAccountRequest = UMKMockURLProtocol.expectMockHTTPPostRequestWithURL(accountURL, requestJSON: ["username":username,
        "password":password,
        "email":email],
        responseStatusCode: 200,
        responseJSON: [
        "username": username,
        "email": email,
        "token": authToken
    ])
    createAccountRequest.headers = createAccountHeader
    //Need to figure out way to include "Content-Length" which is added by Apple
    //createAccountRequest.checksHeadersWhenMatching = true
    
    var deviceURL = baseURl.URLByAppendingPathComponent("device/apns/")
    
    var deviceRequest = UMKMockURLProtocol.expectMockHTTPPostRequestWithURL(deviceURL, requestJSON: ["name":deviceName,
        "registration_id":apnsToken],
        responseStatusCode: 200,
        responseJSON: [
                "name": deviceName,
                "registration_id": apnsToken,
                "active": true,
                "date_created": dateCreatedSring
        ])
    deviceRequest.headers = postHeader
    //deviceRequest.checksHeadersWhenMatching = true
    
    var tokenURL = baseURl.URLByAppendingPathComponent("tokens/")
    
    var tokenRequest = UMKMockURLProtocol.expectMockHTTPPostRequestWithURL(tokenURL, requestJSON: [
        "name":tokenName,
        "apns_device":apnsToken],
        responseStatusCode: 200,
        responseJSON: [
            "name": tokenName,
            "token": whitelistToken,
            "apns_device": apnsToken,
            "gcm_device": NSNull()
        ])
    
    tokenRequest.headers = postHeader
    //tokenRequest.checksHeadersWhenMatching = true
    
    
    var messageURL = baseURl.URLByAppendingPathComponent("messages/")
    
    var sendMessageRequest = UMKMockURLProtocol.expectMockHTTPPostRequestWithURL(tokenURL, requestJSON: [
        "token":whitelistToken,
        "data":apnsToken],
        responseStatusCode: 200,
        responseJSON: [
            //TODO waiting on server changes
        ])
    sendMessageRequest.headers = postHeader
    //sendMessageRequest.checksHeadersWhenMatching = true
}

