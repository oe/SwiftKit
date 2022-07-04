import XCTest
import SwiftXToolkit

final class XiuToolkitTests: XCTestCase {
  func testExample() throws {
      // This is an example of a functional test case.
      // Use XCTAssert and related functions to verify your tests produce the correct
      // results.
    XCTAssertEqual("SwiftUI is awesome".caseInsensitiveContains("swiftui"), true)
  }
  
  struct IUserMeta: Decodable {
    var page: Int
    var per_page: Int
    var total: Int
    var total_pages: Int
  }
  
  func testFetchGithub() async throws {
    let resp = try await HTTPRequest.fetch("https://search.evecalm.com/", .init(url: URL(string: "https://github.com/")!))
    let content = resp.text()!
    print(content)
    XCTAssertTrue(content.count > 0, "should have content")
  }
  
  func testFetch() async throws {
    let requestPayload = HTTPRequest.Request(url: URL(string: "https://reqres.in/api/users")!, qs: ["page": "1", "per_page": "3"])
    print(requestPayload.body ?? "no body provide")
    let resp = try await HTTPRequest.fetch(requestPayload)
    let meta: IUserMeta = try resp.json()
    XCTAssertEqual(meta.page, 1)
  }
  
  struct INPMMeta: Decodable {
    var analyzedAt: Date
  }

  func testFetchCustomDecoder() async throws {
    let requestPayload = HTTPRequest.Request(url: URL(string: "https://api.npms.io/v2/package/react")!)
    print(requestPayload.body ?? "no body provide")
    let resp = try await HTTPRequest.fetch(requestPayload)
    let meta: INPMMeta = try resp.json { () -> JSONDecoder in
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)
        let isoFormatter = ISO8601DateFormatter()
        // "2022-01-09T00:11:09.676Z" is iso8601 with fractional seconds
        isoFormatter.formatOptions.insert(.withFractionalSeconds)
        return isoFormatter.date(from: dateStr)!
      })
      return decoder
    }
    let dateString = meta.analyzedAt.toString(.format("EEEE, MMM d, yyyy", locale: "zh-TW"))
    XCTAssertNotEqual(dateString, "")
  }
  
  struct User: Equatable, Hashable, Identifiable {
    var id: String
    var name: String
  }
  
  func testArrayUnique() {
//    XCTAssertEqual([1,2,3,2,3].uniqued(), [1,2,3])
    
    XCTAssertEqual([User(id: "1", name: "Saiya"), User(id: "1", name: "aaa")].uniqued(), [User(id: "1", name: "Saiya")])
  }
}
