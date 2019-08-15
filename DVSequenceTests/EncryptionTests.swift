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

import XCTest
@testable import DVSequence

class EncryptionTests: XCTestCase {
    
    // MARK: Variables Used For Testing
    
    let url = "https://webclients.jumboprivacy.com/interview_challenge/challenge.json"
    let publicKey = """
                    -----BEGIN PUBLIC KEY-----
                    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAufKvMjy2EMPsHXlP/Y81
                    BHrOEZm84B84C+/GwDqIzoEH4XHn5Vj3N3+QNG/WT9TZv+tufm6i9jNQUosKztXy
                    yZSGYhtypLVb2oni4oDn3a/UXOnJjSk9nNohcYghQRZ++1nRs+MUYBQKAHZDxle6
                    MytDYdBxV3gyfDhnjilqLe/91KbDaB7EjL3ffxfop+QFZGExqcfWxq4gL92mlzNr
                    Si/N0lRv5nAsicAyNSBAU4RJYW/ECPPvgeV9KXYrcCodx+Ed+ap3FJaUeZF0KJiv
                    BaKOlBpWGGqevdOCykb4ub4ePnQB/6s81MxVHfAoUBKGBsYfy1wuwkWFDH0c9SOm
                    cQIDAQAB
                    -----END PUBLIC KEY-----
                    """
    let badPublicKey = """
                    -----BEGIN PUBLIC KEY-----
                    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAufKvMjy2EMPsHXlP/Y81
                    BHrOEZm84B84C+/GwDqIzoEH4XHn5Vj3N3+QNG/WT9TZv+tufm6i9jNQUosKztXy
                    yZSGYhtypLVb2oni4oDn3a/UXOnJjCk9nNohcYghQRZ++1nRs+MUYBQKAHZDxle6
                    MytDYdBxV3gyfDhnjilqLe/91KbDaB7EjL3ffxfop+QFZGExqcfWxq4gL92mlzNr
                    Si/N0lRv5nAsicAyNSBAU4RJYW/ECPPvgeV9KXYrcCodx+Ed+ap3FJaUeZF0KJiv
                    BaKOlBpWGGqevdOCykh4ub4ePnQB/6s81MxVHfAoUBKGBsYfy1wuwkWFDH0c9SOm
                    cQIDAQAB
                    -----END PUBLIC KEY-----
                    """
    let encodedPayload = "dmFyIEp1bWJvID0ge21lc3NhZ2U6IGZ1bmN0aW9uKCkge3JldHVybiAiSSdtIEp1bWJvLCB0aGUgZWxlcGhhbnQhIn19"
    let badEncodedPayload = "dmFyIEp1bWJvID0ge61lc3NhZ2U6IGZ1bmN0bW9uKCkge3JldHVybiAiSSdtIEp1bSJvLCB0aGUgZWxlcGhhbnQhIn19"
    let encodedSignature = "LpvogjO5evRy41WDkPATXFSpNM31NIvx1JgaNQCfhKH8Uv0UQDlF8/SAHXuk10Y0fp6D1fDHv4PTt1HmV+bwtv1bDdSiqT2gsu+bjPB8Pg92j9mKygxORmSzR1QthKzqRAMR3HOK04O1XkXHbmyJSPLXfepbT/AQBHh5uWHhb/Ils727+T1+Ntt+7SqQZ2gnfhbZDNFFHCXhpXVU66KE619cJxImaS1XAEQZ95nXHAEofmf/uiGBOzKCXt1m+LfHtjOA7CzwN1TeSZbj/Z7jSsz+GbtSpXoYGOffDNxHRS5SBvgVi/uU8zgnyEhXh1fKAHf3o4Uw20Mf3kVog3q4yg=="
    let badEncodedSignature = "ApvogjO5evRy41WDkPATXFSpNM31NIvx1JgaNQCfhKH8Uv0UQDlF8/SAHXuk10Y0fp6D1fDHv4PTt1HmV+bwtv1bDdSiqT2gsu+bjPB8Pg92j9mKygxORmSzR1QthKzqRAMR3HOK04O1XkXHbmyKSPLXfepbT/AQBHh5uWHhb/Ils727+T1+Ntt+7SqQZ2gnfhbZDNFFHCXhpXVU66KE619cJxImaS1XAEQZ95nXHAEofmf/uiGBOzKCXt1m+LfHtjOA7CzwN1TeSZbj/Z7jSsz+GbtSpXoYGOffDNxHRS5SBvgVi/uU8zgnyEhXh1fKAHf5o4Uw20Mf3kVog3q4yg=="
    let payload = "var Jumbo = {message: function() {return \"I'm Jumbo, the elephant!\"}}"
    
    // MARK: Codable Response
    
    struct Response : Codable {
        let payload: String
    }
    
    // MARK: Encryption Struct Variations
    
    var decryptionWithoutVerfication: Encryption {
        return Encryption(method: .base64, verification: nil)
    }
    
    var decryptionWithVerfication: Encryption {
        let verification = EncryptionVerification (publicKey: publicKey,
                                                   signatureKey: "signature",
                                                   payloadKey: "payload")
        return Encryption(method: .base64, verification: verification)
    }
    
    var decryptionWithVerficationBadPublicKey: Encryption {
        let verification = EncryptionVerification (publicKey: badPublicKey,
                                                   signatureKey: "signature",
                                                   payloadKey: "payload")
        return Encryption(method: .base64, verification: verification)
    }
    
    var decryptionWithVerficationBadSignatureKey: Encryption {
        let verification = EncryptionVerification (publicKey: publicKey,
                                                   signatureKey: "badSignature",
                                                   payloadKey: "payload")
        return Encryption(method: .base64, verification: verification)
    }
    
    var decryptionWithVerficationBadPayloadKey: Encryption {
        let verification = EncryptionVerification (publicKey: publicKey,
                                                   signatureKey: "signature",
                                                   payloadKey: "badPayload")
        return Encryption(method: .base64, verification: verification)
    }
    
    func executeResponse(expectation: XCTestExpectation,
                         sequenceData: SequenceData,
                         successCheck: ((Response) -> Void)?,
                         errorCheck: String?) {
        DVSequence.shared.execute(sequenceData: sequenceData, completion: { (result: Result<Response, Error>) in
            switch result {
            case let .success(response):
                if errorCheck != nil { XCTAssertNil("supposed to receive error") }
                else { if let s = successCheck { s(response) } }
            case let .failure(error):
                if errorCheck != nil { XCTAssertEqual(error.string, errorCheck!) }
                else { XCTAssertNil(error.string) }
            }
            expectation.fulfill()
        })
    }
    
    func undecryptedResponse(_ expectation: XCTestExpectation) {
        let sequenceData = SequenceData(url: url)
        func check(response: Response) {
            XCTAssertEqual(response.payload, encodedPayload)
        }
        executeResponse(expectation: expectation,
                        sequenceData: sequenceData,
                        successCheck: check,
                        errorCheck: nil)
    }
    
    func decryptedResponse(_ expectation: XCTestExpectation) {
        let sequenceData = SequenceData(url: url, encryption: decryptionWithoutVerfication)
        func check(response: Response) {
            XCTAssertEqual(response.payload, payload)
        }
        executeResponse(expectation: expectation,
                        sequenceData: sequenceData,
                        successCheck: check,
                        errorCheck: nil)
    }
    
    func decryptedResponseWithVerification(_ expectation: XCTestExpectation) {
        let sequenceData = SequenceData(url: url, encryption: decryptionWithVerfication)
        func check(response: Response) {
            XCTAssertEqual(response.payload, payload)
        }
        executeResponse(expectation: expectation,
                        sequenceData: sequenceData,
                        successCheck: check,
                        errorCheck: nil)
    }
    
    func decryptedResponseWithVerificationBadPublicKey(_ expectation: XCTestExpectation) {
        let sequenceData = SequenceData(url: url, encryption: decryptionWithVerficationBadPublicKey)
        executeResponse(expectation: expectation,
                        sequenceData: sequenceData,
                        successCheck: nil,
                        errorCheck: "code: 400 info: failed to verify signature")
    }
    
    func decryptedResponseWithVerificationBadPayloadKey(_ expectation: XCTestExpectation) {
        let sequenceData = SequenceData(url: url, encryption: decryptionWithVerficationBadPayloadKey)
        executeResponse(expectation: expectation,
                        sequenceData: sequenceData,
                        successCheck: nil,
                        errorCheck: "code: 500 info: failed to unwrap JSON key: |badPayload| type: |String|")
    }
    
    func decryptedResponseWithVerificationBadSignatureKey(_ expectation: XCTestExpectation) {
        let sequenceData = SequenceData(url: url, encryption: decryptionWithVerficationBadSignatureKey)
        executeResponse(expectation: expectation,
                        sequenceData: sequenceData,
                        successCheck: nil,
                        errorCheck: "code: 500 info: failed to unwrap JSON key: |badSignature| type: |String|")
    }
    
    func base64EncryptDecrypt() {
        do {
            let decoded = try encodedPayload.base64Decoded()
            XCTAssertEqual(decoded, payload)
            let encoded: String = try decoded.base64Encoded()
            XCTAssertEqual(encoded, encodedPayload)
        } catch (let error) {
            XCTAssertNil(error.string)
        }
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUndecryptedResponse() {
        let expectation = XCTestExpectation(description: "downloading encrypted request")
        undecryptedResponse(expectation)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDecryptedResponse() {
        let expectation = XCTestExpectation(description: "downloading encrypted request")
        decryptedResponse(expectation)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDecryptedResponseWithVerification() {
        let expectation = XCTestExpectation(description: "downloading encrypted request")
        decryptedResponseWithVerification(expectation)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDecryptedResponseWithVerificationBadPublicKey() {
        let expectation = XCTestExpectation(description: "downloading encrypted request")
        decryptedResponseWithVerificationBadPublicKey(expectation)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDecryptedResponseWithVerificationBadPayloadKey() {
        let expectation = XCTestExpectation(description: "downloading encrypted request")
        decryptedResponseWithVerificationBadPayloadKey(expectation)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDecryptedResponseWithVerificationBadSignatureKey() {
        let expectation = XCTestExpectation(description: "downloading encrypted request")
        decryptedResponseWithVerificationBadSignatureKey(expectation)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testBase64EncryptDecrypt() {
        base64EncryptDecrypt()
    }
    
}

