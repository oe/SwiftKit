//
//  ColorTests.swift
//  
//
//  Created by Saiya Lee on 7/5/22.
//

import XCTest
import SwiftUI

final class ColorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHexColor() throws {
      let color = Color(hexcode: 0x112233)
      XCTAssertTrue(color == Color(red: 0x11 / 255, green: 0x22 / 255, blue: 0x33 / 255), "hexcode color should equal to normal RGB color")
    }

}
