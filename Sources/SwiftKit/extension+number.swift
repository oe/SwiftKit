//
//  extension+number.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

public extension Double {
  
  /// convert to Date in timestamp(second) format
  ///
  /// ```swift
  /// let time: Double = 1641632605312
  /// let date = time.toDate()
  /// ```
  /// - Parameter isMillisecond: whether time is in millisecond format, such as javascript timestamp
  /// - Returns: Date Object
  func toDate(isMillisecond: Bool = false) -> Date {
    Date(timeIntervalSince1970: isMillisecond ? self / 1000 : self)
  }
}

public extension Int {
  /// convert to Date in timestamp(second) format
  ///
  /// be aware, on Latest Apple device, Int should be Int64
  /// ```swift
  /// let time = 1641632605312
  /// let date = time.toDate()
  /// ```
  /// - Parameter isMillisecond: whether time is in millisecond format, such as javascript timestamp
  /// - Returns: Date Object
  func toDate(isMillisecond: Bool = false) -> Date {
    Date(timeIntervalSince1970: TimeInterval(isMillisecond ? self / 1000 : self))
  }
}
