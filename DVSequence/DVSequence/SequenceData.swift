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

public protocol PassedProtocol {
    var passed: JSON { get set }
}

public enum Method {
    case get
    case post
    case update
    case delete
    
    var string: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .update: return "PUT"
        case .delete: return "DELETE"
        }
    }
}

public enum DataType {
    case json
    case xml
}

public struct SequenceData {
    let firstSequence: SequenceType
    let secondSequence: SequenceType?
    let method: Method
    let dataType: DataType
    var encryption: Encryption?
    
    // creates a get request from server
    public init(url: String) {
        let serverData = ServerData(url: url)
        self.firstSequence = SequenceType.serverData(serverData)
        self.secondSequence = nil
        self.method = .get
        self.dataType = .json
    }
    
    // creates a get request from server and handles Encryption
    public init(url: String, encryption: Encryption) {
        let serverData = ServerData(url: url)
        self.firstSequence = SequenceType.serverData(serverData)
        self.secondSequence = nil
        self.method = .get
        self.dataType = .json
        self.encryption = encryption
    }
    
    init(firstSequence: SequenceType, secondSequence: SequenceType?, method: Method, dataType: DataType) {
        self.firstSequence = firstSequence
        self.secondSequence = secondSequence
        self.method = method
        self.dataType = dataType
    }
    
    var updatedSequences: SequenceData {
        let first: JSON = [
            "method": method,
            "dataType": dataType,
            "encryption": encryption
        ]
        let second: JSON = [
            "method": method == .get ? Method.update : method,
            "dataType": dataType,
            "encryption": encryption
        ]
        let fs = firstSequence.update(passed: first)
        let ss = secondSequence?.update(passed: second)
        return SequenceData(firstSequence: fs,
                            secondSequence: ss,
                            method: method,
                            dataType: dataType)
    }
}

enum SequenceType: PassedProtocol {
    case serverData(ServerData)
    case storeData(StoreData)
    
    var isServerData: Bool {
        switch self {
        case .serverData: return true
        default: return false
        }
    }
    
    var passed: JSON {
        get {
            switch self {
            case .serverData(let st): return st.passed
            case .storeData(let st): return st.passed
            }
        }
        set {
            assert(true, "use update(passed: ParametersDict)")
        }
    }
    
    func update(passed: JSON) -> SequenceType {
        switch self {
        case .serverData(var st):
            st.passed = passed
            return .serverData(st)
        case .storeData(var st):
            st.passed = passed
            return .storeData(st)
        }
    }
    
    func update(parameter: String, value: Any?) -> SequenceType {
        switch self {
        case .serverData(var st):
            st.passed[parameter] = value
            return .serverData(st)
        case .storeData(var st):
            st.passed[parameter] = value
            return .storeData(st)
        }
    }
}

