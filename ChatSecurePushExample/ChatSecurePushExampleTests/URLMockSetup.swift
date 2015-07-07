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
let token = "f96197bfcf724523cb95626786d8c3baf8d16ada"

func setupURLMock() {
    
    var accountURL = baseURl.URLByAppendingPathComponent("accounts")
    
    var request = UMKMockURLProtocol.expectMockHTTPPostRequestWithURL(accountURL, requestJSON: ["username":username,
        "password":password,
        "email":email],
        responseStatusCode: 200, responseJSON: [
        "username": username,
        "email": email,
        "token": token
    ])
}

