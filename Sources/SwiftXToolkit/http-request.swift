//
//  StandardRequest.swift
//  swift-demo
//
//  Created by Saiya Lee on 1/9/22.
//

import Foundation


/// HTTP methods
public enum HTTPRequestMethod {
  case GET
  case POST
  case PUT
  case DELETE
  case CUSTOM(_ method: String)
  
  func toString() -> String {
    switch self {
      case .CUSTOM(let method):
        return method
      case .GET:
        return "GET"
      case .POST:
        return "POST"
      case .PUT:
        return "PUT"
      case .DELETE:
        return "DELETE"
    }
  }
}


/// common http request payload
public struct HTTPRequestPayload {
  /// init with standard parameters
  public init(url: URL, method: HTTPRequestMethod? = nil, qs: [String : String]? = nil, headers: [String : String]? = nil, body: Data? = nil, json: Bool? = nil) {
    self.url = url
    self.method = method
    self.qs = qs
    self.headers = headers
    self.body = body
    self.json = json
  }
  
  
  /// init with encodable body
  public init<T: Encodable>(url: URL, method: HTTPRequestMethod? = nil, qs: [String : String]? = nil, headers: [String : String]? = nil, body: T? = nil, json: Bool? = nil) throws {
    if let body = body {
      guard let bodyData = try? JSONEncoder().encode(body) else {
        throw HTTPRequestError.malformedBody
      }
      self.init(url: url, method: method, qs: qs, headers: headers, body: bodyData, json: json)
    } else {
      self.init(url: url, method: method, qs: qs, headers: headers, body: nil, json: json)
    }
  }
  
  /// URL target
  public var url: URL
  /// request method, default to get
  public var method: HTTPRequestMethod?
  /// query string
  public var qs: [String: String]?
  /// http headers
  public var headers: [String: String]?
  /// request body (for post/put)
  public var body: Data?
  /// use json request, add accept/content-type header automaticlly
  public var json: Bool?
  
  /// convert to an URLRequest object which can be used in http request
  public func toURLRequest() -> URLRequest {
    var urlRequest: URLRequest = URLRequest(url: url)
    // append qs
    if let qs = self.qs {
      var urlComponents = URLComponents(string: url.absoluteString)!
      if urlComponents.queryItems == nil {
        urlComponents.queryItems = []
      }
      for (key, value) in qs {
        urlComponents.queryItems!.append(URLQueryItem(name: key, value: value))
      }
      urlRequest.url = urlComponents.url
    }
    // default to GET if nil
    urlRequest.httpMethod = (method ?? .GET).toString()
    
    if let headers = self.headers {
      for (key, value) in headers {
        urlRequest.addValue(value, forHTTPHeaderField: key)
      }
    }
    
    let usingJson = json == true
    
    if let body = self.body {
      urlRequest.httpBody = body
      if usingJson {
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      }
    }
    if usingJson {
      urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    }
    
    return urlRequest
  }
}

public enum HTTPRequestError: Error {
  case invalidURL
  case malformedBody
}


public enum HTTPRequest {
  
  /// request with an url string
  ///
  /// ```swift
  /// struct IUserMeta: Decodable {
  ///   var page: Int
  ///   var per_page: Int
  ///   var total: Int
  ///   var total_pages: Int
  ///
  ///  static func getData() async throws -> Self {
  ///   try await HTTPRequest.request("https://reqres.in/api/users?page=1&per_page=3")
  ///  }
  /// }
  /// ```
  ///
  /// - Returns: request result
  public static func request<T: Decodable>(_ url: String) async throws -> T {
    guard let requestUrl = URL(string: url) else {
      throw HTTPRequestError.invalidURL
    }
    return try await request(requestUrl)
  }
  
  
  /// request with an ``URL`` Object
  ///
  /// ```swift
  /// struct IUserMeta: Decodable {
  ///   var page: Int
  ///   var per_page: Int
  ///   var total: Int
  ///   var total_pages: Int
  ///
  ///  static func getData() async throws -> Self {
  ///   try await HTTPRequest.request(URL(string: "https://reqres.in/api/users?page=1&per_page=3")!)
  ///  }
  /// }
  /// ```
  ///
  /// - Returns: request result
  public static func request<T: Decodable>(_ url: URL) async throws -> T {
    return try await request(HTTPRequestPayload(url: url))
  }
  
  
  /// request with a ``HTTPRequestPayload`` Object
  ///
  /// ```swift
  /// struct IUserMeta: Decodable {
  ///   var page: Int
  ///   var per_page: Int
  ///   var total: Int
  ///   var total_pages: Int
  ///
  ///  static func getData() async throws -> Self {
  ///   try await HTTPRequest.request(HTTPRequestPayload(
  ///     url: URL(string: "https://reqres.in/api/users")!,
  ///     qs: ["page": "1", "per_page": "3"]
  ///   ))
  ///  }
  /// }
  /// ```
  ///
  /// - Returns: request result
  public static func request<T: Decodable>(_ payload: HTTPRequestPayload) async throws -> T {
    do {
      let (data, _) = try await URLSession.shared.data(for: payload.toURLRequest())
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      throw error
    }
  }
}
