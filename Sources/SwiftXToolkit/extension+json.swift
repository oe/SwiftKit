//
//  File.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

  // - JSON Decoder ignore invalid array item
  // reference https://stackoverflow.com/questions/46344963/swift-jsondecode-decoding-arrays-fails-if-single-element-decoding-fails
struct FailableDecodable<Base : Decodable> : Decodable {
  
  let base: Base?
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.base = try? container.decode(Base.self)
  }
}
