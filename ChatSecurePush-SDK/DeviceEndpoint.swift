//
//  DeviceClient.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation

class APNSDeviceEndpoint: APIEndpoint {
    
    func postRequest(_ APNSToken: String, name: String?, deviceID: String?, serverID: String?) throws -> URLRequest {
        var parameters = [
            jsonKeys.registrationID.rawValue: APNSToken,
        ]
        
        parameters[jsonKeys.name.rawValue] = name
        parameters[jsonKeys.deviceID.rawValue] = deviceID
        
        var endpoint = Endpoint.apns.rawValue
        if let id = serverID {
            endpoint = "\(endpoint)/\(id)"
        }
        
        return try self.request(Method.post, endpoint: endpoint, jsonDictionary: parameters)
    }
    
    func putRequest(_ APNSToken: String, name: String?, deviceID: String?, serverID: String?) throws -> URLRequest {
        var request = try self.postRequest(APNSToken, name: name, deviceID: deviceID, serverID: serverID)
        request.httpMethod = Method.put.rawValue
        return request
    }
    
    func deviceFromResponse(_ responseData: Data?, response: URLResponse?, error: Error?) throws -> Device {
        try self.handleError(responseData, response: response, error: error)
        
        guard let data = responseData else {
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: ErrorStatusCode.noData.rawValue, userInfo: nil)
        }
        
        return try Deserializer.device(data, kind: .iOS)
    }
}
