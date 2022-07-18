//
//  File.swift
//  
//
//  Created by Saiya Lee on 7/18/22.
//

import Foundation

public extension URL {
  
  /// url's origin(compose by scheme://host:port
  var origin: String? {
    guard let scheme = self.scheme,
          let host = self.host else {
      return nil
    }
    var o = "\(scheme)://\(host)"
    if let port = self.port {
      o += ":\(port)"
    }
    return o
  }
}
