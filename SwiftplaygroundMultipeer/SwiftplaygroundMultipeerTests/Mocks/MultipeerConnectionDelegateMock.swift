//
//  MultipeerConnectionDelegateMock.swift
//  SwiftplaygroundMultipeerTests
//
//  Created by Bruno PUJOL on 11/05/2024.
//

import Foundation
import MultipeerConnectivity

class MultipeerConnectionDelegateMock: MultipeerConnectionDelegate {
    var receivedData = [MCPeerID:[Data]]()
    var receivedUrl = [MCPeerID:[URL]]()
    var sentData = [MCPeerID:[Any]]()
    var connectedPeers = [MCPeerID:Bool]()
    var disconnectedPeers = [MCPeerID:Bool]()
    
    func receiveData(_ data: Data, fromPeer peerID: MCPeerID) {
        var received = receivedData[peerID] ?? [Data]()
        received.append(data)
        receivedData[peerID] = received
    }
    
    func receiveUrl(_ url: URL, fromPeer peerID: MCPeerID) {
        var received = receivedUrl[peerID] ?? [URL]()
        received.append(url)
        receivedUrl[peerID] = received
    }
    
    func sendData(_ message: Any, to peerID: MCPeerID?) {
        let peer = peerID ?? MCPeerID(displayName: "ALL")
        var received = sentData[peer] ?? [Any]()
        received.append(message)
        sentData[peer] = received
    }
    
    func connect(_ peerID: MCPeerID) {
        connectedPeers[peerID] = true
    }
    
    func disconnect(_ peerID: MCPeerID?) {
        let peer = peerID ?? MCPeerID(displayName: "ALL")
        disconnectedPeers[peer] = true
    }
    
    
}
