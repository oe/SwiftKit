//
//  File 2.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

extension Date {
  
  /// create Date from ios8601 style time string
  ///
  /// ```swift
  /// let date = Date(iso8601: "2006-10-24T07:00:00Z")
  /// ```
  /// - Parameter iso8601: iso8601 style  time string
  init?(iso8601:String) {
    if let date = Date.iso8601Formatter.date(from: iso8601) {
      self = date
    } else {
      return nil
    }
  }
  
  /// ios8601 date formatter
  static let iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate,
                               .withTime,
                               .withDashSeparatorInDate,
                               .withColonSeparatorInTime]
    return formatter
  }()

  
  /// convert date to formatted string
  ///
  /// ```swift
  /// let fullTime = date.toString(.format("YYYY-MM-DD hh:mm"))
  /// let relativeTime = date.toString(.relative(.full))
  /// ```
  /// - Parameter format: see ``DateStringFormat`` for details
  /// - Returns: formatted string
  func toString(_ format: DateStringFormat) -> String {
    switch format {
      case .format(let dateFormat):
        let dateFormatter = DateFormatter(dateFormat: dateFormat)
        return dateFormatter.string(from: self)
      case .relative(let style):
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = style ?? .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
  }
}


/// date string format
public enum DateStringFormat {
  /** normal  `YYYY/MM/DD` format */
  case format(String);
  /** relative time in ``RelativeDateTimeFormatter`` */
  case relative(RelativeDateTimeFormatter.UnitsStyle?);
}

extension DateFormatter {
  
  /// create a DateFormatter via format string
  ///
  /// ```swift
  /// let formatter = DateFormatter(dateFormat: "YYYY/MM/DD")
  /// ```
  /// - Parameter dateFormat: format string, like YYYY/MM/DD
  convenience init(dateFormat: String) {
    self.init()
    self.dateFormat = dateFormat
  }
}
