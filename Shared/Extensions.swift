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

// Semantic color tokens (`Color.buttonBackground`, etc.) are now provided by the
// asset catalog's generated Swift symbol extensions
// (ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES), which
// also expose `NSColor`/`ShapeStyle` variants and stay in sync with the catalog.
