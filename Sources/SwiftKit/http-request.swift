//
//  StandardRequest.swift
//  swift-demo
//
//  Created by Saiya Lee on 1/9/22.
//
import Combine
import Foundation
import WebKit

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
  public static func fetch(_ url: String, _ payload: Request? = nil) async throws -> Response {
    var httpRequest: Request!
    if let payload = payload {
      httpRequest = payload
      httpRequest.url = URL(string: url, relativeTo: httpRequest.url)
    } else {
      guard let requestUrl = URL(string: url) else {
        throw RequestError.invalidURL
      }
      httpRequest = .init(url: requestUrl)
    }
    
    return try await fetch(httpRequest)
  }
  
  public static func fetch(_ url: URL, _ payload: Request? = nil) async throws -> Response {
    var httpRequest: Request!
    if let payload = payload {
      httpRequest = payload
      httpRequest.url = url
    } else {
      httpRequest = .init(url: url)
    }
    return try await fetch(httpRequest)
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
  ///   let resp = try await HTTPRequest.request(URL(string: "https://reqres.in/api/users?page=1&per_page=3")!)
  ///   return try resp.json()
  ///  }
  /// }
  /// ```
  ///
  /// - Returns: request result
  public static func fetch(_ url: URL) async throws -> Response {
    return try await fetch(Request(url: url))
  }
  

  /// get string an decode in correct text encoding
  /// - Parameter payload: request params
  /// - Returns: string
  public static func fetch(_ payload: Request) async throws -> Response {
    let request = try payload.toURLRequest()
    let (data, response) = try await URLSession.shared.data(for: request)
    return Response(request: payload, data: data, response: response)
  }
  
  
  /// get string response directly
  /// - Parameters:
  ///   - url: url string
  ///   - payload: optional payload
  /// - Returns: reponse body in string
  public static func api(_ url: String, _ payload: Request? = nil) async throws -> String {
    let resp = try await fetch(url, payload)
    return resp.text()
  }
  
  public static func api(_ url: URL, _ payload: Request? = nil) async throws -> String {
    let resp = try await fetch(url, payload)
    return resp.text()
  }
  
  public static func api(_ payload: Request) async throws -> String {
    let resp = try await fetch(payload)
    return resp.text()
  }
  

  /// get parsed JSON response
  /// - Parameters:
  ///   - url: url
  ///   - payload: optional payload
  /// - Returns: response body in parsed struct
  public static func api<T: Decodable, D: TopLevelDecoder>(_ url: String, _ payload: Request? = nil, decoder getDecoder: (() -> D)) async throws -> T where D.Input == Data {
    let resp = try await fetch(url, payload)
    return try resp.json(decoder: getDecoder)
  }
  
  public static func api<T: Decodable>(_ url: String, _ payload: Request? = nil) async throws -> T {
    let resp = try await fetch(url, payload)
    return try resp.json()
  }

  
  public static func api<T: Decodable>(_ url: URL, _ payload: Request? = nil) async throws -> T {
    let resp = try await fetch(url, payload)
    return try resp.json()
  }
  public static func api<T: Decodable, D: TopLevelDecoder>(_ url: URL, _ payload: Request? = nil, decoder getDecoder: (() -> D)) async throws -> T where D.Input == Data {
    let resp = try await fetch(url, payload)
    return try resp.json(decoder: getDecoder)
  }

  
  public static func api<T: Decodable>(_ payload: Request) async throws -> T {
    let resp = try await fetch(payload)
    return try resp.json()
  }
  public static func api<T: Decodable, D: TopLevelDecoder>(_ payload: Request, decoder getDecoder: (() -> D)) async throws -> T where D.Input == Data {
    let resp = try await fetch(payload)
    return try resp.json(decoder: getDecoder)
  }
}


/// extension for request and response
public extension HTTPRequest {
  /// common http request payload
  struct Request {
    /// URL target
    public var url: URL?
    /// request method, default to get
    public var method: Method?
    /// query string
    public var qs: [String: String]?
    /// http headers
    public var headers: [String: String]?
    /// request body (for post/put)
    public var body: Data?
    /// use json request, add accept/content-type header automaticlly
    public var json: Bool?
    /// timeout in senconds, default to 60s internal
    public var timeout: TimeInterval?
    
    /// init with standard parameters
    public init(url: URL? = nil, method: Method? = nil, qs: [String : String]? = nil, headers: [String : String]? = nil, body: Data? = nil, json: Bool? = nil, timeout: TimeInterval? = nil) {
      self.url = url
      self.method = method
      self.qs = qs
      self.headers = headers
      self.body = body
      self.json = json
      self.timeout = timeout
    }
    
    
    /// init with encodable body
    public init<T: Encodable>(url: URL? = nil, method: Method? = nil, qs: [String : String]? = nil, headers: [String : String]? = nil, body: T? = nil, json: Bool? = nil, timeout: TimeInterval? = nil) throws {
      if let body = body {
        guard let bodyData = try? JSONEncoder().encode(body) else {
          throw RequestError.malformedBody
        }
        self.init(url: url, method: method, qs: qs, headers: headers, body: bodyData, json: json, timeout: timeout)
      } else {
        self.init(url: url, method: method, qs: qs, headers: headers, body: nil, json: json, timeout: timeout)
      }
    }
    
    /// convert to an URLRequest object which can be used in http request
    public func toURLRequest() throws -> URLRequest {
      guard let url = url else {
        throw RequestError.urlMissing
      }
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

  /// URL Response struct
  struct Response {
    let request: Request
    let data: Data
    let response: URLResponse
    let httpResponse: HTTPURLResponse?
    
    public init (request: Request, data: Data, response: URLResponse) {
      self.request = request
      self.data = data
      self.response = response
      if let httpResponse = response as? HTTPURLResponse {
        self.httpResponse = httpResponse
      } else {
        self.httpResponse = nil
      }
    }
    
    public var status: Int {
      httpResponse?.statusCode ?? 0
    }
    
    public var url: URL? {
      response.url
    }
    /// is request OK
    public var isOk: Bool {
      (200...299).contains(status) || status == 0
    }
    
    public var redirected: Bool {
      url != request.url
    }
    
    public var statusText: String {
      HTTPURLResponse.localizedString(forStatusCode: status)
    }
    
    public func getHeader(_ name: String) -> String? {
      httpResponse?.value(forHTTPHeaderField: name)
    }
    
    public var headers: [AnyHashable: Any]? {
      httpResponse?.allHeaderFields
    }
    
    public var body: Data {
      data
    }

    public func text() -> String {
      let encoding: String.Encoding!
      if let textEncodingName = response.textEncodingName {
        let cfe = CFStringConvertIANACharSetNameToEncoding(textEncodingName as CFString)
        let se = CFStringConvertEncodingToNSStringEncoding(cfe)
        encoding = String.Encoding(rawValue: se)
      } else {
        encoding = .utf8
      }
      return String(data: data, encoding: encoding) ?? ""
    }
    
    public func json<T: Decodable>() throws -> T {
      let decoder = JSONDecoder()
      return try decoder.decode(T.self, from: data)
    }
    
    /// decode to struct with custom decoder
    /// - Parameter getDecoder function to get that decoder
    /// - Returns: parsed struct
    ///
    ///  due to latest swift (5.7) cann't infer type from a default parameter ( https://forums.swift.org/t/generic-parameter-d-could-not-be-inferred/58696 )
    ///       this method cann't be written in following pattern and replace the previous one
    ///       `public func json<T: Decodable, D: TopLevelDecoder>(_ getDecoder: (() -> D) = { JSONDecoder() } )  throws -> T where D.Input == Data {`
    public func json<T: Decodable, D: TopLevelDecoder>(decoder getDecoder: (() -> D) )  throws -> T where D.Input == Data {
      let decoder = getDecoder()
      return try decoder.decode(T.self, from: data)
    }
    
    public func blob() -> Data {
      data
    }
  }
  
}

/// extension for error  and Method
public extension HTTPRequest {
  /// HTTP Error
  enum RequestError: Error {
    case urlMissing
    case invalidURL
    case malformedBody
  }

  /// HTTP methods
  enum Method {
    case GET
    case POST
    case PUT
    case DELETE
    case CUSTOM(_ method: String)
    
    public func toString() -> String {
      switch self {
        case .CUSTOM(let method):
          return method.uppercased()
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
}

/// extension for web crawler
public extension HTTPRequest {
  private static var cachedUserAgent = ""
  
  
  /// current device userAgent
  ///   should access it in a async queue, or it will crash your app
  static var currentUserAgent: String {
    if cachedUserAgent.isEmpty {
      cachedUserAgent = WKWebView().value(forKey: "userAgent") as! String
    }
    return cachedUserAgent
  }
  
  
  /// crawl webpage with current use agent by default
  /// - Parameters:
  ///   - url: url
  ///   - referrer: referer string
  ///   - options: custom request payload
  /// - Returns: html body
  static func crawl(_ url: String? = nil, referrer: String? = nil, payload options: Request? = nil) async throws -> String {
    var request: Request!
    if options != nil {
      request = options!
      if url != nil {
        request.url = URL(string: url!, relativeTo: options!.url)
      }
    } else {
      guard url != nil else {
        throw RequestError.urlMissing
      }
      request = Request(url: URL(string: url!))
    }
    var requestReferrer: String!
    if referrer == nil {
      guard let finalUrl = request.url,
            let origin = finalUrl.origin else {
        throw RequestError.urlMissing
      }
      requestReferrer = "\(origin)/"
    } else {
      requestReferrer = referrer!
    }
    
    
    if request.headers != nil {
      if !request.headers!.contains(where: { $0.key.lowercased() == "user-agent"}) {
        request.headers!["User-Agent"] = currentUserAgent
        request.headers!["Referer"] = requestReferrer
      }
    } else {
      request.headers = [
        "User-Agent": currentUserAgent,
        "Referer": requestReferrer
      ]
    }
    
    let response = try await fetch(request)
    return response.text()
  }
  
}
