//
//  ViewModifiers.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 5/28/21.
//

import SwiftUI

// MARK: - BackgroundViewModifier

/// A black background which ignores safe area.
struct FullScreenBlackBackgroundIgnoresSafeArea: ViewModifier {
  func body(content: Content) -> some View {
    content
    #if os(iOS)
      .frame(
        width: .fullScreenWidth,
        height: .fullScreenHeight,
        alignment: .center
      )
    #endif
    .background(Color.black)
      .ignoresSafeArea()
  }
}
