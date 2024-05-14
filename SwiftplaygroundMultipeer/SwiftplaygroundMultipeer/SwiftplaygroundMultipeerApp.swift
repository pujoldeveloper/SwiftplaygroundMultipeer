//
//  SwiftplaygroundMultipeerApp.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 08/05/2024.
//

import SwiftUI

@main
struct SwiftplaygroundMultipeerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(multipeerConnectionManager: MultipeerConnectionManager.shared, controller: ContentViewController())
        }
    }
}
