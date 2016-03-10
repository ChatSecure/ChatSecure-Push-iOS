//
//  DeviceClient.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation

class APNSDeviceEndpoint: APIEndpoint {
    
    func postRequest(APNSToken: String, name: String?, deviceID: String?, serverID: String?) throws -> NSMutableURLRequest {
        var parameters = [
            jsonKeys.registrationID.rawValue: APNSToken,
        ]
        
        parameters[jsonKeys.name.rawValue] = name
        parameters[jsonKeys.deviceID.rawValue] = deviceID
        
        var endpoint = Endpoint.APNS.rawValue
        if let id = serverID {
            endpoint = "\(endpoint)/\(id)"
        }
        
        return try self.request(Method.POST, endpoint: endpoint, jsonDictionary: parameters)
    }
    
    func putRequest(APNSToken: String, name: String?, deviceID: String?, serverID: String?) throws -> NSMutableURLRequest {
        let request = try self.postRequest(APNSToken, name: name, deviceID: deviceID, serverID: serverID)
        request.HTTPMethod = Method.PUT.rawValue
        return request
    }
    
    func deviceFromResponse(responseData: NSData?, response: NSURLResponse?, error: NSError?) throws -> Device {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.ChatsecurePush.rawValue, code: ErrorStatusCode.NoData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.device(data, kind: .iOS)
    }
}
