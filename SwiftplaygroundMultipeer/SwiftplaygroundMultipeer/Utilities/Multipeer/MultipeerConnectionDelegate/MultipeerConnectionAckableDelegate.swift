//
//  MultipeerConnectionAckableDelegate.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 11/05/2024.
//

import Foundation
import MultipeerConnectivity

class MultipeerConnectionAckableDelegate: MultipeerConnectionDelegate {
    private static let ACK = "Ack"
    
    internal let underlyingDelegate: MultipeerConnectionDelegate
    internal var sendingDataQueues = [MCPeerID:[Any]]()
    internal var sendingPendingAcks = [MCPeerID:Bool]()

    init (underlyingDelegate: MultipeerConnectionDelegate) {
        self.underlyingDelegate = underlyingDelegate
    }

    func connect(_ peerID: MCPeerID) {
        sendingDataQueues.removeValue(forKey: peerID)
        sendingPendingAcks.removeValue(forKey: peerID)
        
        underlyingDelegate.connect(peerID)
    }
    func disconnect(_ peerID: MCPeerID?) { underlyingDelegate.disconnect(peerID) }

    func receivingUrlStart(from peerID: MCPeerID, with progress: Progress) {
        underlyingDelegate.receivingUrlStart(from: peerID, with: progress)
    }
    
    func receivingUrlEnd(from peerID: MCPeerID, _ url: URL) {
        underlyingDelegate.send(to: peerID, Self.ACK.data(using: .utf8)!)
        handleReceive(from: peerID, url )
    }
    
    func receivingUrlCanceled(from peerID: MCPeerID) {
        underlyingDelegate.receivingUrlCanceled(from: peerID)
    }
    
    func receiveData(from peerID: MCPeerID, _ data: Data) {
        if isAck(data) {
            sendingPendingAcks[peerID] = nil
            tryToSend(to: peerID)
        } else {
            underlyingDelegate.send(to: peerID, Self.ACK.data(using: .utf8)!)
            handleReceive(from: peerID, data)
        }
    }
    
    internal func handleReceive(from peerID: MCPeerID, _ message: Any) {
        if let data = message as? Data {
            underlyingDelegate.receiveData(from: peerID, data)
        } else if let url = message as? URL {
            underlyingDelegate.receivingUrlEnd(from: peerID, url)
        }
    }
    
    func send(to peerID: MCPeerID?, _ message: Any) {
        addToSend(message, to: peerID ?? MultipeerConnectionManager.shared.peers.first!)
    }
    
    internal func addToSend(_ data: Any, to peerID: MCPeerID) {
        addToQueue(data, to: peerID)
        tryToSend(to: peerID)
    }
    
    internal func addToQueue(_ data: Any, to peerID: MCPeerID) {
        var sendingDataQueue = sendingDataQueues[peerID] ?? [Data]()
        sendingDataQueue.append(data)
        sendingDataQueues[peerID] = sendingDataQueue
    }
    
    internal func tryToSend(to peerID: MCPeerID) {
        let isPending = sendingPendingAcks[peerID] ?? false
        if isPending {
            return
        }
        
        var sendingDataQueue = sendingDataQueues[peerID]
        if sendingDataQueue?.isEmpty ?? true {
            sendingPendingAcks[peerID] = nil
            return
        }
        guard let toSend = sendingDataQueue?.removeFirst() else {
            sendingPendingAcks[peerID] = nil
            return
        }
        sendingDataQueues[peerID] = sendingDataQueue
        sendingPendingAcks[peerID] = true
        
        underlyingDelegate.send(to: peerID, toSend)
    }
    
    internal func isAck(_ data : Data) -> Bool {
        isFixString(data, Self.ACK)
    }
    
    internal func isFixString(_ data : Data, _ fixString: String) -> Bool {
        if let message = String(data: data, encoding: .utf8) {
            return message == fixString
        }
        return false
    }
}
