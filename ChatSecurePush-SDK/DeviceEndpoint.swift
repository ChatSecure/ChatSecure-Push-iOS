//
//  DeviceClient.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation

class APNSDeviceEndpoint: APIEndpoint {
    
    func postRequest(APNSToken: String, name: String?, deviceID: String?) -> NSMutableURLRequest {
        var parameters = [
            jsonKeys.registrationID.rawValue: APNSToken,
        ]
        
        parameters[jsonKeys.name.rawValue] = name
        parameters[jsonKeys.deviceID.rawValue] = deviceID
        
        var request = self.request(Method.POST, endpoint: Endpoint.APNS, jsonDictionary: parameters).0
        return request
    }
    
    func get() {
        
    }
    
    func deviceFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) -> (Device?, NSError?) {
        var device: Device?
        var err = self.handleError(responseData, response: response, error: error)
        if err != nil {
            return (nil, err)
        } else if let data = responseData {
            var serialized = Deserializer.device(data, kind: .iOS)
            device =  serialized.0
            err = serialized.1
        } else {
            err = NSError(domain: errorDomain.chatsecurePush.rawValue, code: errorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return (device,err)
    }
    
}
