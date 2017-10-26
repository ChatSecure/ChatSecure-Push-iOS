//
//  Endpoint.swift
//  Pods
//
//  Created by David Chiles on 8/31/15.
//
//

import Foundation


class APIEndpoint {
    
    var baseURL: URL
    var token: String?
    
    init (baseUrl: URL) {
        self.baseURL = baseUrl
    }
    
    func request(_ method: Method, endpoint: String, jsonDictionary:[String: Any]?) throws -> URLRequest {
        
        return try APIEndpoint.request(method.rawValue, URL: self.url(endpoint), jsonDictionary: jsonDictionary)
    }
    
    func url(_ endPoint: String) -> URL {
        return self.baseURL.appendingPathComponent(endPoint+"/")
    }
    
    func handleError(_ data: Data?, response: URLResponse?, error: Error?) throws {
        
        if let err = error {
            throw err
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            try self.validate(httpResponse, responseData:data)
        }
    }
    
    func validate(_ response: HTTPURLResponse, responseData:Data?) throws {
        var acceptable = false
        if response.statusCode > 199 && response.statusCode < 300 {
            acceptable = true
        }
        
        if(!acceptable) {
            var userInfo : [String: Any] = [:]
            if let data = responseData {
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    userInfo = [NSLocalizedDescriptionKey:string]
                }
            }
            
            throw NSError(domain: ErrorDomain.chatsecurePush.rawValue, code: response.statusCode, userInfo: userInfo)
        }
    }
    
    class func request(_ method: String, URL:Foundation.URL, jsonDictionary:[String:Any]?) throws -> URLRequest {
        var request = URLRequest(url: URL)
        request.httpMethod = method
        
        if let json = jsonDictionary {
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
            
            if let count = request.httpBody?.count, count > 0 {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        return request
    }
}
