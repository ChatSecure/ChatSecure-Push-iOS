//
//  Device.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

public enum DeviceType {
    case unkown
    case iOS
    case Android
}

public class Device: NSObject {
    public var name: String
    public var registrationID: String
    public let deviceType = DeviceType.unkown
    
    init (name: String, registrationID: String, deviceID: String) {
        self.name = name
        self.registrationID = registrationID
    }
}