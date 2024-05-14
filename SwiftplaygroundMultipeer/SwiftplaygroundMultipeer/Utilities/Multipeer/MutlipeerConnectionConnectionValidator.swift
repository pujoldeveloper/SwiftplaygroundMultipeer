//
//  MutlipeerConnectionConnectionValidator.swift
//
//  Created by Bruno PUJOL on 17/02/2024.
//

import SwiftUI
import Foundation
import MultipeerConnectivity

protocol MutlipeerConnectionConnectionValidator {
    func accept(_ peerId: MCPeerID, peers: [MCPeerID]) -> Bool
    func shouldBeAdvertising(peers: [MCPeerID]) -> Bool
}

class MutlipeerConnectionOneConnectionValidator: MutlipeerConnectionConnectionValidator {
    func accept(_ peerId: MCPeerID, peers: [MCPeerID]) -> Bool {
        return peers.count == 0
    }
    func shouldBeAdvertising(peers: [MCPeerID]) -> Bool {
        return peers.count == 0
    }
}

