//
//  File.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

extension String {
  // check string contains parts of string, case insensitive
  func caseInsensitiveContains(_ str: String) -> Bool {
    guard let _ = range(of: str, options: .caseInsensitive) else {
      return false
    }
    return true
  }
  
  // convert string to Date object
  func toDate(format: String) -> Date? {
    let dateFormatter = DateFormatter(dateFormat: format)
    return dateFormatter.date(from: self)
  }
  
  // get regex matched part in a string
  func getMatchedGroup(index: Int, regexp: NSRegularExpression) -> String? {
    guard let matched = regexp.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) else {
      return nil
    }
    
    guard let range = Range(matched.range(at: index), in: self) else {
      return nil
    }
    return String(self[range])
  }
}
