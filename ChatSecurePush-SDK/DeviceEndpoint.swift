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
        
        let request = self.request(Method.POST, endpoint: Endpoint.APNS, jsonDictionary: parameters).0
        return request
    }
    
    func get() {
        
    }
    
    func deviceFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> Device {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: errorDomain.chatsecurePush.rawValue, code: errorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.device(data, kind: .iOS)
    }
    
}
