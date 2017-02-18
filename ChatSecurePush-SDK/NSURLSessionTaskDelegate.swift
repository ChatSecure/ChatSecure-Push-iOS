//
//  NSURLSessionTaskDelegate.swift
//  Pods
//
//  Created by David Chiles on 3/11/16.
//
//

import Foundation

open class URLSessionDelegate:NSObject, URLSessionDataDelegate {
    
    /// Handle redirects
    open func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        guard let req = (task.originalRequest as NSURLRequest?)?.mutableCopy() as? NSMutableURLRequest else {
            completionHandler(request)
            return
        }
        
        req.url = request.url
        completionHandler(req as URLRequest)
    }
}
