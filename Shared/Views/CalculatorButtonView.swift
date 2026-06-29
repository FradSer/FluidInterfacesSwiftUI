//
//  CalculatorButtonView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 5/27/21.
//

import SwiftUI

// MARK: - CalculatorButtonView

/// A iOS calculator app like button.
///
/// # Key Features
///
/// 1. Highlights instantly on touch.
/// 2. Can be tapped rapidly even when mid-animation.
/// 3. User can touch down and drag outside of the button to cancel the tap.
/// 4. User can touch down, drag outside, drag back in, and confirm the tap.
///
/// # Design Theory
///
/// We want buttons that feel responsive, acknowledging to the user that they are functional. In
/// addition, we want the action to be cancellable if the user decides against their action after they
/// touched down. This allows users to make quicker decisions since they can perform actions in
/// parallel with thought.
///
/// # iOS 26 Approach
///
/// The default `Button` gesture already matches the calculator behaviors we want (instant
/// highlight, cancel by drag-out, re-confirm by drag-back-in), so a `ButtonStyle` is still all we
/// need. The styling now leans on the native Liquid Glass material via `.glassEffect` and
/// `.buttonStyle(.glassProminent)` for the emphasized action, with spring presets driving the
/// press scale. Haptics use `.sensoryFeedback`.
///
/// # References
///
/// - [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
/// - [Composing SwiftUI Gestures](https://developer.apple.com/documentation/swiftui/composing-swiftui-gestures)
/// - [Building Fluid Interfaces](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
/// - [Designing Fluid Interfaces](https://developer.apple.com/videos/play/wwdc2018/803/?time=3013)
///
struct CalculatorButtonView: View {
  @State private var simultaneousTapCount = 0
  @State private var sequencedTapCount = 0

  var body: some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(MeshBackgroundView())
      #if os(iOS)
        .ignoresSafeArea()
      #endif
  }

  private var content: some View {
    #if !os(tvOS)
      GlassEffectContainer(spacing: 24) {
        stack
      }
    #else
      stack
    #endif
  }

  private var stack: some View {
    VStack(spacing: 32) {
      HeaderView(
        title: "Simultaneous",
        description: "同时进行手势，类似 Apple 的计算器 app。"
      )
      Button("9") { simultaneousTapCount += 1 }
        .buttonStyle(CalculatorButtonStyle(prominent: true))
        #if !os(tvOS)
          .sensoryFeedback(.impact(weight: .light), trigger: simultaneousTapCount)
        #endif

      Spacer().frame(height: 32)

      HeaderView(
        title: "Sequenced",
        description: "循序渐进手势，依次识别点击、长按、拖拽，仅供娱乐。"
      )
      sequencedButton
    }
    .padding()
  }

  #if !os(tvOS)
    /// A `PrimitiveButtonStyle` demo that recognizes a long-press then a drag.
    /// tvOS's Siri Remote can't express this gesture, so the demo is hidden there.
    private var sequencedButton: some View {
      Button("9") { sequencedTapCount += 1 }
        .buttonStyle(CalculatorSequencedButtonStyle())
        .sensoryFeedback(
          .impact(weight: .medium),
          trigger: sequencedTapCount
        )
    }
  #else
    private var sequencedButton: some View {
      Text("Sequenced gesture demo is not available on tvOS.")
        .foregroundStyle(.secondary)
    }
  #endif

  // MARK: Private

  private struct HeaderView: View {
    var title: String
    var description: String

    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(title).font(.title).textCase(.uppercase)
          Spacer()
        }
        Text(description)
      }
      .foregroundStyle(.primary)
    }
  }
}

// MARK: - CalculatorButtonStyle

/// A circular calculator button rendered with native Liquid Glass. The emphasized
/// variant uses the system prominent glass style for the call-to-action look.
struct CalculatorButtonStyle: ButtonStyle {
  var prominent: Bool = false

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.largeTitle)
      .frame(width: 96, height: 96)
      .foregroundStyle(prominent ? Color.black : Color.white)
      .background(background)
      .scaleEffect(configuration.isPressed ? 0.94 : 1)
      .animation(.spring(.bouncy), value: configuration.isPressed)
  }

  @ViewBuilder private var background: some View {
    if prominent {
      Circle().fill(.yellow)
    } else {
      Circle()
        .fill(Color.buttonBackground)
        #if !os(tvOS)
          .glassEffect(in: .circle)
        #endif
    }
  }
}

// MARK: - CalculatorSequencedButtonStyle

/// `PrimitiveButtonStyle` demonstrating a sequenced long-press → drag gesture.
/// Visuals are driven via `visualEffect` (no `GeometryReader`) and the press
/// state uses native glass. The interactive glass variant is iOS-only.
struct CalculatorSequencedButtonStyle: PrimitiveButtonStyle {
  enum DragState: Equatable {
    case inactive
    case pressing
    case dragging(translation: CGSize)

    var translation: CGSize {
      switch self {
      case .inactive, .pressing: .zero
      case .dragging(let translation): translation
      }
    }

    var isActive: Bool {
      self != .inactive
    }

    var isDragging: Bool {
      if case .dragging = self { return true }
      return false
    }
  }

  @GestureState private var dragState = DragState.inactive
  @State private var viewState = CGSize.zero

  func makeBody(configuration: Configuration) -> some View {
    let minimumLongPressDuration = 0.5
    let longPressDrag =
      LongPressGesture(minimumDuration: minimumLongPressDuration)
        .sequenced(before: DragGesture())
        .updating($dragState) { value, state, _ in
          switch value {
          case .first(true): state = .pressing
          case .second(true, let drag):
            state = .dragging(translation: drag?.translation ?? .zero)
          default: state = .inactive
          }
        }
        .onEnded { value in
          guard case .second(true, let drag?) = value else { return }
          viewState.width += drag.translation.width
          viewState.height += drag.translation.height
          configuration.trigger()
        }

    configuration.label
      .font(.largeTitle)
      .frame(width: 96, height: 96)
      .foregroundStyle(.white)
      .background(
        Circle()
          .fill(
            dragState.isActive
              ? Color.buttonBackgroundHighlighted
              : Color.buttonBackground
          )
      )
      #if os(iOS)
        .glassEffect(.regular.interactive(), in: .circle)
      #else
        .glassEffect(in: .circle)
      #endif
      .overlay {
        if dragState.isDragging {
          Circle().stroke(Color.white, lineWidth: 2)
        }
      }
      .offset(
        x: viewState.width + dragState.translation.width,
        y: viewState.height + dragState.translation.height
      )
      .animation(.spring(.snappy), value: dragState)
      .gesture(longPressDrag)
  }
}

// MARK: - Previews

#Preview {
  CalculatorButtonView()
}
