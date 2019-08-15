//
//  DVSequenceTests.swift
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

class NetworkTests: XCTestCase {
    var count = 0
    let todoApi = "https://jsonplaceholder.typicode.com/todos/1"
    let todosApi = "https://jsonplaceholder.typicode.com/todos"
    let userApi = "https://jsonplaceholder.typicode.com/users/1"
    let usersApi = "https://jsonplaceholder.typicode.com/users"
    
    struct Todo : Codable {
        let userId: Int
        let id: Int
        let title: String
        let completed: Bool
    }
    
    struct User : Codable {
        let name: String
        let email: String
        let company: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case email
            case company
        }
        
        enum CompanyKeys: String, CodingKey {
            case name
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            name = try values.decode(String.self, forKey: .name)
            email = try values.decode(String.self, forKey: .email)
            let companyValues = try values.nestedContainer(keyedBy: CompanyKeys.self, forKey: .company)
            company = try companyValues.decode(String.self, forKey: .name)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(email, forKey: .email)
            var companyValues = container.nestedContainer(keyedBy: CompanyKeys.self, forKey: .company)
            try companyValues.encode(company, forKey: .name)
        }
    }
    
    func todoRequest(_ expectation: XCTestExpectation) {
        let c = count > 0 ? count : nil
        count = count > 0 ? count + 1 : 0
        let sequenceData = SequenceData(url: todoApi)
        DVSequence.shared.execute(sequenceData: sequenceData, completion: { (result: Result<Todo, Error>) in
            switch result {
            case let .success(todo):
                XCTAssertEqual(todo.userId, 1)
                XCTAssertEqual(todo.id, 1)
                XCTAssertEqual(todo.title, "delectus aut autem")
                XCTAssertEqual(todo.completed, false)
            case let .failure(error):
                XCTAssertNil(error.string)
            }
            if c != nil { print("completed \(c!)") }
            expectation.fulfill()
        })
    }
    
    func todosRequest(_ expectation: XCTestExpectation) {
        let c = count > 0 ? count : nil
        count = count > 0 ? count + 1 : 0
        let sequenceData = SequenceData(url: todosApi)
        DVSequence.shared.execute(sequenceData: sequenceData,
                                  completion: { (result: Result<[Todo], Error>) in
            switch result {
            case let .success(todos):
                XCTAssertEqual(todos.count, 200)
            case let .failure(error):
                XCTAssertNil(error.string)
            }
            if c != nil { print("completed \(c!)") }
            expectation.fulfill()
        })
    }
    
    
    func userRequest(_ expectation: XCTestExpectation) {
        let c = count > 0 ? count : nil
        count = count > 0 ? count + 1 : 0
        let sequenceData = SequenceData(url: userApi)
        DVSequence.shared.execute(sequenceData: sequenceData, completion: { (result: Result<User, Error>) in
            switch result {
            case let .success(user):
                XCTAssertEqual(user.name, "Leanne Graham")
                XCTAssertEqual(user.email, "Sincere@april.biz")
                XCTAssertEqual(user.company, "Romaguera-Crona")
            case let .failure(error):
                XCTAssertNil(error.string)
            }
            if c != nil { print("completed \(c!)") }
            expectation.fulfill()
        })
    }
    
    func usersRequest(_ expectation: XCTestExpectation) {
        let c = count > 0 ? count : nil
        count = count > 0 ? count + 1 : 0
        let sequenceData = SequenceData(url: usersApi)
        DVSequence.shared.execute(sequenceData: sequenceData, completion: { (result: Result<[User], Error>) in
            switch result {
            case let .success(todos):
                XCTAssertEqual(todos.count, 10)
            case let .failure(error):
                XCTAssertNil(error.string)
            }
            if c != nil { print("completed \(c!)") }
            expectation.fulfill()
        })
    }
    
    override func setUp() {
        // Put teardown code here. This method is called before the invocation of each test method in the class.
        count = 0
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    

    func testTodoRequest() {
        let expectation = XCTestExpectation(description: "downloading Todo request")
        todoRequest(expectation)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testTodosRequest() {
        let expectation = XCTestExpectation(description: "downloading Todos request")
        todosRequest(expectation)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testUserRequest() {
        let expectation = XCTestExpectation(description: "downloading User request")
        userRequest(expectation)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testUsersRequest() {
        let expectation = XCTestExpectation(description: "downloading Users request")
        usersRequest(expectation)
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPerformance() {
        // This is an example of a performance test case.
        self.measure {
            let expectation = XCTestExpectation(description: "downloading multiple requests")
            expectation.expectedFulfillmentCount = 4
            todoRequest(expectation)
            todosRequest(expectation)
            userRequest(expectation)
            usersRequest(expectation)
            wait(for: [expectation], timeout: 10.0)
        }
    }

}
