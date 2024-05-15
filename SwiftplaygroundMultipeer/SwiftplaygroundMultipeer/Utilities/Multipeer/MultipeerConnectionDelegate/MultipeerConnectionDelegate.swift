//
//  MultipeerConnectionDelegate.swift
//
//  Created by Bruno PUJOL on 05/09/2023.
//

import Foundation
import MultipeerConnectivity

protocol MultipeerConnectionDelegate {
    func receiveData(from peerID: MCPeerID, _ data: Data)
    func receivingUrlStart(from peerID: MCPeerID, withName: String, with progress: Progress)
    func receivingUrlEnd(from peerID: MCPeerID, withName: String, _ url: URL)
    func receivingUrlCanceled(from peerID: MCPeerID, withName: String)
    func send(to peerID: MCPeerID?, _ message: Any, withName: String?, withOption: Any?)
    func connect(_ peerID: MCPeerID)
    func disconnect(_ peerID: MCPeerID?)
}
