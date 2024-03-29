//
//  File.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

public extension Sequence where Element: Identifiable {
  
  /// check whether an element is included in a  collection
  /// - Parameter element: element should conforms to ``Identifiable``
  /// - Returns: true for found
//  func contains(_ element: Element) -> Bool {
//    self.contains { item in
//      item[keyPath: \.id] == element[keyPath: \.id]
//    }
//  }
  
  /// Get uniqued sequence when element is identificable
  func uniqued() -> [Element] {
    var seen: Set<Element.ID> = []
    return filter { seen.insert($0[keyPath: \.id]).inserted }
  }

}

//public extension Sequence where Element: Hashable {
//  
//  /// Get uniqued sequence when element is hashable
//  func uniqued() -> [Element] {
//    var seen: Set<Element> = []
//    return filter { seen.insert($0).inserted }
//  }
//}
