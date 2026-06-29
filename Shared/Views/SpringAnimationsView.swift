//
//  SpringAnimationsView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 5/31/21.
//

import SwiftUI

// MARK: - SpringAnimationsView

/// A simple spring animation demo.
///
/// # Key Features
///
/// 1. Uses a SwiftUI `Spring` value (no duration concept).
/// 2. Easily interruptible — velocity is preserved across interruptions.
/// 3. Live sliders re-tune the spring in flight.
///
/// # Design Theory
///
/// Springs make great animation models because of their speed and natural
/// appearance. A spring animation starts incredibly quickly, spending most of
/// its time gradually approaching its final state — perfect for interfaces that
/// feel responsive. They spring to life!
///
/// # iOS 26 Approach
///
/// The original faked a continuous loop with `repeatForever` on an offset and
/// rebuilt the view (`viewID` bump) whenever a slider moved. A `phaseAnimator`
/// replaces that: it cycles phases on its own, and its `animation` closure is
/// re-evaluated as `response`/`dampingFraction` change, so the spring is
/// re-tuned live with no view recreation.
///
/// # References
///
/// - [Building Fluid Interfaces](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
/// - [Spring Animation / What does the blendDuration parameter do?](https://stackoverflow.com/a/59170144)

struct SpringAnimationsView: View {
  @State private var response = 0.55
  @State private var dampingFraction = 0.825

  private var spring: Spring {
    Spring(response: response, dampingRatio: dampingFraction)
  }

  var body: some View {
    VStack(spacing: 64) {
      // The phaseAnimator lives in this view's hierarchy so its `animation`
      // closure reads `spring` from `@State` directly — each phase transition
      // re-evaluates the closure, re-tuning the spring live as the sliders move.
      // The shape animates inside a fixed, layout-neutral box (GeometryReader
      // sized once, overlay for the offset content) so the spring's horizontal
      // offset never feeds back into the surrounding/window layout — that
      // feedback previously stalled the animation and recursed AppKit's
      // Update Constraints pass.
      GeometryReader { proxy in
        Color.clear
          .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
              .fill(
                LinearGradient(
                  colors: [.springTop, .springBottom],
                  startPoint: .top,
                  endPoint: .bottom
                )
              )
              .frame(width: 120, height: 120)
              .phaseAnimator([false, true]) { content, phase in
                content.offset(x: phase ? proxy.size.width / 2 - 60 : -proxy.size.width / 2 + 60)
              } animation: { _ in
                .spring(spring)
              }
          }
      }
      .frame(height: 120)

      VStack(spacing: 24) {
        SliderRow(title: "Response (Speed)", value: $response)
        SliderRow(title: "Damping Fraction", value: $dampingFraction)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(MeshBackgroundView())
    #if os(iOS)
      .ignoresSafeArea()
    #endif
  }

  // MARK: Private

  private struct SliderRow: View {
    var title: String
    @Binding var value: Double

    var body: some View {
      VStack(spacing: 6) {
        HStack {
          Text(title).textCase(.uppercase)
          Spacer()
          Text("\(value, specifier: "%.2f")")
            .font(.system(.body).monospacedDigit())
            .contentTransition(.numericText(value: value))
            .animation(.smooth, value: value)
        }
        Slider(value: $value, in: 0.05...1.0)
      }
    }
  }
}

// MARK: - Previews

#Preview {
  SpringAnimationsView()
}
