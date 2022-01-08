//
//  extenison+string.swift
//
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

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
  
  
  /// convert string to Date object
  ///
  /// ```swift
  /// let dateStr = "2021/12/12 23:45:32"
  /// let date = dateStr.toDate("YYYY/MM/DD hh:mm:ss")
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
}
