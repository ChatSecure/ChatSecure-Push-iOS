//
//  Device.swift
//  Pods
//
//  Created by David Chiles on 7/7/15.
//
//

import Foundation

public enum DeviceKind:Int {
    case unkown  = 0
    case iOS     = 1
    case Android = 2
}

public extension NSData {
    
    //http://stackoverflow.com/questions/7520615/how-to-convert-an-nsdata-into-an-nsstring-hex-string/7520655#7520655
    var hexString : String {
        let buf = UnsafePointer<UInt8>(bytes)
        let charA = UInt8(UnicodeScalar("a").value)
        let char0 = UInt8(UnicodeScalar("0").value)
        
        func itoh(i: UInt8) -> UInt8 {
            return (i > 9) ? (charA + i - 10) : (char0 + i)
        }
        
        var p = UnsafeMutablePointer<UInt8>.alloc(length * 2)
        
        for i in 0..<length {
            p[i*2] = itoh((buf[i] >> 4) & 0xF)
            p[i*2+1] = itoh(buf[i] & 0xF)
        }
        
        return NSString(bytesNoCopy: p, length: length*2, encoding: NSUTF8StringEncoding, freeWhenDone: true)! as String
    }
}

public class Device: NSObject, NSCoding, NSCopying {
    public var name: String?
    public var id: String?
    public var deviceID: String?
    public var registrationID: String
    public var active = true
    public var deviceKind = DeviceKind.unkown
    public let dateCreated: NSDate
    
    
    
    public init (registrationID: String,dateCreated: NSDate, name: String?, deviceID: String?, id: String?) {
        self.name = name
        self.dateCreated = dateCreated
        self.registrationID = registrationID
        self.deviceID = deviceID
        self.id = id
    }
    
    public required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as? String
        self.id = aDecoder.decodeObjectForKey("id") as? String
        self.deviceID = aDecoder.decodeObjectForKey("deviceID") as? String
        if let registrationID = aDecoder.decodeObjectForKey("registrationID") as? String {
            self.registrationID = registrationID
        } else {
            self.registrationID = ""
        }
        self.active = aDecoder.decodeBoolForKey("active")
        if let date = aDecoder.decodeObjectForKey("dateCreated") as? NSDate {
            self.dateCreated = date
        } else {
            self.dateCreated = NSDate()
        }
        if let deviceKindRawValue = aDecoder.decodeObjectForKey("deviceKind") as? Int {
            if let deviceKind = DeviceKind(rawValue: deviceKindRawValue) {
                self.deviceKind = deviceKind
            } else {
                self.deviceKind = .unkown
            }
        } else {
            self.deviceKind = .unkown
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeObject(self.deviceID, forKey: "deviceID")
        aCoder.encodeObject(self.registrationID, forKey: "registrationID")
        aCoder.encodeBool(self.active, forKey: "active")
        aCoder.encodeObject(self.dateCreated, forKey: "dateCreated")
        aCoder.encodeObject(self.deviceKind.rawValue, forKey: "deviceKind")
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        var newDevice = Device(registrationID: self.registrationID, dateCreated: self.dateCreated, name: self.name, deviceID: self.deviceID, id: self.deviceID)
        newDevice.active = self.active
        newDevice.deviceKind = self.deviceKind
        return newDevice
    }
}