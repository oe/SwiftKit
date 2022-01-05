//
//  File 2.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

extension Date {
    init(iso8601:String) {
        self = Date.iso8601Formatter.date(from: iso8601)!
    }

    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,
                                          .withTime,
                                          .withDashSeparatorInDate,
                                          .withColonSeparatorInTime]
        return formatter
    }()
  
  // - MARK convert date to formatted string
  // usage:
  //  date.toString(.format("YYYY-MM-DD hh:mm"))
  //  date.toString(.relative(.full))
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

public enum DateStringFormat {
  case format(String);
  case relative(RelativeDateTimeFormatter.UnitsStyle?);
}

extension DateFormatter {
  convenience init(dateFormat: String) {
    self.init()
    self.dateFormat = dateFormat
  }
}
