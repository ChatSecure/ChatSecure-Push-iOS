//
//  Device.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

@objc public enum DeviceKind:Int {
    case unknown  = 0
    case iOS     = 1
    case android = 2
}

public extension Data {
    
    //https://stackoverflow.com/questions/39075043/how-to-convert-data-to-hex-string-in-swift/40089462#40089462
    func hexString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

@objc open class Device: NSObject, NSCoding, NSCopying {
    @objc open var name: String?
    @objc open var id: String?
    @objc open var deviceID: String?
    @objc open var registrationID: String
    @objc open var active = true
    @objc open var deviceKind = DeviceKind.unknown
    @objc public let dateCreated: Date
    
    
    
    @objc public init (registrationID: String,dateCreated: Date, name: String?, deviceID: String?, id: String?) {
        self.name = name
        self.dateCreated = dateCreated
        self.registrationID = registrationID
        self.deviceID = deviceID
        self.id = id
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.id = aDecoder.decodeObject(forKey: "id") as? String
        self.deviceID = aDecoder.decodeObject(forKey: "deviceID") as? String
        if let registrationID = aDecoder.decodeObject(forKey: "registrationID") as? String {
            self.registrationID = registrationID
        } else {
            self.registrationID = ""
        }
        self.active = aDecoder.decodeBool(forKey: "active")
        if let date = aDecoder.decodeObject(forKey: "dateCreated") as? Date {
            self.dateCreated = date
        } else {
            self.dateCreated = Date()
        }
        if let deviceKindRawValue = aDecoder.decodeObject(forKey: "deviceKind") as? Int {
            if let deviceKind = DeviceKind(rawValue: deviceKindRawValue) {
                self.deviceKind = deviceKind
            } else {
                self.deviceKind = .unknown
            }
        } else {
            self.deviceKind = .unknown
        }
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.deviceID, forKey: "deviceID")
        aCoder.encode(self.registrationID, forKey: "registrationID")
        aCoder.encode(self.active, forKey: "active")
        aCoder.encode(self.dateCreated, forKey: "dateCreated")
        aCoder.encode(self.deviceKind.rawValue, forKey: "deviceKind")
    }
    
    open func copy(with zone: NSZone?) -> Any {
        let newDevice = Device(registrationID: self.registrationID, dateCreated: self.dateCreated, name: self.name, deviceID: self.deviceID, id: self.deviceID)
        newDevice.active = self.active
        newDevice.deviceKind = self.deviceKind
        return newDevice
    }
}
