//
//  extension+number.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

extension Double {
  
  /// convert to Date in timestamp(second) format
  ///
  /// ```swift
  /// let time: Double = 123665566
  /// let date = time.toDate()
  /// ```
  /// - Returns: Date Object
  func toDate() -> Date {
    Date(timeIntervalSince1970: self)
  }
}

extension Int {
  /// convert to Date in timestamp(second) format
  ///
  /// ```swift
  /// let time = 123665566
  /// let date = time.toDate()
  /// ```
  /// - Returns: Date Object
  func toDate() -> Date {
    Date(timeIntervalSince1970: TimeInterval(self))
  }
}
