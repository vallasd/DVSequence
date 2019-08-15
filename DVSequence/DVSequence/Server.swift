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

import Foundation

let timeoutInterval: Double = 5.0
public typealias ServerDict = Dictionary<String, String>

/// object model used for SequenceData to make server requests
struct ServerData: PassedProtocol {
    let url: String // URL that the request is sent from
    let parameters: ServerDict // list of parameters
    var passed: JSON // dictionary used for passing information by ServerData during sequence
    
    init(url: String) {
        self.url = url
        self.parameters = [:]
        self.passed = [:]
    }
    
    /// Creates a URLRequest for the RequestData.  If a request can not be created, returns an Error.
    var urlRequest: Result<URLRequest, Error> {
        
        var urlString = url
        
        for key in parameters.keys {
            urlString = urlString.addParameterSeperator
            let value = parameters[key] ?? ""
            urlString = urlString + "\(key)=\(value)"
        }
        
        // return error if url can not be created
        guard let url = URL(string: urlString) else {
            return .failure(NSError.createURL(url: urlString))
        }
        
        // create urlreqeust
        let request = NSMutableURLRequest(url: url)
        
        // define httpMethod
        let result: Result<Method, Error> = checkPassed(object: self, parameter: "method", type: Method.self)
        switch result {
        case .success(let method): request.httpMethod = method.string
        case .failure(let error): return .failure(error)
        }
        
        // define timeout interval
        request.timeoutInterval = timeoutInterval
        
        // copy it to a URL Request
        let r = request.copy() as! URLRequest
        
        return .success(r)
    }
}

/// performs server request and returns PassedProtocol (with data) or Error
func processServer(serverData: ServerData) -> Result<PassedProtocol, Error> {
    return createURLRequest(serverData: serverData)
        >>> processURLRequest
        >>> checkError
        >>> checkURLResponse
}

/// attempts to create URLRequest and store in in passed dictionary, returns .failure(error) is URLRequest can not be made
fileprivate func createURLRequest(serverData: ServerData) -> Result<ServerData, Error> {
    let result = serverData.urlRequest
    switch result {
    case .success(let urlRequest):
        var sd = serverData
        sd.passed["urlRequest"] = urlRequest
        return .success(sd)
    case .failure(let error):
        return .failure(error)
    }
}

/// dispatches synchronous call to server and returns data, urlResponse, error in passed dictionary
fileprivate func processURLRequest(serverData: ServerData) -> Result<ServerData, Error> {
    var copy = serverData
    let urlRequest = serverData.passed["urlRequest"] as! URLRequest
    let semaphore = DispatchSemaphore(value: 0)
    URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
        copy.passed["data"] = data
        copy.passed["urlResponse"] = urlResponse
        copy.passed["error"] = error
        semaphore.signal()
        }.resume()
    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    return .success(copy)
}

/// checks if ServerData object contains passed parameter "error" of type Error, returns .failure(Error) if true
fileprivate func checkError(serverData: ServerData) -> Result<ServerData, Error> {
    let result: Result<Error, Error> = checkPassed(object: serverData, parameter: "error", type: Error.self)
    switch result {
    case .success(let error): return .failure(error)
    case .failure: return .success(serverData)
    }
}

/// checks if ServerData object contains urlResponse and that response is valid, returns .failure(Error) if false
fileprivate func checkURLResponse(serverData: ServerData) -> Result<PassedProtocol, Error> {
    if let httpResponse = serverData.passed["urlResponse"] as? HTTPURLResponse {
        let code = httpResponse.statusCode
        let successRange = 200..<300
        if !successRange.contains(code) {
            let message = HTTPURLResponse.localizedString(forStatusCode: code)
            let error = NSError.error(message: message, code: code)
            return .failure(error)
        }
    }
    return .success(serverData)
}
