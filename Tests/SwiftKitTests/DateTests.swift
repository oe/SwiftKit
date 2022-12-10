//
//  DateTests.swift
//  
//
//  Created by Saiya Lee on 12/10/22.
//

import XCTest

final class DateTests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
  }
  
  func testDateRelativeFormat() throws {
    let date = Date(timeIntervalSince1970: 1670639580)
    let str = date.toString(.relative(.abbreviated, locale: .current))
    print("str", str)
    let twStr = date.toString(.relative(.abbreviated, locale: .init(identifier: "zh-TW")))
    print("twStr", twStr)
    XCTAssert(!str.isEmpty)
  }
  
}
