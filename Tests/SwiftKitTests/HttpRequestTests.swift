import XCTest
import SwiftKit

final class HttpRequestTests: XCTestCase {
  struct IUserMeta: Codable {
    var page: Int
    var per_page: Int
    var total: Int
    var total_pages: Int
  }
  
  func testFetchWithUrl() async throws {
    let resp = try await HTTPRequest.fetch("https://search.evecalm.com/")
    let content = resp.text()
    XCTAssertTrue(resp.status == 200, "should be 200")
    XCTAssertTrue(content.count > 0, "should have content")
  }
  
  func testFetchWithRelatedUrl() async throws {
    let resp = try await HTTPRequest.fetch("/tj", .init(url: URL(string: "https://github.com/")!))
    let content = resp.text()
    XCTAssertTrue(resp.status == 200, "should be 200")
    XCTAssertTrue(content.count > 0, "should have content")
  }
  
  func testFetchWithPayloadAndParse() async throws {
    let resp = try await HTTPRequest.fetch(.init(url: URL(string: "https://reqres.in/api/users")!, qs: ["page": "1", "per_page": "3"]))
    let meta: IUserMeta = try resp.json()
    XCTAssertEqual(meta.page, 1)
  }
  
  struct INPMMeta: Decodable {
    var analyzedAt: Date
  }

  func testFetchCustomDecoder() async throws {
    let resp = try await HTTPRequest.fetch(URL(string: "https://api.npms.io/v2/package/react")!)
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
  
  func testApiWithStringUrl() async throws {
    let text: String = try await HTTPRequest.api("https://huaban.com/")
    XCTAssertTrue(text.count > 0, "should have content")
  }
  
  func testApiWithUrlObj() async throws {
    let text: String = try await HTTPRequest.api(URL(string: "https://huaban.com/")!)
    XCTAssertTrue(text.count > 0, "should have content")
  }
  
  func testApiForJson() async throws {
    let meta: IUserMeta = try await HTTPRequest.api(.init(url: URL(string: "https://reqres.in/api/users")!, qs: ["page": "1", "per_page": "3"]))
    XCTAssertEqual(meta.page, 1)
  }
  
  func testApiWithCustomDecoder() async throws {
    let meta: INPMMeta = try await HTTPRequest.api(URL(string: "https://api.npms.io/v2/package/react")!) { () -> JSONDecoder in
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
  
  func testCrawlUrl() async throws {
//    let html = try await HTTPRequest.crawl("https://2022.ip138.com/")
    let html = try await HTTPRequest.crawl("https://www.ip138.com/iplookup.asp?ip=115.44.3.105&action=2", responseEncoding: "gb2312")
    print("HTML", html)
    XCTAssertTrue(!html.isEmpty, "should has content")
  }
  
  func testQQZone() async throws {
    let resp = try await HTTPRequest.fetch("https://users.qzone.qq.com/fcg-bin/cgi_get_portrait.fcg?uins=123456")
    let text = resp.text(encoding: "GB18030")
    print("text", text)
    XCTAssertTrue(!text.isEmpty, "should have content")
  }
  
  func testPostJson() async throws {
    let data: IUserMeta = .init(page: 10, per_page: 100, total: 20, total_pages: 2)
    let resp: String = try await HTTPRequest.api("https://postman-echo.com/post", .init(
      method: .POST,
      body: data,
      encoder: .json
    ))
    print(resp)
    XCTAssertTrue(!resp.isEmpty)
  }
  
  func testTimeout() async throws {
    let start = Date().timeIntervalSince1970
    do {
      _ = try await HTTPRequest.api("https://postman-echo.com/post", .init(timeout: 2))
      print("success")
    } catch {
      print("error", error)
      let end = Date().timeIntervalSince1970
      XCTAssertTrue(end - start <= 3.0, "should break in 2 seconds")
    }
  }
  
  func testStringEncode() {
//    encodeURIComponent('https://v.youku.com/v_show/id_XNTg4MDUzMzU1Ng==.html').length
    let str = "https://aaa:ccc@v.youku.com/v_show/id_XNTg4MDUzMzU1Ng==.html"

    let encoded = str.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed)!
//    let encoded = str.addingPercentEncoding(withAllowedCharacters: NSMutableCharacterSet.urlQueryAllowed)!
    print(encoded)
    XCTAssertTrue(!encoded.isEmpty)
  }
}
