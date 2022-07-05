//
//  CollectionTests.swift
//  
//
//  Created by Saiya Lee on 7/5/22.
//

import XCTest

final class CollectionTests: XCTestCase {

  override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  struct User: Equatable, Hashable, Identifiable {
    var id: String
    var name: String
  }
  
  func testArrayUnique() {
    let collection = [User(id: "1", name: "Saiya"), User(id: "1", name: "aaa")]
    XCTAssertEqual(collection.uniqued(), [User(id: "1", name: "Saiya")])
    XCTAssertTrue(collection.contains(User(id: "1", name: "Saiya")))
  }

}
