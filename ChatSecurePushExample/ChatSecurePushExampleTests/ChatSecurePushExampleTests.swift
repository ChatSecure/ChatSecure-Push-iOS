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
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.protocolClasses = [UMKMockURLProtocol.self]
        
        var account :Account? = nil
        if (authToken != nil) {
            account = Account(username:username)
            account?.token = authToken
        }
        
        var client = Client(baseUrl: baseURl, urlSessionConfiguration: configuration,account: account)
        return client
    }
    
    func testCreatingClient() {
        var client = self.defaultClient(nil)
        var hasLength = count(client.baseUrl.absoluteString!) > 0
        XCTAssertTrue(hasLength, "No base url")
    }
    
    func testCreatingAccount() {
        var client = self.defaultClient(nil)
        var expectation = self.expectationWithDescription("Creating Account")
        
        client.registerNewUser(username, password: password, email: email) { (account, error) -> Void in
            
            
            var correctUsername = account?.username == username
            var correctEmail = account?.email == email
            var correctToken = account?.token == authToken
            
            XCTAssertNil(error, "Error creating account \(error)")
            XCTAssertTrue(correctUsername, "Incorrect username \(account?.username)")
            XCTAssertTrue(correctEmail, "Incorrect email \(account?.email)")
            XCTAssertTrue(correctToken, "Incorrect token \(account?.token)")
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            if( error != nil) {
                println(error)
            }
        })
    }
    
    func testCreatingDevice() {
        var client = self.defaultClient(authToken)
        
        var expectation = self.expectationWithDescription("Creating Device")
        
        client.registerDevice(apnsToken, name: deviceName, deviceID: nil) { (device, error) -> Void in
            var correctDeviceName = device?.name == deviceName
            var correctAPNSToken = device?.registrationID == apnsToken
            
            XCTAssertNil(error, "Error creating device \(error)")
            XCTAssertTrue(correctDeviceName, "Incorrect device name \(device?.name)")
            XCTAssertTrue(correctAPNSToken, "Incorrect apns token \(device?.registrationID)")
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            if( error != nil) {
                println(error)
            }
        })
    }
    
    func testCreatingToken() {
        var client = self.defaultClient(authToken)
        
        var expectation = self.expectationWithDescription("Creating Token")
        
        client.createToken(apnsToken, name: tokenName) { (token, error) -> Void in
            var correctDeviceName = token?.name == tokenName
            var correctApnsToken = token?.registrationID == apnsToken
            var correctToken = token?.tokenString == whitelistToken
            
            XCTAssertNil(error, "Erro creating token: \(error)")
            XCTAssertTrue(correctDeviceName, "Incorrect device name \(token?.name)")
            XCTAssertTrue(correctApnsToken, "Incorrect APNS token \(token?.registrationID)")
            XCTAssertTrue(correctToken, "Incorrect token \(token?.tokenString)")
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            if( error != nil) {
                println(error)
            }
        })
    }
    
    func testSendingMessage() {
        var client = self.defaultClient(authToken)
        
        var expectation = self.expectationWithDescription("Sending Message")
        let dict = [
            "key":["key":"value"],
            "Help":"Me"
        ]
        
        var originalMessage = Message(token:"23", data:dict as? [String : AnyObject])
        
        client.sendMessage(originalMessage) { (newMessage, error) -> Void in
            
            var equalToken = originalMessage.token == newMessage?.token
            
            XCTAssertNil(error, "Error sending message \(error)")
            XCTAssertTrue(equalToken, "Token not equal")
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(30, handler: { (error) -> Void in
            if error != nil {
                println("Error: \(error)")
            }
        })
    }
    
    func testAPNSResponse() {
        var dict : [String: AnyObject] = ["aps" : ["content-available" : 1],"message": ["token": "d1a2b6113bc9b8dd40982881fd2734daf407ea85"]]
        
        var message = Deserializer.messageFromDictionary(dict)
        if let messageDict = (dict["message"] as? [String: AnyObject]) {
            if let token = messageDict["token"] as? String {
                var equalToken = message?.token == token
                XCTAssertTrue(equalToken, "Not equal token")
            } else {
                XCTAssertTrue(false, "")
            }
        } else {
            XCTAssertTrue(false, "")
        }
        
    }
}
