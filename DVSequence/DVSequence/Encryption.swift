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
import SwiftyRSA

fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()

// Encryption Struct, Defines the method and verification variable for Encryption
public struct Encryption {
    let method: EncodingMethod
    var verification: EncryptionVerification?
}

// Encoding Method, used to encode object
public enum EncodingMethod {
    case base64
}

// Keys used to verify that Encrypted signature is valid
public struct EncryptionVerification {
    let publicKey: String
    let signatureKey: String
    let payloadKey: String
}

/// Verifies data (using EncryptionVerification), decodes using EncodingMethod, and returns decoded Codable generic
func decrypt<T: Codable>(data: Data, object: PassedProtocol) -> Result<T, Error> {
    
    // verify signature if EncryptionVerification passed, decodes JSON (using EncodingMethod), and create generic
    if let encryption = object.passed["encryption"] as? Encryption {
        do {
            let json = try verify(verification: encryption.verification, data: data)
            let decodedData = try decode(method: encryption.method, json: json)
            let generic = try decoder.decode(T.self, from: decodedData)
            return .success(generic)
        } catch (let error) {
            return .failure(error)
        }
    }
    
    // decodes generic without decryption
    do {
        let generic = try decoder.decode(T.self, from: data)
        return .success(generic)
    } catch (let error) {
        return .failure(error)
    }
}

/// unpackages a data object as JSON
fileprivate func unpackageJSON(data: Data) throws -> JSON {
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        guard let json = jsonObject as? JSON else { throw NSError.json(jsonObject) }
        return json
    } catch (let error) {
        throw error
    }
}

/// verifies data if EncryptionVerification is passed, returns JSON (without signature key)
fileprivate func verify(verification: EncryptionVerification?, data: Data) throws ->  JSON {
    do {
        var json = try unpackageJSON(data: data)
        if let v = verification {
            let signature = try json.string(v.signatureKey)
            let payload = try json.string(v.payloadKey)
            let publicKey = try PublicKey(pemEncoded: verification!.publicKey)
            let clear = try ClearMessage(string: payload, using: .utf8)
            let sig = try Signature(base64Encoded: signature)
            let isSuccessful = try clear.verify(with: publicKey, signature: sig, digestType: .sha256)
            if !isSuccessful { throw NSError.signatureVerification }
            json.removeValue(forKey: v.signatureKey)
        }
        return json
    } catch (let error) {
        throw error
    }
}

/// decodes a JSON Object using an EncodingMethod and returns object as Data
fileprivate func decode(method: EncodingMethod, json: JSON) throws -> Data {
    let decoded: JSON!
    do {
        switch method {
        case .base64: decoded = Dictionary(uniqueKeysWithValues:
            json.map { key, value in (key, value.base64Decoded(key)) })
        }
        return try JSONSerialization.data(withJSONObject: decoded as Any, options: .sortedKeys)
    } catch (let error) {
        throw error
    }
}


extension String {
    
    func base64Encoded() throws -> Data {
        guard let encoded = self.data(using: .utf8)?.base64EncodedData() else {
            throw NSError.base64Encodable(string: self)
        }
        return encoded
    }
    
    func base64Encoded() throws -> String {
        guard let encoded = self.data(using: .utf8)?.base64EncodedString() else {
            throw NSError.base64Encodable(string: self)
        }
        return encoded
    }
    
    func base64Decoded() throws -> String {
        guard
            let data = Data(base64Encoded: self),
            let decoded = String(data: data, encoding: .utf8) else {
                throw NSError.base64Decodable(string: self)
        }
        return decoded
    }
}

extension Optional {
    
    func base64Encoded(_ key: String) -> Any? {
        do {
            if let s = self as? String { return try s.base64Decoded() }
            return self
        } catch {
            print("WARNING: |\(key)| is not base64 encodable, returning original value")
            return self
        }
    }
    
    func base64Decoded(_ key: String) -> Any? {
        do {
            if let s = self as? String { return try s.base64Decoded() }
            return self
        } catch {
            print("WARNING: |\(key)| is not base64 decodable, returning original value")
            return self
        }
    }
}


