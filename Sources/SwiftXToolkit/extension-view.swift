//
//  SwiftUIView.swift
//  
//
//  Created by Saiya Lee on 2/13/22.
//

import SwiftUI

public extension View {
  /// a modifier just works opposite to mask
  /// ```swift
  /// Color.yellow
  /// .frame(width: 200, height: 200)
  /// .reverseMask{ Star() }
  /// ```
  ///
  /// reference:  <https://www.fivestars.blog/articles/reverse-masks-how-to/>
  func reverseMask<Mask: View>(
    alignment: Alignment = .center,
    @ViewBuilder _ mask: () -> Mask
  ) -> some View {
    self.mask {
      Rectangle()
        .overlay(alignment: alignment) {
          mask()
            .blendMode(.destinationOut)
        }
    }
  }
}
