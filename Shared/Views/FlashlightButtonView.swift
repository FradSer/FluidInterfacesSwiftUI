//
//  FlashlightButtonView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 5/31/21.
//

import SwiftUI

// MARK: - FlashlightButtonView

/// A iOS like flashlight button.
///
/// # Key Features
///
/// 1. Requires an intentional gesture with `LongPressGesture`, [see more](https://developer.apple.com/documentation/swiftui/longpressgesture ).
/// 2. Bounciness hints at the required gesture.
/// 3. Haptic feedback confirms activation.
///
/// # Design Theory
///
/// Apple wanted to create a button that was easily and quickly accessible, but couldn’t be triggered
/// accidentally. Requiring long press to activate the flashlight is a great choice, but lacks
/// affordance and feedback.
///
/// In order to solve those problems, the button is springy and grows as the user applies force,
/// hinting at the required gesture. In addition, there are two separate vibrations of haptic feedback:
/// one when the required amount of force is applied, and another when the button activates as the
/// force is reduced. These haptics mimic the behavior of a physical button.
///
/// - Note:
/// The [origin version](https://github.com/nathangitter/fluid-interfaces/blob/master/FluidInterfaces/FluidInterfaces/FlashlightButton.swift)
/// calls [3D Touch](https://developer.apple.com/design/human-interface-guidelines/ios/user-interaction/3d-touch/)
/// which has been deprecated, in this version it will replaced by `LongPressGesture` and
/// `DragGesture`.
///
/// # References
///
/// - [Building Fluid Interfaces. How to create natural gestures and…](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
/// - [Composing SwiftUI Gestures](https://developer.apple.com/documentation/swiftui/composing-swiftui-gestures)

struct FlashlightButtonView: View {
  // MARK: Internal

  var body: some View {
    let minimumLongPressDuration = 0.5
    let longPress =
      LongPressGesture(
        minimumDuration: minimumLongPressDuration
      )
      .sequenced(
        before: DragGesture(minimumDistance: 0)
      )
      .updating($pressState) { value, state, _ in
        switch value {
        case .first:
          state = .activated
        case .second:
          state = .confirmed
        }
      }
      .onEnded { value in
        guard case .second = value else { return }
        self.viewState.toggle()
      }

    Image(systemName:
      stateConfirmed(
        "flashlight.on.fill",
        "flashlight.off.fill"
      ) as! String)
      .foregroundColor(stateConfirmed(Color.black, Color.white) as? Color)
      .animation(nil)
      .font(.largeTitle)
      .padding(32)
      .background(
        Circle()
          .foregroundColor(
            stateConfirmed(
              Color.highlightedButtonColor,
              Color.normalButtonColor
            ) as? Color
          )
          .animation(nil)
      )
      .scaleEffect(pressState.isPressing ? 1.2 : 1)
      .animation(.spring(response: 0.2, dampingFraction: 0.4))
      .gesture(longPress)
  }

  // MARK: Private

  private enum PressState {
    /// **Default state**.
    /// The button is ready to be activiated.
    case reset
    /// The button with enough duration long pressing.
    case activated
    /// The button has recently switched on/off.
    case confirmed

    // MARK: Internal

    var isPressing: Bool {
      switch self {
      case .activated, .confirmed:
        return true
      case .reset:
        return false
      }
    }

    var isConfirmed: Bool {
      switch self {
      case .activated, .reset:
        return false
      case .confirmed:
        return true
      }
    }
  }

  @GestureState private var pressState = PressState.reset
  @State var viewState: Bool = false

  /// Controlled by both `viewState` and `pressState.isConfirmed` .
  /// - Important: For `FlashlightButtonView` **ONLY**.
  /// - Parameters:
  ///   - activedItem: Actived item.
  ///   - inactivedItem: Inactived item.
  /// - Returns: `Any`.
  private func stateConfirmed(
    _ activedItem: Any,
    _ inactivedItem: Any
  ) -> Any {
    return viewState ?
      pressState.isConfirmed ?
      activedItem : inactivedItem :
      pressState.isConfirmed ?
      inactivedItem : activedItem
  }
}

// MARK: - FlashlightButtonView_Previews

struct FlashlightButtonView_Previews: PreviewProvider {
  static var previews: some View {
    FlashlightButtonView()
  }
}
