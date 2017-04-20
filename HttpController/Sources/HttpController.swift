//
//  HttpController.swift
//  HttpController
//
//  Created by tran.quoc.quan on 4/19/17.
//  Copyright © 2017 tran.quoc.quan. All rights reserved.
//

import UIKit




public protocol HttpControllerDelegate {
    func didDoPOSTRequestCompleted(response: String!, errorMsg:String!, identify: String)
    func didDoGETRequestCompleted(response: String!, errorMsg: String!, identify: String)
}

class MulticastDelegate<T> {
    private var delegates = [Weak]()
    
    func add(_ delegate: T) {
        if Mirror(reflecting: delegate).subjectType is AnyClass {
            delegates.append(Weak(value: delegate as AnyObject))
        } else {
            fatalError("MulticastDelegate does not support value types")
        }
    }
    
    func remove(_ delegate: T) {
        if type(of: delegate).self is AnyClass {
            delegates.remove(Weak(value: delegate as AnyObject))
        }
    }
    
    func invoke(_ invocation: (T) -> ()) {
        for (index, delegate) in delegates.enumerated() {
            if let delegate = delegate.value {
                invocation(delegate as! T)
            } else {
                delegates.remove(at: index)
            }
        }
    }
}

private class Weak: Equatable {
    weak var value: AnyObject?
    
    init(value: AnyObject) {
        self.value = value
    }
}

private func ==(lhs: Weak, rhs: Weak) -> Bool {
    return lhs.value === rhs.value
}

extension RangeReplaceableCollection where Iterator.Element : Equatable {
    @discardableResult
    mutating func remove(_ element : Iterator.Element) -> Iterator.Element? {
        if let index = self.index(of: element) {
            return self.remove(at: index)
        }
        return nil
    }
}

open class HttpController: NSObject {
    
    let multicastDelegate = MulticastDelegate<HttpControllerDelegate>()
    var baseURL: String = ""
    
    
    override public init() {
        super.init()
    }
    
    open func setBaseURL(url : String) {
        baseURL = url
    }
    
    
    open func setDelegate(delegate: HttpControllerDelegate) {
        multicastDelegate.add(delegate)
    }
    
    open func removeDelegate(delegate: HttpControllerDelegate) {
        multicastDelegate.remove(delegate)
    }
    
    public func doRequestPOSTWithHttp (parameter: NSDictionary, domain: String, identify: String) {
//        var request = URLRequest(url: URL(string: "http://139.59.109.83:9001/api/validateAccount?email=quantq777@gmail.com")!)
//        request.httpMethod = "POST"
//        request.addValue("\(getDeviceId())", forHTTPHeaderField: "device-id")
//        request.addValue("vn.giaohanggiare.customer", forHTTPHeaderField: "package-name")
//        request.addValue("user", forHTTPHeaderField: "app-type")
//        
//        let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E188a Safari/601.1"
//        
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
//        
//        let postString = ""
//        request.httpBody = postString.data(using: .utf8)
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {                                                 // check for fundamental networking error
//                print("error=\(String(describing: error))")
//                return
//            }
//            
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(String(describing: response))")
//            }
//            
//            let responseString = String(data: data, encoding: .utf8)
//            print("responseString = \(String(describing: responseString))")
//        }
//        task.resume()
        
        let urlString: String = baseURL.appending(domain)
        let bodyString = parameter.dictionaryToString()
        let request = RequestCustom(urlString: urlString, deviceId: getDeviceId(), method: .POST, body: bodyString) { (response) in
            if let response = response {
                self.multicastDelegate.invoke({$0.didDoGETRequestCompleted(response: response, errorMsg: nil, identify: identify)})
            }
        }
        request.makeCompleteRequest()
    }
    
    public func doRequestGETWithHttp (parameter: NSDictionary, domain: String, identify: String) {
//        var request = URLRequest(url: URL(string: "http://139.59.109.83:9001/api/validateAccount?email=quantq777@gmail.com")!)
//        request.httpMethod = "GET"//"POST"
//        request.addValue("\(getDeviceId())", forHTTPHeaderField: "device-id")
//        request.addValue("vn.giaohanggiare.customer", forHTTPHeaderField: "package-name")
//        request.addValue("user", forHTTPHeaderField: "app-type")
//        
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        
//        let postString = ""
//        request.httpBody = postString.data(using: .utf8)
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {                                                 // check for fundamental networking error
//                print("error=\(String(describing: error))")
//                return
//            }
//            
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(String(describing: response))")
//            }
//            
//            let responseString = String(data: data, encoding: .utf8)
//            print("responseString = \(String(describing: responseString))")
//            self.multicastDelegate.invoke({$0.didDoGETRequestCompleted(response: responseString, errorMsg: nil)})
//        }
//        task.resume()
        
        
        let urlString: String = baseURL.appending(domain)
        let request = RequestCustom(urlString: urlString, deviceId: getDeviceId(), method: .GET, body: "") { (response) in
            if let response = response {
                self.multicastDelegate.invoke({$0.didDoGETRequestCompleted(response: response, errorMsg: nil, identify: identify)})
            }
        }
        request.makeCompleteRequest()
        
    }
    
    
    private func getDeviceId () -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}

extension NSDictionary {
    func dictionaryToString () -> String {
//        let data = NSJSONSerialization.dataWithJSONObject(self, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
        let data = JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions)
        if let data = data {
            let json = NSString(data: data, encoding: NSUTF8StringEncoding)
            if let json = json {
                print(json)
            }
        }
    }
}

enum HttpMethod:String {
    case POST
    case GET
}

class RequestCustom: NSObject {
    let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E188a Safari/601.1"
    var currentTask: URLSessionDataTask!
    
    override init() {
        super.init()
    }
    
    init(urlString: String, deviceId: String, method: HttpMethod, body:String, completion:@escaping ((_ response: String?) -> Void)) {
        super.init()
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method.rawValue//"POST"
        request.addValue("\(deviceId)", forHTTPHeaderField: "device-id")
        request.addValue("vn.giaohanggiare.customer", forHTTPHeaderField: "package-name")
        request.addValue("user", forHTTPHeaderField: "app-type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = body.data(using: .utf8)
        currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                completion(nil)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            completion(responseString)
        }
    }
    
    func makeCompleteRequest() {
        if let task = currentTask {
            task.resume()
        }
    }
    
}
