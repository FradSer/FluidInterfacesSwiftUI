//
//  ViewModifiers.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 5/28/21.
//

import SwiftUI

// MARK: - BackgroundViewModifier

/// A full-bleed black background that fills the available space on every platform.
///
/// The original pinned the frame to `UIScreen.main.bounds`, which is deprecated,
/// wrong in multi-window/multi-display setups, and meaningless on macOS, tvOS
/// and visionOS. Filling the offered space with `maxWidth`/`maxHeight` works
/// everywhere and respects the safe area only where it exists (iOS).
struct FullScreenBlackBackgroundIgnoresSafeArea: ViewModifier {
  func body(content: Content) -> some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.black)
      #if os(iOS)
        .ignoresSafeArea()
      #endif
  }
}
