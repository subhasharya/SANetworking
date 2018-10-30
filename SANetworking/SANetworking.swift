//
//  SANetworking.swift
//  SANetworking
//
//  Created by gauri on 10/29/18.
//  Copyright © 2018 gauri. All rights reserved.
//

import UIKit

public class SANetworking: NSObject {
    
   public func SANetworkingRequest(url: URL, param: AnyObject, requestType: RequestType, timeOut : TimeInterval, sa_networkingHandler: @escaping (_ isSuccess: Bool,_ response: Any) -> Void) {
        let session             = URLSession.shared
        let request             = NSMutableURLRequest(url:url)
        request.timeoutInterval = timeOut
        request.cachePolicy     = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        if requestType == .post {
            let theJSONData = try? JSONSerialization.data(
                withJSONObject: param ,
                options: JSONSerialization.WritingOptions(rawValue: 0))
            let jsonString = NSString(data: theJSONData!,
                                      encoding: String.Encoding.ascii.rawValue)
            let postLength = NSString(format:"%lu", jsonString!.length) as String
            request.setValue(postLength, forHTTPHeaderField:"Content-Length")
            request.httpBody = jsonString!.data(using: String.Encoding.utf8.rawValue, allowLossyConversion:true)
            request.httpMethod = "POST"
        }else {
            request.httpMethod = "GET"
        }
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if((error) != nil) {
                sa_networkingHandler(false,error!)
            }else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    sa_networkingHandler(true,json)
                } catch {
                    sa_networkingHandler(false,"Invalid JSON")
                }
            }
        }
        dataTask.resume()
    }
    
}


public enum RequestType {
    case get
    case post
}

