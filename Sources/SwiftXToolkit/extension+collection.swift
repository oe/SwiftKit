//
//  File.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

extension RandomAccessCollection where Element: Identifiable {
  
  /// check whether an element is included in a  collection
  /// - Parameter element: element should conforms to ``Identifiable``
  /// - Returns: true for found
  func contains(_ element: Element) -> Bool {
    self.contains { item in
      item[keyPath: \.id] == element[keyPath: \.id]
    }
  }
}
