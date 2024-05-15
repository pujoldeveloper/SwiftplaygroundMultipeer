//
//  ContentViewController.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 08/05/2024.
//

import Foundation
import MultipeerConnectivity
import SwiftUI
import UIKit

class ContentViewController: ObservableObject {
    @Published var receivedImage: UIImage? = nil
    @Published var sentImage: UIImage? = nil
    @Published var delegateType = MultipeerConnectionDelegateType.Ackable
    var useUrl = true
    var usePing = true
    var progress: Progress? = nil
    
    init() {
        applyConfig()
    }
    
    func applyConfig() {
        setMultipeerConnectionManagerDelegate()
        setPingTimer()
    }
    
    func setPingTimer() {
        if usePing {
            MultipeerConnectionManager.shared.startPingTimer()
        } else {
            MultipeerConnectionManager.shared.stopPingTimer()
        }
    }
    func setMultipeerConnectionManagerDelegate() {
        MultipeerConnectionManager.shared.delegate = getDelegate()
        LogManager.shared.log(self, "setMultipeerConnectionManagerDelegate: \(String(describing: MultipeerConnectionManager.shared.delegate).extractLoggerName())")
    }
    
    func getDelegate() -> MultipeerConnectionDelegate {
        switch delegateType {
        case .Ackable: MultipeerConnectionAckableDelegate(underlyingDelegate: self)
        case .Discardable: MultipeerConnectionDiscardableDelegate(underlyingDelegate: self)
        default: self
        }
    }
    
    func startSession() {
        MultipeerConnectionManager.shared.host(startPing: usePing)
    }
    
    func joinSession() {
        MultipeerConnectionManager.shared.join();
    }
    
    func disconnect() {
        MultipeerConnectionManager.shared.disconnect();
    }

    func send(_ message: String) {
        MultipeerConnectionManager.shared.send(message)
    }
    
    @MainActor func sendImage(_ imageName: String) {
        let image = Image(imageName)
        
        if useUrl {
            if let url = image.createLocalTempUrl() {
                MultipeerConnectionManager.shared.delegate?.send(to: MultipeerConnectionManager.shared.peers.first, url, withName: imageName, withOption: "Image")
            }
        } else {
            if let imageData = image.getData() {
                MultipeerConnectionManager.shared.delegate?.send(to: MultipeerConnectionManager.shared.peers.first, imageData, withName: imageName, withOption: "Image")
            }
        }
        change(sent: image.getUIImage())
    }
    
    @MainActor func getImageData(_ imageName: String) -> Data? {
        let image = Image(imageName)
        let uiImage = image.getUIImage()
        return uiImage?.jpegData(compressionQuality: 1.0)
    }
    
    func change(sent: UIImage? = nil, received: UIImage? = nil) {
        DispatchQueue.main.async {
            if let sent = sent {
                self.sentImage = sent
            }
            if let received = received {
                self.receivedImage = received
            }
        }
    }
}
extension ContentViewController: MultipeerConnectionDelegate {
    func send(to peerID: MCPeerID? = nil, _ message: Any, withName name: String?, withOption: Any?) {
        MultipeerConnectionManager.shared.send(message, withName: name, to: peerID)
    }
    
    func receiveData(from peerID: MCPeerID, _ data: Data) {
        if let uiImage = UIImage(data: data) {
            change(received: uiImage)
            //LogManager.shared.log(self, "Received UIImage from \(peerID.displayName)")
        } else {
            LogManager.shared.log(self, "Received unknown Data from \(peerID.displayName)")
        }
    }
    
    func receivingUrlStart(from peerID: MCPeerID, withName name: String, with progress: Progress) {
        LogManager.shared.log(self, "Start receiving URL:\(name) from \(peerID.displayName)")
        self.progress = progress
    }
    
    func receivingUrlEnd(from peerID: MCPeerID, withName name: String, _ url: URL) {
        LogManager.shared.log(self, "Received URL:\(name) from \(peerID.displayName)")
        progress = nil
        if let uiImage = url.loadImage() {
            change(received: uiImage)
        } else {
            LogManager.shared.log(self, "Received unknown URL from \(peerID.displayName)")
        }
    }
    
    func receivingUrlCanceled(from peerID: MCPeerID, withName name: String) {
        LogManager.shared.log(self, "Cancelled URL:name from \(peerID.displayName)")
        progress = nil
    }
    
    func connect(_ peerID: MCPeerID) {
        LogManager.shared.log(self, "Connect from \(peerID.displayName)")
    }
    func disconnect(_ peerID: MCPeerID?) {
        LogManager.shared.log(self, "Disconnect from \(peerID?.displayName ?? "Unknown")")
    }
}
