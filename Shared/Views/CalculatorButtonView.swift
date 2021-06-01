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
/// # `Button` in `SwiftUI`
///
/// In `UIKit` you can use `touchDown`, `touchDragEnter` or some other useful
/// `[UIControl.Event](https://developer.apple.com/documentation/uikit/uicontrol/event )`,
/// in `SwiftUI` you needs to customize these gestures.
///
/// But very lucky, the default gesture of `Button` in `SwiftUI` looks match the features we want,
/// all we need is a customized `ButtonStyle`.
///
/// # References
///
/// - [Composing SwiftUI Gestures](https://developer.apple.com/documentation/swiftui/composing-swiftui-gestures)
/// - [Mastering buttons in SwiftUI](https://swiftwithmajid.com/2020/02/19/mastering-buttons-in-swiftui/)
/// - [Building Fluid Interfaces. How to create natural gestures and…](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
/// - [Designing Fluid Interfaces ](https://developer.apple.com/videos/play/wwdc2018/803/?time=3013)
/// - [How to set custom highlighted state of SwiftUI Button](https://stackoverflow.com/a/56980172/3413981 )
///
struct CalculatorButtonView: View {
  // MARK: Internal

  var body: some View {
    VStack(spacing: 32) {
      HeaderView(
        title: "Simultaneous",
        description: "同时进行手势，类似 Apple 的计算器 app。"
      )
      Button(action: {
        print("Button style 1 tapped.")
      }) {
        Text("9")
      }
      .buttonStyle(CalculatorButtonStyle1())
      Spacer().frame(height: 32)
      HeaderView(
        title: "Sequenced",
        description: "循序渐进手势，依次识别点击、长按、拖拽，仅供娱乐。"
      )
      Button(action: {
        print("Button style 2 tapped")
      }) {
        Text("9")
      }
      .buttonStyle(CalculatorButtonStyle2())
    }
    .padding()
    .fullScreenBlackBackgroundIgnoresSafeArea()
  }

  // MARK: Private

  private struct HeaderView: View {
    @State var title: String
    @State var description: String

    var body: some View {
      VStack(alignment: .leading, spacing: 8.0) {
        HStack {
          Text(title)
            .font(.title)
            .textCase(.uppercase)
          Spacer()
        }
        Text(description)
      }
      .foregroundColor(.white)
    }
  }
}

// MARK: - CalculatorButtonStyle1

struct CalculatorButtonStyle1: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .foregroundColor(.white)
      .font(.largeTitle)
      .padding(32)
      .background(
        Circle()
          .foregroundColor(configuration.isPressed ?
            .highlightedButtonColor : .normalButtonColor)
          .animation(configuration.isPressed ?
            nil : .easeOut(duration: 0.5))
      )
      .cornerRadius(8.0)
  }
}

// MARK: - CalculatorButtonStyle2

/// `PrimitiveButtonStyle` protocol that looks very similar to `ButtonStyle` but provides all
/// the needed API to build a super custom button.
///
/// Read [this link](https://swiftwithmajid.com/2020/02/19/mastering-buttons-in-swiftui/ )
/// for more.
/// - Attention: When `PrimitiveButtonStyle` used in `buttonStyle(_:)`, all the defualt
/// `Button` styles will be **ignored**.
struct CalculatorButtonStyle2: PrimitiveButtonStyle {
  /// Model sequenced gesture states.
  enum DragState {
    case inactive
    case pressing
    case dragging(translation: CGSize)

    // MARK: Internal

    var translation: CGSize {
      switch self {
      case .inactive, .pressing:
        return .zero
      case let .dragging(translation):
        return translation
      }
    }

    var isActive: Bool {
      switch self {
      case .inactive:
        return false
      case .dragging, .pressing:
        return true
      }
    }

    var isDragging: Bool {
      switch self {
      case .inactive, .pressing:
        return false
      case .dragging:
        return true
      }
    }
  }

  @GestureState var dragState = DragState.inactive
  @State var viewState = CGSize.zero

  func makeBody(configuration: Configuration) -> some View {
    let minimumLongPressDuration = 0.5
    let longPressDrag =
      LongPressGesture(minimumDuration: minimumLongPressDuration)
        .sequenced(before: DragGesture())
        .updating($dragState) { value, state, _ in
          switch value {
          // Long press begins.
          case .first(true):
            state = .pressing
          // Long press confirmed, dragging may begin.
          case .second(true, let drag):
            state = .dragging(translation: drag?.translation ?? .zero)
          // Dragging ended or the long press cancelled.
          default:
            state = .inactive
          }
        }
        .onEnded { value in
          guard case .second(true, let drag?) = value else { return }
          self.viewState.width += drag.translation.width
          self.viewState.height += drag.translation.height
        }

    configuration.label
      .foregroundColor(.white)
      .font(.largeTitle)
      .padding(32)
      .background(
        GeometryReader { _ in
          Circle()
            .foregroundColor(dragState.isActive ?
              .highlightedButtonColor : .normalButtonColor)
            .animation(dragState.isActive ?
              nil : .easeOut(duration: minimumLongPressDuration))
            .overlay(dragState.isDragging ? Circle()
              .stroke(Color.white, lineWidth: 2) : nil)
        }
      )
      .offset(
        x: viewState.width + dragState.translation.width,
        y: viewState.height + dragState.translation.height
      )
      .animation(.default)
      .gesture(longPressDrag)
  }
}

// MARK: - CalculatorButtonView_Previews

struct CalculatorButtonView_Previews: PreviewProvider {
  static var previews: some View {
    CalculatorButtonView()
      .fullScreenBlackBackgroundIgnoresSafeArea()
  }
}
