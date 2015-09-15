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
        UMKMockURLProtocol.reset()
        UMKMockURLProtocol.enable()
        setupURLMock()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        UMKMockURLProtocol.disable()
    }
    
    func defaultClient(authToken:String?) -> Client {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.protocolClasses = [UMKMockURLProtocol.self]
        
        var account :Account? = nil
        if (authToken != nil) {
            account = Account(username:username)
            account?.token = authToken
        }
        
        let client = Client(baseUrl: baseURl, urlSessionConfiguration: configuration,account: account)
        return client
    }
    
    func testCreatingClient() {
        let client = self.defaultClient(nil)
        let hasLength = (client.baseUrl.absoluteString).characters.count > 0
        XCTAssertTrue(hasLength, "No base url")
    }
    
    func testCreatingAccount() {
        let client = self.defaultClient(nil)
        let expectation = self.expectationWithDescription("Creating Account")
        
        client.registerNewUser(username, password: password, email: email) { (account, error) -> Void in
            
            
            let correctUsername = account?.username == username
            let correctEmail = account?.email == email
            let correctToken = account?.token == authToken
            
            XCTAssertNil(error, "Error creating account \(error)")
            XCTAssertTrue(correctUsername, "Incorrect username \(account?.username)")
            XCTAssertTrue(correctEmail, "Incorrect email \(account?.email)")
            XCTAssertTrue(correctToken, "Incorrect token \(account?.token)")
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            if( error != nil) {
                print(error)
            }
        })
    }
    
    func testCreatingDevice() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectationWithDescription("Creating Device")
        
        client.registerDevice(apnsToken, name: deviceName, deviceID: nil) { (device, error) -> Void in
            let correctDeviceName = device?.name == deviceName
            let correctAPNSToken = device?.registrationID == apnsToken
            
            XCTAssertNil(error, "Error creating device \(error)")
            XCTAssertTrue(correctDeviceName, "Incorrect device name \(device?.name)")
            XCTAssertTrue(correctAPNSToken, "Incorrect apns token \(device?.registrationID)")
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            if( error != nil) {
                print(error)
            }
        })
    }
    
    func testCreatingToken() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectationWithDescription("Creating Token")
        
        client.createToken(apnsToken, name: tokenName) { (token, error) -> Void in
            let correctDeviceName = token?.name == tokenName
            let correctApnsToken = token?.registrationID == apnsToken
            let correctToken = token?.tokenString == whitelistToken
            
            XCTAssertNil(error, "Erro creating token: \(error)")
            XCTAssertTrue(correctDeviceName, "Incorrect device name \(token?.name)")
            XCTAssertTrue(correctApnsToken, "Incorrect APNS token \(token?.registrationID)")
            XCTAssertTrue(correctToken, "Incorrect token \(token?.tokenString)")
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            if( error != nil) {
                print(error)
            }
        })
    }
    
    func testGettingTokens() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectationWithDescription("Getting multiple tokens")
        client.tokens(nil, completion: { (tokens, error) -> Void in
            XCTAssertGreaterThan(tokens!.count, 0, "No tokens found")
            XCTAssertNil(error, "Error \(error)")
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(20, handler: { (error) -> Void in
            if error != nil {
                print(error)
            }
        })
    }
    
    func testSendingMessage() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectationWithDescription("Sending Message")
        let dict = [
            "key":["key":"value"],
            "Help":"Me"
        ]
        
        let originalMessage = Message(token:"23", data:dict)
        
        client.sendMessage(originalMessage) { (newMessage, error) -> Void in
            
            let equalToken = originalMessage.token == newMessage?.token
            
            XCTAssertNil(error, "Error sending message \(error)")
            XCTAssertTrue(equalToken, "Token not equal")
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(30, handler: { (error) -> Void in
            if error != nil {
                print("Error: \(error)")
            }
        })
    }
    
    func testAPNSResponse() {
        let token = "09bd6d3cb017959eeec6cf031dbf7ad60f0a3bcd"
        let dict : [String: AnyObject] = ["aps": [
            "alert": [
                "message": [
                    "token": token
                ]
            ],
            "content-available": 1
        ]]
        do {
           let message = try Deserializer.messageFromPushDictionary(dict)
            let equalToken = message.token == token
            XCTAssertTrue(equalToken, "Not equal token")
        } catch let error {
            XCTAssertNil(error)
        }
    }
}
