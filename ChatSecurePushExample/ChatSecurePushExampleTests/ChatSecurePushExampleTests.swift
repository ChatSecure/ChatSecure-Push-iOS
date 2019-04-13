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
    
    func defaultClient(_ authToken:String?) -> Client {
        let configuration = URLSessionConfiguration.default
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
        let hasLength = (client.baseUrl.absoluteString).count > 0
        XCTAssertTrue(hasLength, "No base url")
    }
    
    func testCreatingAccount() {
        let client = self.defaultClient(nil)
        let expectation = self.expectation(description: "Creating Account")
        
        client.registerNewUser(username, password: password, email: email) { (account, error) -> Void in
            
            
            let correctUsername = account?.username == username
            let correctEmail = account?.email == email
            let correctToken = account?.token == authToken
            
            XCTAssertNil(error, "Error creating account \(String(describing: error))")
            XCTAssertTrue(correctUsername, "Incorrect username \(String(describing: account?.username))")
            XCTAssertTrue(correctEmail, "Incorrect email \(String(describing: account?.email))")
            XCTAssertTrue(correctToken, "Incorrect token \(String(describing: account?.token))")
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10, handler: { (error) -> Void in
            if( error != nil) {
                print("\(String(describing: error))")
            }
        })
    }
    
    func testCreatingDevice() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectation(description: "Creating Device")
        
        client.registerDevice(apnsToken, name: deviceName, deviceID: nil) { (device, error) -> Void in
            let correctDeviceName = device?.name == deviceName
            let correctAPNSToken = device?.registrationID == apnsToken
            
            XCTAssertNil(error, "Error creating device \(String(describing: error))")
            XCTAssertTrue(correctDeviceName, "Incorrect device name \(String(describing: device?.name))")
            XCTAssertTrue(correctAPNSToken, "Incorrect apns token \(String(describing: device?.registrationID))")
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10, handler: { (error) -> Void in
            if( error != nil) {
                print("\(String(describing: error))")
            }
        })
    }
    
    func testCreatingToken() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectation(description: "Creating Token")
        
        client.createToken(apnsToken, name: tokenName) { (token, error) -> Void in
            let correctDeviceName = token?.name == tokenName
            let correctApnsToken = token?.registrationID == apnsToken
            let correctToken = token?.tokenString == whitelistToken
            let correctTokenExpiresDate = token?.expires == Deserializer.dateFormatter().date(from: dateExpires)
            
            XCTAssertNil(error, "Erro creating token: \(String(describing: error))")
            XCTAssertTrue(correctDeviceName, "Incorrect device name \(String(describing: token?.name))")
            XCTAssertTrue(correctApnsToken, "Incorrect APNS token \(String(describing: token?.registrationID))")
            XCTAssertTrue(correctToken, "Incorrect token \(String(describing: token?.tokenString))")
            XCTAssertTrue(correctTokenExpiresDate, "Incorect expiration date \(String(describing: token?.expires))")
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10, handler: { (error) -> Void in
            if( error != nil) {
                print("\(String(describing: error))")
            }
        })
    }
    
    func testGettingTokens() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectation(description: "Getting multiple tokens")
        client.tokens(nil, completion: { (tokens, error) -> Void in
            XCTAssertGreaterThan(tokens!.count, 0, "No tokens found")
            XCTAssertNil(error, "Error \(String(describing: error))")
            expectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 20, handler: { (error) -> Void in
            if error != nil {
                print("\(String(describing: error))")
            }
        })
    }
    
    /// Test deleting tokens
    func testDeletingToken() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectation(description: "Deleting token")
        client.revokeToken("tokenID") { (error) -> Void in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 30) { (err) -> Void in
            
        }
    }
    
    func testSendingMessage() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectation(description: "Sending Message")
        let dict = [
            "key":["key":"value"],
            "Help":"Me"
        ] as [String : Any]
        
        let originalMessage = Message(token:"23", url:nil, data:dict)
        
        client.sendMessage(originalMessage) { (newMessage, error) -> Void in
            
            let equalToken = originalMessage.token == newMessage?.token
            
            XCTAssertNil(error, "Error sending message \(String(describing: error))")
            XCTAssertTrue(equalToken, "Token not equal")
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 30, handler: { (error) -> Void in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
        })
    }
    
    /// Teset 404 message response. Token was revoked case
    func testErrorSendingMessage() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectation(description: "Error Sending Message")
        
        let message = Message(token: errorToken, url: nil, data: nil)
        
        client.sendMessage(message) { (message, error) -> Void in
            XCTAssertNil(message)
            guard let err = error as NSError? else {
                XCTFail()
                expectation.fulfill()
                return
            }
            XCTAssertEqual(err.code, 404)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 30) { (err) -> Void in
            if (err != nil) {
                print("\(String(describing: err))")
            }
        }
    }
    
    /// Test sending messages that have a url
    func testSendingMessageOtherServer() {
        let client = self.defaultClient(authToken)
        
        let expectation = self.expectation(description: "Sending Message to other server")
        let dict = [
            "key":["key":"value"],
            "Help":"Me"
        ] as [String : Any]
        
        let origMessage = Message(token: "111", url: otherMessageURL, data: dict)
        client.sendMessage(origMessage) { (message, error) -> Void in
         
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 30) { (error) -> Void in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
        }
    }
    
    func testAPNSResponse() {
        let token = "09bd6d3cb017959eeec6cf031dbf7ad60f0a3bcd"
        let dict : [String: Any] = ["aps": [
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
