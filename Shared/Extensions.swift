//
//  Extensions.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 5/28/21.
//

import SwiftUI

public extension View {
  /// A full-bleed black background that respects each platform's window model.
  func fullScreenBlackBackgroundIgnoresSafeArea() -> some View {
    modifier(FullScreenBlackBackgroundIgnoresSafeArea())
  }
}

/// Semantic color tokens backed by the asset catalog so they adapt to dark mode
/// and stay tint-friendly under Liquid Glass.
public extension Color {
  static let buttonBackground = Color("ButtonBackground", bundle: .main)
  static let buttonBackgroundHighlighted = Color(
    "ButtonBackgroundHighlighted", bundle: .main)

  // Per-demo gradient endpoints (visual identity preserved from the original).
  static let springTop = Color("SpringTop", bundle: .main)
  static let springBottom = Color("SpringBottom", bundle: .main)
  static let rubberbandingTop = Color("RubberbandingTop", bundle: .main)
  static let rubberbandingBottom = Color("RubberbandingBottom", bundle: .main)
  static let accelerationTop = Color("AccelerationTop", bundle: .main)
  static let accelerationBottom = Color("AccelerationBottom", bundle: .main)
  static let momentumTop = Color("MomentumTop", bundle: .main)
  static let momentumBottom = Color("MomentumBottom", bundle: .main)
  static let pipTop = Color("PiPTop", bundle: .main)
  static let pipBottom = Color("PiPBottom", bundle: .main)
}
