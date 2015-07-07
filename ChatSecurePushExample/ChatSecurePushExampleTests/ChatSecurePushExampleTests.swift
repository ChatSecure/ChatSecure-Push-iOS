//
//  ChatSecurePushExampleTests.swift
//  ChatSecurePushExampleTests
//
//  Created by David Chiles on 7/7/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

import UIKit
import XCTest
import URLMock
import ChatSecure_Push_iOS

class ChatSecurePushExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UMKMockURLProtocol.enable()
        setupURLMock()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func defaultClient() -> Client {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.protocolClasses = [UMKMockURLProtocol.self]
        var client = Client(baseUrl: baseURl, urlSessionConfiguration: configuration)
        return client
    }
    
    func testCreatingClient() {
        var client = self.defaultClient()
        var hasLength = count(client.baseUrl.absoluteString!) > 0
        XCTAssertTrue(hasLength, "No base url")
    }
    
    func testCreatingAccount() {
        var client = self.defaultClient()
        
        client.registerNewUser(username, password: password, email: email) { (account, error) -> Void in
            var correctUsername = account?.username == username
            var correctEmail = account?.email == email
            var correctToken = account?.token == token
            
            XCTAssertNil(error, "Error creating account \(error)")
            XCTAssertTrue(correctUsername, "Incorrect username \(account?.username)")
            XCTAssertTrue(correctEmail, "Incorrect email \(account?.email)")
            XCTAssertTrue(correctToken, "Incorrect token \(account?.token)")
        }
    }
    
}
