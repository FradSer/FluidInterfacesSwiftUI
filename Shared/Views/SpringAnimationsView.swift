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
/// 1. Uses“design-friendly”parameters.
/// 2. Noconceptofanimationduration.
/// 3. Easilyinterruptible.
///
/// # Design Theory
///
/// Springs make great animation models because of their speed and natural appearance. A spring
/// animation starts incredibly quickly, spending most of its time gradually approaching its final state.
/// This is perfect for creating interfaces that feel responsive—they spring to life!
///
/// # References
///
/// - [Building Fluid Interfaces. How to create natural gestures and…](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
/// - [SOLVED/ Instantly reset state of animation. ](https://www.hackingwithswift.com/forums/swiftui/instantly-reset-state-of-animation/4494 )

struct SpringAnimationsView: View {
  // MARK: Internal

  var body: some View {
    VStack(spacing: 128) {
      ResetRoundedRectangle(
        response: $response,
        dampingFraction: $dampingFraction,
        blendDuration: $blendDuration
      )
      .id(viewID)

      VStack {
        HeaderView(title: "Response (Speed)", number: $response)
        Slider(
          value: $response,
          in: 0 ... 1.0,
          onEditingChanged: { _ in
            sliderChanged()
          }
        )
        HeaderView(title: "Damping Fraction", number: $dampingFraction)
        Slider(
          value: $dampingFraction,
          in: 0 ... 1.0,
          onEditingChanged: { _ in
            sliderChanged()
          }
        )
        HeaderView(title: "Blend Duratio", number: $blendDuration)
        Slider(
          value: $blendDuration,
          in: 0 ... 5.0,
          onEditingChanged: { _ in
            sliderChanged()
          }
        )
      }
    }
    .padding()
    .fullScreenBlackBackgroundIgnoresSafeArea()
  }

  // MARK: Private

  private struct HeaderView: View {
    @State var title: String
    @Binding var number: Double

    var body: some View {
      HStack {
        Text(title)
          .textCase(.uppercase)
        Spacer()
        Text("\(number, specifier: "%.2f")")
          .font(.system(.body).monospacedDigit())
      }
      .foregroundColor(.white)
    }
  }

  @State private var isAnimated: Bool = false

  @State private var response: Double = 0.55
  @State private var dampingFraction: Double = 0.825
  @State private var blendDuration: Double = 0.0

  @State private var viewID = 0

  private func sliderChanged() {
    viewID += 1
  }
}

// MARK: - ResetRoundedRectangle

private struct ResetRoundedRectangle: View {
  // MARK: Internal

  @Binding var response: Double
  @Binding var dampingFraction: Double
  @Binding var blendDuration: Double

  var body: some View {
    let offset = CGFloat.fullScreenWidth * 0.62 / 2.0
    RoundedRectangle(cornerRadius: 32.0)
      .fill(
        LinearGradient(
          gradient: Gradient(colors: [.topColor, .bottomColor]),
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .frame(width: 120, height: 120, alignment: .center)
      .offset(x: isAnimated ? offset : -offset)
      .onAppear {
        withAnimation(Animation.spring(
          response: response,
          dampingFraction: dampingFraction,
          blendDuration: blendDuration
        )
        .repeatForever(autoreverses: false)) {
          isAnimated = true
        }
      }
  }

  // MARK: Private

  @State private var isAnimated: Bool = false
}

/// Colors of rounded rectangle.
private extension Color {
  static let topColor = Color(red: 0.39, green: 0.80, blue: 0.97)
  static let bottomColor = Color(red: 0.21, green: 0.62, blue: 0.93)
}

// MARK: - SpringAnimationsView_Previews

struct SpringAnimationsView_Previews: PreviewProvider {
  static var previews: some View {
    SpringAnimationsView()
  }
}
