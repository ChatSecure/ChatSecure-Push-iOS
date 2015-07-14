//
//  Device.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

public enum DeviceKind {
    case unkown
    case iOS
    case Android
}

public class Device: NSObject {
    public var name: String?
    public var registrationID: String
    public var active = true
    public let dateCreated: NSDate
    public let deviceKind = DeviceKind.unkown
    
    
    public init (registrationID: String,dateCreated: NSDate, name: String?, deviceID: String?) {
        self.name = name
        self.dateCreated = dateCreated
        self.registrationID = registrationID
    }
}