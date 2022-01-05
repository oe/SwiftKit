//
//  File.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

extension RandomAccessCollection where Element: Identifiable {
  // add contains to Array, Set and Anything like them
  //  usage: arr.contains(item)
  func contains(_ element: Element) -> Bool {
    self.contains { item in
      item[keyPath: \.id] == element[keyPath: \.id]
    }
  }
}
