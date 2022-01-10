//
//  Extensions.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 5/28/21.
//

import SwiftUI

public extension View {
  func fullScreenBlackBackgroundIgnoresSafeArea() -> some View {
    modifier(FullScreenBlackBackgroundIgnoresSafeArea())
  }
}

#if os(iOS)
  public extension CGFloat {
    static let fullScreenWidth = UIScreen.main.bounds.width
    static let fullScreenHeight = UIScreen.main.bounds.height
  }
#endif

/// Colors of buttons.
public extension Color {
  static let normalButtonColor = Color(red: 0.2, green: 0.2, blue: 0.2)
  static let highlightedButtonColor = Color(
    red: 0.467,
    green: 0.467,
    blue: 0.467
  )
}
