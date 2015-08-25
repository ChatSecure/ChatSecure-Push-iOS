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

public class Device: NSObject {
    public var name: String?
    public var id: String?
    public var deviceID: String?
    public var registrationID: String
    public var active = true
    public let dateCreated: NSDate
    public let deviceKind = DeviceKind.unkown
    
    
    public init (registrationID: String,dateCreated: NSDate, name: String?, deviceID: String?, id: String?) {
        self.name = name
        self.dateCreated = dateCreated
        self.registrationID = registrationID
        self.deviceID = deviceID
        self.id = id
    }
}