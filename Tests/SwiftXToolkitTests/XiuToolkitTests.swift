import XCTest
import SwiftXToolkit

final class XiuToolkitTests: XCTestCase {
  func testExample() throws {
      // This is an example of a functional test case.
      // Use XCTAssert and related functions to verify your tests produce the correct
      // results.
    XCTAssertEqual(SwiftXToolkit().text, "Hello, World!")
  }
  
  struct IUserMeta: Decodable {
    var page: Int
    var per_page: Int
    var total: Int
    var total_pages: Int
  }
  func testFetch() async throws {
    let requestPayload = HTTPRequestPayload(url: URL(string: "https://reqres.in/api/users")!, qs: ["page": "1", "per_page": "3"])
    print(requestPayload.body ?? "no body provide")
    let meta: IUserMeta = try await HTTPRequest.request(requestPayload)
    XCTAssertEqual(meta.page, 1)
  }
}
