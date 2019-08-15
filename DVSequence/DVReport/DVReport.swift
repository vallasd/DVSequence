//    The MIT License (MIT)
//
//    Copyright (c) 2018 David C. Vallas (david_vallas@yahoo.com) (dcvallas@twitter)
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

/// DVReport is used to create generic error messaging throughout the app.  User may turn on or off specific message types.  Used to create uniformity in message reporting.
public struct DVReport {
    
    public static var shared = DVReport()
    
    var on = true // turns all reporting on/off
    var reportInfo = true // turns info error reporting on/off
    var reportWarn = true // turns warning error reporting on/off
    var reportError = true // turns error error reporting on/off
    var reportAlert = true // turns alert error reporting on/off
    var reportAssert = true // turns assertion error reporting on/off
    
    func report(_ msg: String, type: DVErrorType) {
        if !on { return }
        let report = "[\(type.string)] " + msg
        switch (type) {
        case .info:    if reportInfo { print(report) }
        case .warn:    if reportWarn { print(report) }
        case .error:   if reportError { print(report) }
        case .alert:   if reportAlert { print(report) }
        case .assert:  if reportAssert { assert(true, report) }
        }
        
    }
    
    /// creates a generic message for an optional that failed to unwrap
    public func optionalFailed<T>(_ decoder: T, object: Any?, returning: Any?) {
        DVReport.shared.report("|\(decoder)| |OPTIONAL UNWRAP FAILED| object: |\(String(describing: object))|, returning: |\(String(describing: returning))|", type: .error)
    }
    
    /// creates a generic message for a default that failed to retrieve
    public func defaultsFailed<T>(_ decoder: T, key: String) {
        DVReport.shared.report("|\(decoder)| |DEFAULTS RETRIEVAL FAILED| invalid key: |\(key)|", type: .error)
    }
    
    /// creates a generic message for a decode that failed to map the object
    public func decodeFailed<T>(_ decoder: T, object: Any) {
        DVReport.shared.report("|\(decoder)| |DECODING FAILED| not mapable object: |\(object)|", type: .error)
    }
    
    /// creates a generic message for a decode that failed to be inserted
    public func setDecodeFailed<T>(_ decoder: T, object: Any) {
        DVReport.shared.report("|\(decoder)| |DECODING FAILED| not inserted object: |\(object)|", type: .error)
    }
    
    /// creates a generic message for two objects not matching
    public func notMatching(_ object: Any, object2: Any) {
        DVReport.shared.report("|\(object)| is does not match |\(object2)|", type: .error)
    }
    
    /// creates a generic message for insertion failure
    public func insertFailed<T>(set: T, object: Any) {
        DVReport.shared.report("|\(set)| |INSERT FAILED| object: \(object)", type: .error)
    }
    
    /// creates a generic message for deletion failure
    public func deleteFailed<T>(set: T, object: Any) {
        DVReport.shared.report("|\(set)| |DELETE FAILED| object: \(object)", type: .error)
    }
    
    /// creates a generic message for get failure
    public func getFailed<T>(set: T, keys: [Any], values: [Any]) {
        DVReport.shared.report("|\(set)| |GET FAILED| for keys: |\(keys)| values: |\(values)|", type: .error)
    }
    
    /// creates a generic message for update failure of specific key
    public func updateFailed<T>(set: T, key: Any, value: Any) {
        DVReport.shared.report("|\(set)| |UPDATE FAILED| for key: |\(key)| not valid value: |\(value)|", type: .error)
    }
    
    /// creates a generic message for update failure
    public func updateFailedGeneric<T>(set: T) {
        DVReport.shared.report("|\(set)| |UPDATE FAILED| nil object returned, possible stale objects", type: .error)
    }
    
    /// creates a generic message for vaildation error
    public func validateFailed<T,U>(decoder: T, value: Any, key: Any, expectedType: U) {
        DVReport.shared.report("|\(decoder)| |VALIDATION FAILED| for key: |\(key)| value: |\(value)| expected type: |\(expectedType)|", type: .error)
    }
}


