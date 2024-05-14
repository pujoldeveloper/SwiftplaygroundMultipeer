//
//  SettingsView.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 11/05/2024.
//

import SwiftUI

enum MultipeerConnectionDelegateType: String, Equatable, CaseIterable {
    case Simple, Ackable, Splitable
}


struct SettingsView: View {
    @StateObject var controller: ContentViewController
    @Binding var isShown: Bool

    var body: some View {
        VStack {
            HStack {
                Text("Delegate")
                Picker("Delegate", selection: $controller.delegateType) {
                    ForEach(Array(MultipeerConnectionDelegateType.allCases), id: \.self) {
                        Text($0.rawValue)
                    }
                }.padding()
            }
            Toggle("Use URL:", isOn: $controller.useUrl).padding()
            Toggle("Use Ping:", isOn: $controller.usePing).padding()

            Spacer()
            Button(action: { isShown.toggle() },
                   label: { Label("Exit", systemImage: "x.circle") } )
            .padding()
        }
    }
}
