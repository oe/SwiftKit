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
  
  struct INPMMeta: Decodable {
    var analyzedAt: Date
  }
  func testFetchCustomDecoder() async throws {
    let requestPayload = HTTPRequestPayload(url: URL(string: "https://api.npms.io/v2/package/react")!)
    print(requestPayload.body ?? "no body provide")
    let meta: INPMMeta = try await HTTPRequest.request(requestPayload) { decoder in
      decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)
        let isoFormatter = ISO8601DateFormatter()
        // "2022-01-09T00:11:09.676Z" is iso8601 with fractional seconds
        isoFormatter.formatOptions.insert(.withFractionalSeconds)
        return isoFormatter.date(from: dateStr)!
      })
    }
    let dateString = meta.analyzedAt.toString(.format("EEEE, MMM d, yyyy", locale: "zh-TW"))
    XCTAssertNotEqual(dateString, "")
  }
}
