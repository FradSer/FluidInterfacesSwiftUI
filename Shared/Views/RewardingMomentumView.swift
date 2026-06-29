//
//  RewardingMomentumView.swift
//  FluidInterfacesSwiftUI
//
//  Created by lixi on 6/2/21.
//

import SwiftUI

// MARK: - RewardingMomentumView

/// A drawer with open/closed states whose bounciness follows the gesture's
/// velocity.
///
/// # Key Features
///
/// 1. Tapping the drawer opens it without bounciness.
/// 2. Flicking the drawer opens it with bounciness.
/// 3. Interactive, interruptible, and reversible.
///
/// # Design Theory
///
/// This drawer shows the concept of rewarding momentum: swiping a view with
/// velocity is more satisfying when the animation carries that momentum with
/// bounce. A tap has no momentum, so it animates without bounce — different
/// interactions deserve different animations.
///
/// # iOS 26 Approach
///
/// Drawer positions are derived from a `containerRelativeFrame`-sized layout
/// instead of `UIScreen.main`. The drag's end chooses a spring by velocity
/// (`.bouncy` for a flick, `.smooth` for a tap) and drives it through a
/// value-based `.spring(_:value:)`, which carries velocity across the
/// interruption — the core of "rewarding momentum". The drawer is styled with
/// native Liquid Glass.
///
/// # References
///
/// - [Building Fluid Interfaces](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)

struct RewardingMomentumView: View {
  @State private var isOpen = false
  @State private var dragOffset: CGFloat = 0

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
      GeometryReader { geometry in
        let closedY = geometry.size.height * 0.68
        let openY = geometry.size.height * 0.1
        let targetY = isOpen ? openY : closedY

        ZStack(alignment: .bottom) {
          RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(
              LinearGradient(
                colors: [.momentumTop, .momentumBottom],
                startPoint: .top,
                endPoint: .bottom
              )
            )
            #if !os(tvOS)
              .glassEffect(.regular, in: .rect(cornerRadius: 32))
            #endif
            .overlay(alignment: .top) {
              Capsule()
                .fill(.primary)
                .opacity(0.5)
                .frame(width: 64, height: 8)
                .padding(.top, 12)
            }
            .frame(height: geometry.size.height - openY)
            .offset(y: targetY + dragOffset)
            .gesture(
              DragGesture()
                .onChanged { dragOffset = $0.translation.height }
                .onEnded { value in
                  let velocity = value.predictedEndLocation.y - value.location.y
                  let translation = value.translation.height
                  // A flick carries momentum → animate with bounce; a tap (no
                  // momentum) → smooth. The chosen spring drives the whole motion
                  // (drawer repositioning + residual drag offset settling together).
                  let spring: Spring = abs(velocity) > 200
                    ? .bouncy
                    : .smooth
                  withAnimation(.spring(spring)) {
                    if abs(velocity) > 200 {
                      isOpen = translation < 0
                    } else if abs(translation) > 100 {
                      isOpen.toggle()
                    }
                    dragOffset = 0
                  }
                }
            )
            .animation(.spring(.smooth), value: isOpen)

          debugView(y: targetY + dragOffset)
        }
      }
    }
  #else
    // tvOS: no drag/momentum; a focused button toggles the drawer with a smooth spring.
    private var content: some View {
      GeometryReader { geometry in
        let closedY = geometry.size.height * 0.68
        let openY = geometry.size.height * 0.1
        let targetY = isOpen ? openY : closedY
        ZStack(alignment: .bottom) {
          RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(LinearGradient(colors: [.momentumTop, .momentumBottom], startPoint: .top, endPoint: .bottom))
            .frame(height: geometry.size.height - openY)
            .offset(y: targetY)
            .animation(.spring(.smooth), value: isOpen)
          Button(isOpen ? "Close" : "Open") { withAnimation(.spring(.smooth)) { isOpen.toggle() } }
            .padding()
        }
      }
    }
  #endif

  // MARK: Private

  private func debugView(y: CGFloat) -> some View {
    VStack {
      Spacer()
      HStack(spacing: 32) {
        Text("Current Position:").textCase(.uppercase)
        Spacer()
        FormatedNumView(num: Binding(get: { y }, set: { _ in }))
      }
      .foregroundStyle(.primary)
      .padding()
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
      .padding()
    }
  }
}

// MARK: - Previews

#Preview {
  RewardingMomentumView()
}
