//
//  GradientView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 10/12/21.
//

import SwiftUI

// MARK: - GradientView

/// A simple top-to-bottom linear gradient. Kept as the load-bearing fill for the
/// per-demo shapes (it carries their visual identity).
struct GradientView: View {
  var topColor: Color
  var bottomColor: Color

  var body: some View {
    LinearGradient(
      colors: [topColor, bottomColor],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}

// MARK: - MeshBackgroundView

/// A subtle 4-corner `MeshGradient` used as the "fluid" background in place of a
/// flat black fill. iOS 18+ / macOS 15+ / visionOS 2+ / tvOS 18+.
struct MeshBackgroundView: View {
  var colors: [Color] = [
    Color(red: 0.05, green: 0.05, blue: 0.08),
    Color(red: 0.08, green: 0.06, blue: 0.12),
    Color(red: 0.04, green: 0.07, blue: 0.10),
    Color(red: 0.06, green: 0.05, blue: 0.09),
  ]

  var body: some View {
    MeshGradient(
      width: 2,
      height: 2,
      points: [[0, 0], [1, 0], [0, 1], [1, 1]],
      colors: colors
    )
  }
}

// MARK: - Previews

#Preview {
  GradientView(topColor: .red, bottomColor: .blue)
}

#Preview {
  MeshBackgroundView()
}
