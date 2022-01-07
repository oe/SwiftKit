//
//  extension+json.swift
//  
//
//  Created by Saiya Lee on 1/5/22.
//

import Foundation

/// failable json decoder
///
/// fork from <https://stackoverflow.com/questions/46344963/swift-jsondecode-decoding-arrays-fails-if-single-element-decoding-fails>
///
/// ```swift
/// let json = """
/// [
///   { "name": "Banana", "points": 200, "description": "A banana grown in Ecuador."},
///   { "name": "Orange"}
/// ]
/// """.data(using: .utf8)!
///
/// struct GroceryProduct : Codable {
///   var name: String
///   var points: Int
///   var description: String?
/// }
///
/// let products = try JSONDecoder()
///   .decode([FailableDecodable<GroceryProduct>].self, from: json)
///   .compactMap { $0.value } // .flatMap in Swift 4.0
///
/// print(products)
/// ```
struct FailableDecodable<Base : Decodable> : Decodable {
  let value: Base?
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.value = try? container.decode(Base.self)
  }
}
