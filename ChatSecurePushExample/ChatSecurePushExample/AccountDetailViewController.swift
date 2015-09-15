//
//  AccountDetailViewController.swift
//  ChatSecurePushExample
//
//  Created by David Chiles on 7/21/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

import Foundation
import UIKit
import ChatSecure_Push_iOS

let urlString = "http://10.11.41.112:8000/api/v1/"

class AccountDetailViewController: UIViewController {
    
    var account: Account?
    var device: Device?
    var password: String?
    
    @IBOutlet var accountStatusLabel: UILabel?
    @IBOutlet var messageTokenTextField: UITextField?
    
    
    let client = Client(baseUrl: NSURL(string: urlString)!, urlSessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration(), account: nil)
    
    override func viewDidLoad() {
        
        if let password = self.password {
            if let username = self.account?.username {
                self.accountStatusLabel?.text = "Creating Account..."
                self.client.registerNewUser(username, password: password, email: nil, completion: { (account, error) -> Void in
                    
                    
                    if let newAccount = account {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.accountStatusLabel?.text = "Created Account: \(newAccount.username)"
                        })
                        
                        self.account = newAccount
                        self.client.account = newAccount
                        if let apnsToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.apnsToken {
                            self.client.registerDevice(apnsToken, name: "I'm just a test device", deviceID: nil, completion: { (device, error) -> Void in
                                self.device = device
                            })
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func sendMessageButtonPressed(sender: AnyObject?) {
        if let token = self.messageTokenTextField?.text {
            let message = Message(token: token, data: nil)
            self.client.sendMessage(message, completion: { (msg, error) -> Void in
                print("Message: \(msg)")
            })
        }
        
    }
    
    @IBAction func whitelistTokenButtonPressed(sender: AnyObject?) {
        if let _ = (UIApplication.sharedApplication().delegate as? AppDelegate)?.apnsToken {
            if let id = self.device?.id {
                self.client.createToken(id, name: "I'm just a test token", completion: { (token, error) -> Void in
                    if let tempToken = token {
                        print("Token: \(token)")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let activityVewController = UIActivityViewController(activityItems: [tempToken.tokenString], applicationActivities: nil)
                            self.presentViewController(activityVewController, animated: true, completion: nil)
                        })
                    }
                    
                    
                });
            }
            
        }
    }
}
