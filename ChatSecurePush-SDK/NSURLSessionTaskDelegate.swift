//
//  NSURLSessionTaskDelegate.swift
//  Pods
//
//  Created by David Chiles on 3/11/16.
//
//

import Foundation

public class URLSessionDelegate:NSObject, NSURLSessionDataDelegate {
    
    /// Handle redirects
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        guard let req = task.originalRequest?.mutableCopy() as? NSMutableURLRequest else {
            completionHandler(request)
            return
        }
        
        req.URL = request.URL
        completionHandler(req)
    }
}