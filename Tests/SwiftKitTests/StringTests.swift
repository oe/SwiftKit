//
//  StringTests.swift
//  
//
//  Created by Saiya Lee on 7/5/22.
//

import XCTest
import SwiftKit

final class StringTests: XCTestCase {

  override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testCaseInsenstiveContains() throws {
    XCTAssertTrue("abc".caseInsensitiveContains("Ab"))
    XCTAssertTrue(" after the invocation".caseInsensitiveContains(" inVOcaT"))
    XCTAssertTrue(" after the invocation".caseInsensitiveContains(" inVOcaTo") == false)
  }
  
  func testUnicodePoint() throws {
    XCTAssertTrue("a".unicodePoint == 97)
    XCTAssertTrue("ab".unicodePoint == 195)
  }
  
  func testString2Date() throws {
    let date = "2021/12/12".toDate(format: .format("YYYY/MM/DD"))
    XCTAssertTrue(date != nil)
    let compts = Calendar.current.dateComponents([.year, .month, .day], from: date!)
    XCTAssertTrue(compts.year == 2021)
  }
  
  func testToJSON() throws {
    let str = """
    {"name": "Xiu", "age": 21}
    """
    
    let user: User = try str.toJSON()
    print(user)
    XCTAssert(user.age == 21)
  }
  
  struct User: Codable {
    let name: String
    let age: Int
  }

}
