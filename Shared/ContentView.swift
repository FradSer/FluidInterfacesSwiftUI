//
//  ContentView.swift
//  Shared
//
//  Created by Frad LEE on 5/27/21.
//

import SwiftUI

// MARK: - ListItem

struct ListItem: Identifiable {
  let id = UUID()
  let icon: String
  let name: String
}

// MARK: - ContentView

struct ContentView: View {
  let list = [
    ListItem(icon: "icon_calc", name: "Calculator Button"),
    ListItem(icon: "icon_spring", name: "Spring Animations"),
    ListItem(icon: "icon_flash", name: "Flashlight Button"),
    ListItem(icon: "icon_rubber", name: "Rubberbanding"),
    ListItem(icon: "icon_acceleration", name: "Acceleration Pausing"),
    ListItem(icon: "icon_momentum", name: "Rewarding Momentum"),
    ListItem(icon: "icon_pip", name: "FaceTime PiP")
  ]

  var body: some View {
    NavigationView {
      List(list) { listItem in
        NavigationLink(destination: destinationView(listItem.name)) {
          HStack(spacing: 16) {
            Image(listItem.icon)
              .resizable()
              .frame(width: 28, height: 28, alignment: .center)
            Text(listItem.name).bold()
          }
          .padding(.vertical)
        }
      }
      .navigationTitle("Fluid Interfaces")
    }
  }
}

extension ContentView {
  @ViewBuilder
  private func destinationView(_ destination: String) -> some View {
    switch destination {
    case "Calculator Button":
      CalculatorButtonView()
    case "Spring Animations":
      SpringAnimationsView()
    case "Flashlight Button":
      FlashlightButtonView()
    case "Rubberbanding":
      RubberbandingView()
    case "Acceleration Pausing":
      AccelerationPausingView()
    case "Rewarding Momentum":
      RewardingMomentumView()
    case "FaceTime PiP":
      FaceTimePiPView()
    default:
      Text("ERROR")
    }
  }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .preferredColorScheme(.dark)
  }
}
