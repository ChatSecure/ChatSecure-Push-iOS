//
//  DeviceClient.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation

class APNSDeviceEndpoint: APIEndpoint {
    
    func postRequest(APNSToken: String, name: String?, deviceID: String?, serverID: String?) -> NSMutableURLRequest {
        var parameters = [
            jsonKeys.registrationID.rawValue: APNSToken,
        ]
        
        parameters[jsonKeys.name.rawValue] = name
        parameters[jsonKeys.deviceID.rawValue] = deviceID
        
        var endpoint = Endpoint.APNS.rawValue
        if let id = serverID {
            endpoint = "\(endpoint)/\(id)"
        }
        
        let request = self.request(Method.POST, endpoint: endpoint, jsonDictionary: parameters).0
        return request
    }
    
    func deviceFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> Device {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: errorDomain.chatsecurePush.rawValue, code: errorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.device(data, kind: .iOS)
    }
}
