//
//  File.swift
//  
//
//  Created by Saiya Lee on 2/13/22.
//

import SwiftUI

public extension Color {
  
  /// get color from hex rgb color, hex color in **shorthand** like `#fff` is **not supported**
  ///
  /// ```swift
  /// // just change #00ff00 to 0x00ff00
  /// let color = Color(hexcode: 0x00ff00)
  /// ```
  ///
  /// - Parameter hexcode: 0xffffff
  init(hexcode: Int) {
    // overflow color will lead to black
    if hexcode > 0xffffff {
      self.init(red: 0, green: 0, blue: 0)
    } else {
      let red = Double((hexcode & 0xFF0000) >> 16) / 255.0
      let green = Double((hexcode & 0x00FF00) >> 8) / 255.0
      let blue = Double(hexcode & 0x0000FF) / 255.0
      self.init(red: red, green: green, blue: blue)
    }
  }
}
