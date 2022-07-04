//
//  StandardRequest.swift
//  swift-demo
//
//  Created by Saiya Lee on 1/9/22.
//
import Combine
import Foundation

public enum HTTPRequest {
  
  /// HTTP Error
  public enum RequestError: Error {
    case urlMissing
    case invalidURL
    case malformedBody
  }


  /// HTTP methods
  public enum Method {
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
  
  /// common http request payload
  public struct Request {
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
    public init(url: URL, method: Method? = nil, qs: [String : String]? = nil, headers: [String : String]? = nil, body: Data? = nil, json: Bool? = nil, timeout: TimeInterval? = nil) {
      self.url = url
      self.method = method
      self.qs = qs
      self.headers = headers
      self.body = body
      self.json = json
      self.timeout = timeout
    }
    
    
    /// init with encodable body
    public init<T: Encodable>(url: URL, method: Method? = nil, qs: [String : String]? = nil, headers: [String : String]? = nil, body: T? = nil, json: Bool? = nil, timeout: TimeInterval? = nil) throws {
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
  public struct Response {
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

    public func text() -> String? {
      let encoding: String.Encoding!
      if let textEncodingName = response.textEncodingName {
        let cfe = CFStringConvertIANACharSetNameToEncoding(textEncodingName as CFString)
        let se = CFStringConvertEncodingToNSStringEncoding(cfe)
        encoding = String.Encoding(rawValue: se)
      } else {
        encoding = .utf8
      }
      return String(data: data, encoding: encoding)
    }
    
    public func json<T: Decodable>() throws -> T {
      let decoder = JSONDecoder()
      return try decoder.decode(T.self, from: data)
    }
    
    public func json<T: Decodable, D: TopLevelDecoder>(_ getDecoder: @escaping () -> D)  throws -> T where D.Input == Data {
      let decoder = getDecoder()
      return try decoder.decode(T.self, from: data)
    }
    
    public func blob() -> Data {
      data
    }
  }
  
  public typealias CustomDecoder = ( _ decoder: JSONDecoder) -> Void
  
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
  public static func fetch(_ url: String) async throws -> Response {
    guard let requestUrl = URL(string: url) else {
      throw RequestError.invalidURL
    }
    return try await fetch(requestUrl)
  }
  
  public static func fetch(_ url: String, _ payload: Request) async throws -> Response {
    var httpRequest = payload
    httpRequest.url = URL(string: url, relativeTo: httpRequest.url)
    return try await fetch(httpRequest)
  }
  
  public static func fetch(_ url: URL, _ payload: Request) async throws -> Response {
    var httpRequest = payload
    httpRequest.url = url
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
}
