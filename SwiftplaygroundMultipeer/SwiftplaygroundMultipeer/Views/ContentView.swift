//
//  ContentView.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 08/05/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var multipeerConnectionManager: MultipeerConnectionManager
    @StateObject var controller: ContentViewController
    @State var showConfig = false
    @State var receivingProgress: Double? = nil
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            connectionView()
            Divider()
            connectionStatusView()
            Divider()
            buttonView()
            Divider()
            receivedImageView()
            Spacer()
            Divider()
            LogView(logManager: LogManager.shared)
        }
        .padding()
        .sheet(isPresented: $showConfig) {
            controller.applyConfig()
        } content: {
            SettingsView(controller: controller, isShown: $showConfig)
        }.onReceive(timer) { _ in
            timerCallback()
        }
    }
    
    func connectionView() -> some View {
        HStack {
            Spacer()
            Button(action: controller.startSession,
                   label: { Label("Host", systemImage: "plus.circle") } ).disabled(multipeerConnectionManager.role != .None)
            Button( action: controller.joinSession,
                    label: { Label("Join", systemImage: "arrow.up.right.and.arrow.down.left.rectangle") }).disabled(multipeerConnectionManager.role != .None)
            Button( action: controller.disconnect,
                    label: { Label("Leave", systemImage: "exclamationmark.octagon.fill") }).disabled(multipeerConnectionManager.role == .None)
            Spacer()
            Button (action: { showConfig.toggle() },
                    label: { Label("", systemImage: "gearshape") }
            )
        }
    }
    
    func connectionStatusView() -> some View {
        Text(getConnectionStatus())
    }
    
    func buttonView() -> some View {
        HStack {
            button(text: "368K", image: "Saturn")
            button(text: "9M", image: "UGC 12158")
            button(text: "17M", image: "NGC 5468")
            button(text: "48M", image: "Little Dumbbell Nebula")
        }
    }
    
    func button(text: String, image: String) -> some View {
        Button( action: {
            controller.sendImage(image)
        },
                label: {
            VStack {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: getButtonSize(), height: getButtonSize())
                    .padding(0)
                Text(text).padding(0)
            }
        })
        .disabled(multipeerConnectionManager.role == .None)
    }
    
    func receivedImageView() -> some View {
        HStack {
            ZStack {
                if let receivedImage = controller.receivedImage {
                    Image(uiImage: receivedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: getButtonSize(), height: getButtonSize())
                } else {
                    Color.gray.frame(width: getButtonSize(), height: getButtonSize())
                }
                if let progress = receivingProgress {
                   if let _ = controller.receivedImage {
                    Color.gray.frame(width: getButtonSize(), height: getButtonSize()).opacity(0.5)
                   }
                
                   CircularProgressView(progress: progress, strokeColor: .blue)
                        .frame(width: getButtonSize() / 2, height: getButtonSize() / 2)
                }
            }
            if let sentImage = controller.sentImage {
                Image(uiImage: sentImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: getButtonSize(), height: getButtonSize())
            } else {
                Color.gray.frame(width: getButtonSize(), height: getButtonSize())
            }
        }
    }
    
    func getConnectionStatus() -> String {
        if multipeerConnectionManager.role == .None {
            "Not connected"
        } else if multipeerConnectionManager.role == .Host {
            "Connected to \(multipeerConnectionManager.peers.count)"
        } else {
            "Connected to \(multipeerConnectionManager.peers.first?.displayName ?? "Unknown")"
        }
    }
    
    func getButtonSize() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 75
        }
        return 100
    }
    
    func timerCallback() {
        if let progress = controller.progress {
            receivingProgress = progress.fractionCompleted
        } else {
            receivingProgress = nil
        }
    }
}
