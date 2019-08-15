//    The MIT License (MIT)
//
//    Copyright (c) 2019 David C. Vallas (david_vallas@yahoo.com) (dcvallas@twitter)
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE

import UIKit

public extension Error {
    
    /// creates a UIAlertController for Error
    var alert: UIAlertController {
        let alert = UIAlertController(title: "\((self as NSError).code)", message: self.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
    
    /// returns a string format of the Error
    var string: String {
        return "code: \((self as NSError).code) info: \(self.localizedDescription)"
    }
    
    /// prints the Error to log in string format
    func print() {
        Swift.print(self.string)
    }
    
    /// Defined Error Messages
    
    static func createURL(url: String) -> Error {
        return NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "unable to create url: |\(url)|"])
    }
    
    static func passed<T>(parameter: String, type: T) -> Error {
        return NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "passed parameter: [\(parameter) : \(type)] not found"])
    }
    
    static func implemenation<Q, T>(_ object: Q, type: T) -> Error {
        return NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "|\(object)| type: |\(type)| not implemented"])
    }
    
    static func implementation<T>(type: T) -> Error {
        return NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "|\(type)| not implemented"])
    }
    
    static func jsonUnwrap<T>(key: String, type: T) -> Error {
        return NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "failed to unwrap JSON key: |\(key)| type: |\(type)|"])
    }
    
    static func error(message msg: String, code: Int) -> Error {
        return NSError(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    static func base64Encodable(string: String) -> Error {
        return NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "|\(string)| is not Base64 Encodable"])
    }
    
    static func json(_ object: Any) -> Error {
        return NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "|\(object)| is not JSON"])
    }
    
    static func base64Decodable(string: String) -> Error {
        return NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "|\(string)| is not Base64 Decodable"])
    }
    
    static var signatureVerification: Error {
        return NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "failed to verify signature"])
    }
}
