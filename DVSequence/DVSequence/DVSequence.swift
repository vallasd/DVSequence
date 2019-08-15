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

public typealias SequenceDict = Dictionary<String, String>

/// This class performs a Sequence of Storage and Retrieval from different sources.  For example, can retrieve encrypted data from a server and store the data in coredata.  Depends on Codable objects for storage and retrieval.
public class DVSequence {
    
    // MARK: - Public Variables
    public static let shared = DVSequence()
    
    // MARK: - Private Variables
    lazy private var bundleQueue = DispatchQueue(label: "com.dvsequence.bundleQueue", attributes: .concurrent)
    lazy private var fileQueue = DispatchQueue(label: "com.dvsequence.fileQueue", attributes: .concurrent)
    lazy private var defaultsQueue = DispatchQueue(label: "com.dvsequence.defaultsQueue", attributes: .concurrent)
    lazy private var coredataQueue = DispatchQueue(label: "com.dvsequence.coredataQueue", attributes: .concurrent)
    lazy private var keychainQueue = DispatchQueue(label: "com.dvsequence.keychainQueue", attributes: .concurrent)
    lazy private var serverQueue = DispatchQueue(label: "com.dvsequence.serverQueue", attributes: .concurrent)
    
    // MARK: - Public Functions
    
    /// executes the sequenceData.  Processes first and second SequenceTypes on appropriate queue and returns Result<Codable, Error> to the main queue
    public func execute<T: Codable>(sequenceData: SequenceData, completion: @escaping (Result<T, Error>) -> ()) {
        let sd = sequenceData.updatedSequences
        let firstQueue = queue(sequenceType: sd.firstSequence)
        let secondQueue = queue(sequenceType: sd.secondSequence)
        firstQueue!.async() {
            let result: Result<T, Error> = processSequence(sequenceType: sd.firstSequence)
            if (secondQueue == nil) { DispatchQueue.main.async { completion(result) } }
            secondQueue?.async {
                let secondResult: Result<T, Error> = processSequence(result: result, sequenceType: sd.secondSequence!)
                DispatchQueue.main.async { completion(secondResult) }
            }
        }
    }
    
    // MARK: - Private Functions
    
    fileprivate func queue(sequenceType: SequenceType?) -> DispatchQueue? {
        if sequenceType == nil { return nil }
        switch sequenceType! {
        case .serverData:
            return serverQueue
        case .storeData(let storeData):
            switch storeData.type {
            case .bundle:   return bundleQueue
            case .coredata: return coredataQueue
            case .defaults: return defaultsQueue
            case .file:     return fileQueue
            case .keychain: return keychainQueue
            }
        }
    }
}

// MARK: - Public Functions

public var currentQueue: String? {
    let name = __dispatch_queue_get_label(nil)
    return String(cString: name, encoding: .utf8)
}

/// checks if PassedProtocol object contains passed parameter of type T, returns .success(T) if true
func checkPassed<T>(object: PassedProtocol, parameter: String, type: T.Type) -> Result<T, Error> {
    if let passed = object.passed[parameter] as? T { return .success(passed) }
    return .failure(NSError.passed(parameter: parameter, type: type))
}

/// checks if PassedProtocol object contains passed parameter of type T, returns .success(PassedProtocol) if true
func checkPassed<T>(object: PassedProtocol, parameter: String, type: T.Type) -> Result<PassedProtocol, Error> {
    if object.passed[parameter] is T { return .success(object) }
    return .failure(NSError.passed(parameter: parameter, type: type))
}

// MARK: - Fileprivate Functions

/// processes the sequenceType (but first adds the generic to the sequenceTypes passed data, returns the Codable Object or Error in a Result
fileprivate func processSequence<T: Codable>(result: Result<T, Error>, sequenceType: SequenceType) -> Result<T, Error> {
    switch result {
    case .success(let generic):
        var st =  sequenceType
        st.passed["generic"] = generic
        return processSequence(sequenceType: st)
    case .failure(let error):
        return .failure(error)
    }
}

/// processes the sequenceType, returns the Codable Object or Error in a Result
fileprivate func processSequence<T: Codable>(sequenceType: SequenceType) -> Result<T, Error> {
    var passed: Result<PassedProtocol, Error>!
    switch sequenceType {
    case .serverData (let serverData): passed = processServer(serverData: serverData)
    case .storeData (let storeData):
        switch storeData.type {
        case .bundle: return .failure(NSError.implemenation(StoreType.self, type: storeData.type))
        case .coredata: return .failure(NSError.implemenation(StoreType.self, type: storeData.type))
        case .defaults: return .failure(NSError.implemenation(StoreType.self, type: storeData.type))
        case .file: return .failure(NSError.implemenation(StoreType.self, type: storeData.type))
        case .keychain: return .failure(NSError.implemenation(StoreType.self, type: storeData.type))
        }
    }
    return passed
        >>> checkData
        >>> decode
}

/// checks if passed Protocol contains a data object, if false, returns Error
fileprivate func checkData(object: PassedProtocol) -> Result<PassedProtocol, Error> {
    return checkPassed(object: object, parameter: "data", type: Data.self)
}

/// checks if PassedProtocol contains passed parameter "generic" of type T, returns .success(T) if true.  If false, checks if PassedProtocol contains passed parameter "data" of type Data, if true, decodes the data and returns T, else returns error
fileprivate func decode<T: Codable>(object: PassedProtocol) -> Result<T, Error> {
    let result: Result<T, Error> = checkPassed(object: object, parameter: "generic", type: T.self)
    switch result {
    case .success(let generic):
        return .success(generic)
    case .failure:
        return object
        >>> decodeData
    }
}

/// checks dataType and creates a JSON data object for that type, then attempts to decrypt and return Codable generic
fileprivate func decodeData<T: Codable>(object: PassedProtocol) -> Result<T, Error> {
    let dataType = object.passed["dataType"] as! DataType
    let data = object.passed["data"] as! Data
    let jsonData: Data! // data that is JSON decodable
    switch dataType {
    case .json: jsonData = data
    case .xml: return .failure(NSError.implemenation(DataType.self, type: dataType))
    }
    return decrypt(data: jsonData, object: object)
}
