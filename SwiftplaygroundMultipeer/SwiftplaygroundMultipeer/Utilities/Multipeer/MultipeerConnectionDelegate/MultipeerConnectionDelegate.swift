//
//  MultipeerConnectionDelegate.swift
//
//  Created by Bruno PUJOL on 05/09/2023.
//

import Foundation
import MultipeerConnectivity

protocol MultipeerConnectionDelegate {
    func receiveData(from peerID: MCPeerID, _ data: Data)
    func receivingUrlStart(from peerID: MCPeerID, with progress: Progress)
    func receivingUrlEnd(from peerID: MCPeerID, _ url: URL)
    func receivingUrlCanceled(from peerID: MCPeerID)
    func send(to peerID: MCPeerID?, _ message: Any)
    func connect(_ peerID: MCPeerID)
    func disconnect(_ peerID: MCPeerID?)
}
