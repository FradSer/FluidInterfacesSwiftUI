//
//  FaceTimePiPView.swift
//  FluidInterfacesSwiftUI
//
//  Created by Frad LEE on 6/3/21.
//

import SwiftUI

// MARK: - FaceTimePiPView

/// A re-creation of the picture-in-picture UI of the iOS FaceTime app.
///
/// # Key Features
///
/// 1. Light, airy interaction.
/// 2. Continuous animation that respects the gesture's initial velocity.
///
/// # Design Theory
///
/// When the user swipes a view with velocity, animating it with bounciness makes
/// the interface feel alive and fun. Different interactions deserve different
/// animations.
///
/// # iOS 26 Approach
///
/// The original computed the target corner by hand (`findRoundedRectanglePosition`)
/// and animated with `interpolatingSpring` plus a broken `sqrt` velocity
/// normalization. That's replaced by a single floating card whose `.position`
/// snaps to the nearest corner on release, animated with a
/// `.spring(Spring(...))`. The landing corner is predicted from the card's
/// current rendered position plus the gesture's `predictedEndLocation` delta,
/// so a flick toward a corner snaps there even when the card started mid-screen.
/// Styling uses native Liquid Glass. This supersedes the original PreferenceKey
/// TODO.
///
/// # References
///
/// - [Building Fluid Interfaces](https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5)
/// - [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)

struct FaceTimePiPView: View {
  @State private var activeCorner: PiPCorner = .topLeading
  @State private var dragTranslation: CGSize = .zero
  @State private var lastVelocity: CGFloat = 0

  private let cardSize = CGSize(width: 120, height: 180)

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
        ZStack {
          ForEach(PiPCorner.allCases) { corner in
            RoundedRectangle(cornerRadius: 8, style: .continuous)
              .stroke(Color.gray.opacity(0.5), lineWidth: 2)
              .frame(width: cardSize.width, height: cardSize.height)
              .position(position(for: corner, in: geometry))
          }

          card
            .frame(width: cardSize.width, height: cardSize.height)
            .position(
              x: position(for: activeCorner, in: geometry).x + dragTranslation.width,
              y: position(for: activeCorner, in: geometry).y + dragTranslation.height
            )
            .gesture(
              DragGesture()
                .onChanged { dragTranslation = $0.translation }
                .onEnded { value in
                  let predicted = value.predictedEndLocation
                  let predictedDelta = CGSize(
                    width: predicted.x - value.location.x,
                    height: predicted.y - value.location.y
                  )
                  lastVelocity = hypot(predictedDelta.width, predictedDelta.height)
                  // Predict the landing point from the card's *current* rendered
                  // position (anchor + live drag), then add the gesture's predicted
                  // remaining delta — so a flick toward a corner snaps there even
                  // when the card started mid-screen.
                  let current = position(for: activeCorner, in: geometry)
                  let target = nearestCorner(
                    to: CGPoint(
                      x: current.x + dragTranslation.width + predictedDelta.width,
                      y: current.y + dragTranslation.height + predictedDelta.height
                    ),
                    in: geometry
                  )
                  dragTranslation = .zero
                  withAnimation(.spring(Spring(response: 0.4, dampingRatio: 0.7))) {
                    activeCorner = target
                  }
                }
            )
        }
        .overlay(alignment: .bottom) {
          debugView
        }
      }
      .padding()
    }
  #else
    // tvOS: focus-driven buttons move the card between corners (animated spring).
    private var content: some View {
      GeometryReader { geometry in
        ZStack {
          card
            .frame(width: cardSize.width, height: cardSize.height)
            .position(position(for: activeCorner, in: geometry))
            .animation(.spring(.bouncy), value: activeCorner)
          HStack {
            ForEach(PiPCorner.allCases) { corner in
              Button(corner.title) {
                withAnimation(.spring(.bouncy)) { activeCorner = corner }
              }
            }
          }
          .frame(maxHeight: .infinity, alignment: .bottom)
          .padding()
        }
      }
    }
  #endif

  // MARK: Private

  private var card: some View {
    RoundedRectangle(cornerRadius: 8, style: .continuous)
      .fill(
        LinearGradient(
          colors: [.piPTop, .piPBottom],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      #if !os(tvOS)
        .glassEffect(.regular, in: .rect(cornerRadius: 8))
      #endif
  }

  private var debugView: some View {
    VStack(alignment: .center, spacing: 8) {
      Text("Last Velocity").textCase(.uppercase)
      FormatedNumView(num: Binding(get: { lastVelocity }, set: { _ in }))
      Text("Active Corner").textCase(.uppercase)
      Text(activeCorner.title).font(.system(.body).monospacedDigit().bold())
    }
    .foregroundStyle(.primary)
    .padding()
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
  }

  private func position(for corner: PiPCorner, in geometry: GeometryProxy) -> CGPoint {
    let insets: CGFloat = 16 + 8
    let halfW = cardSize.width / 2
    let halfH = cardSize.height / 2
    switch corner {
    case .topLeading:
      return CGPoint(x: insets + halfW, y: insets + halfH)
    case .topTrailing:
      return CGPoint(x: geometry.size.width - insets - halfW, y: insets + halfH)
    case .bottomLeading:
      return CGPoint(x: insets + halfW, y: geometry.size.height - insets - halfH)
    case .bottomTrailing:
      return CGPoint(x: geometry.size.width - insets - halfW, y: geometry.size.height - insets - halfH)
    }
  }

  private func nearestCorner(to point: CGPoint, in geometry: GeometryProxy) -> PiPCorner {
    let midX = geometry.size.width / 2
    let midY = geometry.size.height / 2
    let leading = point.x < midX
    let top = point.y < midY
    switch (leading, top) {
    case (true, true): return .topLeading
    case (false, true): return .topTrailing
    case (true, false): return .bottomLeading
    case (false, false): return .bottomTrailing
    }
  }
}

// MARK: - PiPCorner

enum PiPCorner: String, CaseIterable, Identifiable {
  case topLeading, topTrailing, bottomLeading, bottomTrailing

  var id: String { rawValue }

  var title: String {
    switch self {
    case .topLeading: "Top Leading"
    case .topTrailing: "Top Trailing"
    case .bottomLeading: "Bottom Leading"
    case .bottomTrailing: "Bottom Trailing"
    }
  }

  var alignment: Alignment {
    switch self {
    case .topLeading: .topLeading
    case .topTrailing: .topTrailing
    case .bottomLeading: .bottomLeading
    case .bottomTrailing: .bottomTrailing
    }
  }
}

// MARK: - Previews

#Preview {
  FaceTimePiPView()
}
