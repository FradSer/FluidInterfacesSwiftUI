//
//  ContentView.swift
//  Shared
//
//  Created by Frad LEE on 5/27/21.
//

import SwiftUI

// MARK: - Demo

/// The seven fluid-interface demos, type-driven so routing cannot drift from
/// the case set. Icons are SF Symbols (auto-theming, no image assets).
enum Demo: String, CaseIterable, Identifiable {
  case calculator
  case spring
  case flashlight
  case rubberbanding
  case accelerationPausing
  case rewardingMomentum
  case faceTimePiP

  var id: String { rawValue }

  var title: String {
    switch self {
    case .calculator: "Calculator Button"
    case .spring: "Spring Animations"
    case .flashlight: "Flashlight Button"
    case .rubberbanding: "Rubberbanding"
    case .accelerationPausing: "Acceleration Pausing"
    case .rewardingMomentum: "Rewarding Momentum"
    case .faceTimePiP: "FaceTime PiP"
    }
  }

  var symbolName: String {
    switch self {
    case .calculator: "plus.square"
    case .spring: "waveform"
    case .flashlight: "flashlight.on.fill"
    case .rubberbanding: "arrow.up.left.and.down.right.magnify"
    case .accelerationPausing: "speedometer"
    case .rewardingMomentum: "rectangle.stack"
    case .faceTimePiP: "rectangle.pictureinpicture"
    }
  }

  @ViewBuilder
  @MainActor var destination: some View {
    switch self {
    case .calculator: CalculatorButtonView()
    case .spring: SpringAnimationsView()
    case .flashlight: FlashlightButtonView()
    case .rubberbanding: RubberbandingView()
    case .accelerationPausing: AccelerationPausingView()
    case .rewardingMomentum: RewardingMomentumView()
    case .faceTimePiP: FaceTimePiPView()
    }
  }
}

// MARK: - ContentView

struct ContentView: View {
  @State private var path: [Demo] = []

  var body: some View {
    NavigationStack(path: $path) {
      List(Demo.allCases) { demo in
        NavigationLink(value: demo) {
          HStack(spacing: 16) {
            Image(systemName: demo.symbolName)
              .font(.title3)
              .frame(width: 28, height: 28)
              .foregroundStyle(.tint)
            Text(demo.title).bold()
          }
          .padding(.vertical, 4)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
      }
      .listStyle(.automatic)
      .scrollContentBackground(.hidden)
      .listRowSeparator(.hidden)
      .navigationTitle("Fluid Interfaces")
      .navigationDestination(for: Demo.self) { demo in
        demo.destination
      }
    }
  }
}

// MARK: - Previews

#Preview {
  ContentView()
    .preferredColorScheme(.dark)
}
