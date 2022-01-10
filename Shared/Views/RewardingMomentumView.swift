//
//  RewardingMomentumView.swift
//  FluidInterfacesSwiftUI
//
//  Created by lixi on 6/2/21.
//

import SwiftUI

// MARK: - RewardingMomentumView

/// A drawer with open and closed states that has bounciness based on the velocity of the gesture.
///
/// # Key Features
///
/// 1. Tapping the drawer opens it without bounciness.
/// 2. Flicking the drawer opens it with bounciness.
/// 3. Interactive, interruptible, and reversible.
///
/// # Design Theory
///
/// This drawer shows the concept of rewarding momentum. When the user swipes a view with
/// velocity, it’s much more satisfying to animate the view with bounciness. This makes the interface
/// feel alive and fun.
///
/// When the drawer is tapped, it animates without bounciness, which feels appropriate, since a tap
/// has no momentum in a particular direction.
///
/// When designing custom interactions, it’s important to remember that interfaces can have
/// different animations for different interactions.
///
/// # References
///
/// - [Building Fluid Interfaces. How to create natural gestures and…](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
struct RewardingMomentumView: View {
  // MARK: Internal

  var body: some View {
    let tap = TapGesture()
      .onEnded {
        togglePositionY()
        withAnimation(.default) { self.currentPositionY = self.newPositionY }
      }
    let drag = DragGesture()
      .onChanged { value in
        withAnimation(.default) {
          self.currentPositionY =
            value.translation.height + self.newPositionY
        }
      }
      .onEnded { value in
        let offsetY = value.translation.height
        if offsetY > 100 { isActived = true } else { isActived = false }

        togglePositionY()
        withAnimation(.spring()) { self.currentPositionY = self.newPositionY }
      }

    ZStack {
      heroView
        .gesture(drag)
        .gesture(tap)

      debugView
    }
  }

  // MARK: Private

  @State private var isActived = false

  @State private var currentPositionY: CGFloat = .fullScreenHeight * 0.68
  @State private var newPositionY: CGFloat = .zero

  private func togglePositionY() {
    isActived.toggle()
    newPositionY = isActived ?
      .fullScreenHeight * 0.1 : .fullScreenHeight * 0.68
  }
}

extension RewardingMomentumView {
  private var heroView: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 32)
        .fill(
          LinearGradient(
            gradient: Gradient(colors: [.topColor, .bottomColor]),
            startPoint: .top,
            endPoint: .bottom
          )
        )
      VStack {
        RoundedRectangle(cornerRadius: 4)
          .frame(width: 64, height: 8, alignment: .center)
          .foregroundColor(.white.opacity(0.7))
          .padding()
        Spacer()
      }
    }
    .offset(y: currentPositionY)
  }

  private var debugView: some View {
    VStack {
      Spacer()
      HStack(spacing: 32) {
        Text("Current Position:").textCase(.uppercase)
        Spacer()
        FormatedNumView(num: $currentPositionY)
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.white.opacity(0.7))
      )
    }
    .offset(y: 16.0)
    .padding()
  }
}

private extension Color {
  static let topColor = Color(red: 0.38, green: 0.66, blue: 1.00)
  static let bottomColor = Color(red: 0.14, green: 0.23, blue: 0.82)
}

// MARK: - RewardingMomentumView_Previews

struct RewardingMomentumView_Previews: PreviewProvider {
  static var previews: some View {
    RewardingMomentumView()
  }
}
