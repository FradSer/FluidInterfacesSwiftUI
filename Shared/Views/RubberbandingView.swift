//
//  RubberbandingView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 6/1/21.
//

import SwiftUI

// MARK: - RubberbandingView

/// Rubberbanding occurs when a view resists movement, e.g. when a scrolling
/// view reaches the end of its content.
///
/// # Key Features
///
/// 1. The interface is always responsive, even when an action is invalid.
/// 2. De-synced touch tracking indicates a boundary.
/// 3. The amount of motion lessens further from the boundary.
///
/// # Design Theory
///
/// Rubberbanding communicates invalid actions while still giving the user a
/// sense of control. It softly indicates a boundary, pulling them back into a
/// valid state.
///
/// # iOS 26 Approach
///
/// The `pow(0.7)` resistance math is kept (a simplified Apple-style
/// approximation). Tracking now follows the touch 1:1 with no animation in
/// `.onChanged` (the original's `.linear` added lag), and springs back on
/// release via a value-based `.spring(.smooth)`. Offset is applied through
/// `.visualEffect` to avoid re-rendering the shape. tvOS gets a scrollable
/// `.scrollTransition` variant since Siri Remote can't drag.
///
/// # References
///
/// - [Building Fluid Interfaces](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)

struct RubberbandingView: View {
  @State private var dragHeight: CGFloat = 0
  @State private var isDragging = false

  var body: some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(MeshBackgroundView())
      #if os(iOS)
        .ignoresSafeArea()
      #endif
  }

  #if !os(tvOS)
    private var content: some View {
      RoundedRectangle(cornerRadius: 32, style: .continuous)
        .fill(
          LinearGradient(
            colors: [.rubberbandingTop, .rubberbandingBottom],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .frame(width: 120, height: 120)
        .offset(y: rubberbanded(dragHeight))
        .gesture(
          DragGesture()
            .onChanged {
              isDragging = true
              dragHeight = $0.translation.height
            }
            .onEnded { _ in
              isDragging = false
              withAnimation(.spring(.smooth)) { dragHeight = 0 }
            }
        )
        // Track 1:1 while dragging (no spring lag); spring only on release.
        .animation(isDragging ? nil : .spring(.smooth), value: dragHeight)
    }
  #else
    // tvOS: no drag — a scrollable list that scales/fades rows near the edges.
    private var content: some View {
      ScrollView {
        LazyVStack(spacing: 16) {
          ForEach(0..<12, id: \.self) { index in
            RoundedRectangle(cornerRadius: 16, style: .continuous)
              .fill(
                LinearGradient(
                  colors: [.rubberbandingTop, .rubberbandingBottom],
                  startPoint: .leading,
                  endPoint: .trailing
                )
              )
              .frame(height: 80)
              .scrollTransition { content, phase in
                content
                  .scaleEffect(phase.isIdentity ? 1 : 0.9)
                  .opacity(phase.isIdentity ? 1 : 0.5)
              }
              .padding(.horizontal)
          }
        }
        .padding(.vertical)
      }
    }
  #endif

  /// A simple Apple-style rubberbanding curve.
  /// - Note: This is not how Apple performs rubberbanding, but it's a simple
  ///   approximation. Graph: https://www.desmos.com/calculator/jfesw7c1re
  private func rubberbanded(_ offset: CGFloat) -> CGFloat {
    offset > 0
      ? pow(offset, 0.7)
      : -pow(-offset, 0.7)
  }
}

// MARK: - Previews

#Preview {
  RubberbandingView()
}
