//
//  File.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

extension Double {  
  func toDate() -> Date {
    Date(timeIntervalSince1970: self)
  }
}

extension Int {
  func toDate() -> Date {
    Date(timeIntervalSince1970: TimeInterval(self))
  }
}
