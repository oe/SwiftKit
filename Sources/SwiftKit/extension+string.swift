//
//  extenison+string.swift
//
//
//  Created by Saiya Lee on 1/5/22.
//
import Foundation
import CryptoKit

public extension String {
  /// check string contains parts of string, case insensitive
  ///
  /// ```swift
  /// let str = "SwiftUI is Awesome"
  /// let hasSwiftUI = str.caseInsensitiveContains("swiftui")
  /// ```
  ///
  /// - Parameter str: component to check
  /// - Returns: whether contains that string
  func caseInsensitiveContains(_ str: String) -> Bool {
    guard let _ = range(of: str, options: .caseInsensitive) else {
      return false
    }
    return true
  }
  
  /// all chars unicode point accumulation
  /// empty string result in 0
  var unicodePoint: Int {
    var total: Int = 0
    for v in self.unicodeScalars {
      // handling overflow adding
      total &+= Int(v.value)
      if total < 0 {
        total += Int.max
      }
      
    }
    return total
  }
  
  
  /// string  sha1 hash string(40 letters)
  var sha1: String {
    let digest = Insecure.SHA1.hash(data: self.data(using: .utf8) ?? Data())
    
    return digest.map {
      String(format: "%02hhx", $0)
    }.joined()
  }
  
  /// string md5 hash string(32 letters)
  var md5: String {
    let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
    
    return digest.map {
      String(format: "%02hhx", $0)
    }.joined()
  }
  
  
  /// convert string to Date object
  ///
  /// ```swift
  /// let dateStr = "2021/12/12 23:45:32"
  /// let date = dateStr.toDate(format: .format("YYYY/MM/DD hh:mm:ss"))
  /// ```
  /// - Parameter format: data format that string is using, like "YYYY/MM/DD
  /// - Returns: date instance
  func toDate(format stringFormat: String2DateFormat) -> Date? {
    switch stringFormat {
      case .iso8601:
        let iso8601Formmater = ISO8601DateFormatter()
        return iso8601Formmater.date(from: self)
      case .format(let format, let locale):
        let dateFormatter = DateFormatter(format: format, locale: locale)
        return dateFormatter.date(from: self)
    }
  }
  
  /// convert string to struct
  ///
  /// ```swift
  /// struct User: Codable {
  ///   let name: String
  ///   let age: Int
  /// }
  /// let str = "{\"name\": \"Jack\", \"age\": 26}"
  /// let user: User = try str.toJSON()
  /// print(user.name)
  /// ```
  /// - Parameter encoding: string encoding name, default to .uft8
  /// - Returns: parsed struct
  func toJSON<T: Decodable>(encoding: String.Encoding = .utf8) throws -> T {
    let decoder = JSONDecoder()
    let data = self.data(using: encoding)
    guard let data = data else {
      throw SwiftKitError.runtimeError("unable to encoding with \(encoding)")
    }
    return try decoder.decode(T.self, from: data)
  }
  
  /// format for string that can convert to Date
  enum String2DateFormat {
    // standard iso8601 format
    case iso8601
    // normal date string format
    case format(_ format: String, locale: String? = nil)
  }
  
  
  /// get regexp matched part in a string
  ///
  /// ```swift
  /// let regStr = #"\/id(\d+)"#
  /// let reg = try! NSRegularExpression(pattern: regStr)
  /// let str = "id90232323"
  /// let id = str.getMatchedGroup(regexp: reg)
  /// ```
  /// - Parameters:
  ///   - regexp: regexp
  ///   - index: group index, default to 1(aka the first group)
  /// - Returns: string matched in that index
  func getMatchedGroup(regexp: NSRegularExpression, index: Int = 1) -> String? {
    guard let matched = regexp.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) else {
      return nil
    }
    
    guard let range = Range(matched.range(at: index), in: self) else {
      return nil
    }
    return String(self[range])
  }
  
  /// get regexp matched part in a string
  ///
  /// ```swift
  /// let str = "id90232323"
  /// let id = str.getMatchedGroup(pattern: #"\/id(\d+)"#)
  /// ```
  ///
  /// - Parameters:
  ///   - pattern: regexp pattern in string
  ///   - options: regexp options
  ///   - index: group index, starts from 1
  /// - Returns: string matched in that index
  func getMatchedGroup(pattern: String, options: NSRegularExpression.Options = [], index: Int = 1) -> String? {
    guard let regexp = try? NSRegularExpression(pattern: pattern, options: options),
          let matched = regexp.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) else {
      return nil
    }
    
    guard let range = Range(matched.range(at: index), in: self) else {
      return nil
    }
    return String(self[range])
  }
}
