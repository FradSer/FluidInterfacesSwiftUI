//
//  FlashlightButtonView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 5/31/21.
//

import SwiftUI

// MARK: - FlashlightButtonView

/// An iOS-like flashlight button.
///
/// # Key Features
///
/// 1. Requires an intentional long-press gesture to activate.
/// 2. A repeating bounce hints at the required gesture.
/// 3. Two-stage haptic feedback confirms activation (threshold + toggle).
///
/// # Design Theory
///
/// Apple wanted a button that was quickly accessible but couldn't be triggered
/// accidentally. Requiring a long press solves the first part but lacks
/// affordance and feedback. The bounce hint and the two haptics (one as the
/// threshold is crossed, one on activation) mimic a physical button.
///
/// # iOS 26 Approach
///
/// The original composed `LongPressGesture.sequenced(before: DragGesture)` to
/// read the release moment — but `LongPressGesture.onEnded` already fires on
/// release, so the drag sequel is dropped. The idle hint uses a repeating SF
/// Symbol bounce. Haptics use `.sensoryFeedback`. Styling uses native Liquid
/// Glass with a yellow tint when on.
///
/// # References
///
/// - [Building Fluid Interfaces](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
/// - [Composing SwiftUI Gestures](https://developer.apple.com/documentation/swiftui/composing-swiftui-gestures)

struct FlashlightButtonView: View {
  @State private var isOn = false
  @State private var hintTrigger = 0

  private let activationDuration: Double = 0.5

  var body: some View {
    button
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(MeshBackgroundView())
      #if os(iOS)
        .ignoresSafeArea()
      #endif
  }

  #if !os(tvOS)
    private var button: some View {
      Image(systemName: isOn ? "flashlight.on.fill" : "flashlight.off.fill")
        .font(.largeTitle)
        .frame(width: 96, height: 96)
        .foregroundStyle(isOn ? .black : .white)
        .background(
          Circle()
            .fill(isOn ? Color.yellow : Color.buttonBackground)
        )
        .glassEffect(
          isOn ? .regular.tint(.yellow) : .regular,
          in: .circle
        )
        .symbolEffect(
          .bounce,
          options: .repeat(.continuous),
          value: hintTrigger
        )
        .gesture(
          LongPressGesture(minimumDuration: activationDuration)
            .onEnded { _ in
              isOn.toggle()
              hintTrigger &+= 1
            }
        )
        .sensoryFeedback(.selection, trigger: hintTrigger)
        .sensoryFeedback(.impact(weight: .medium), trigger: isOn)
    }
  #else
    // tvOS Siri Remote has no long-press gesture or haptics; expose a plain toggle.
    private var button: some View {
      Button { isOn.toggle() } label: {
        Image(systemName: isOn ? "flashlight.on.fill" : "flashlight.off.fill")
          .font(.largeTitle)
          .frame(width: 96, height: 96)
          .foregroundStyle(isOn ? .black : .white)
          .background(Circle().fill(isOn ? Color.yellow : Color.buttonBackground))
      }
    }
  #endif
}

// MARK: - Previews

#Preview {
  FlashlightButtonView()
}
