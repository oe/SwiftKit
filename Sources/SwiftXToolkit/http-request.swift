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
  /// URL target
  var url: URL
  /// request method, default to get
  var method: HTTPRequestMethod?
  /// query string
  var qs: [String: String]?
  /// http headers
  var headers: [String: String]?
  /// request body (for post/put)
  var body: Data?
  /// use json request, add accept/content-type header automaticlly
  var json: Bool?
}

public enum HTTPRequest {
  enum RequestError: Error {
    case invalidURL
  }
  static func request<T: Decodable>(_ url: String) async throws -> T {
    guard let requestUrl = URL(string: url) else {
      throw RequestError.invalidURL
    }
    return try await request(requestUrl)
  }
  static func request<T: Decodable>(_ url: URL) async throws -> T {
    return try await request(HTTPRequestPayload(url: url))
  }
  
  static func request<T: Decodable>(_ payload: HTTPRequestPayload) async throws -> T {
    var urlRequest: URLRequest = URLRequest(url: payload.url)
    if let qs = payload.qs {
      var urlComponents = URLComponents(string: payload.url.absoluteString)!
      if urlComponents.queryItems == nil {
        urlComponents.queryItems = []
      }
      for (key, value) in qs {
        urlComponents.queryItems!.append(URLQueryItem(name: key, value: value))
      }
      urlRequest.url = urlComponents.url
    }
    // default to GET if nil
    urlRequest.httpMethod = (payload.method ?? .GET).toString()

    if let headers = payload.headers {
      for (key, value) in headers {
        urlRequest.addValue(value, forHTTPHeaderField: key)
      }
    }
    
    let usingJson = payload.json == true
    
    if let body = payload.body {
      urlRequest.httpBody = body
      if usingJson {
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-type")
      }
    }
    if usingJson {
      urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    }

    do {
      let (data, _) = try await URLSession.shared.data(for: urlRequest)
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      throw error
    }
  }
}
