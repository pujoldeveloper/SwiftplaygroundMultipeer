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
    internal var sendingDataQueues = [MCPeerID:[(data:Any,name:String?,option:Any?)]]()
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

    func receivingUrlStart(from peerID: MCPeerID, withName name : String, with progress: Progress) {
        underlyingDelegate.receivingUrlStart(from: peerID, withName: name, with: progress)
    }
    
    func receivingUrlEnd(from peerID: MCPeerID, withName name : String, _ url: URL) {
        underlyingDelegate.send(to: peerID, Self.ACK.data(using: .utf8)!, withName: name, withOption: nil)
        handleReceive(from: peerID, url, withName: name)
    }
    
    func receivingUrlCanceled(from peerID: MCPeerID, withName name : String) {
        underlyingDelegate.receivingUrlCanceled(from: peerID, withName: name)
    }
    
    func receiveData(from peerID: MCPeerID, _ data: Data) {
        if isAck(data) {
            handleAck(from: peerID)
            tryToSend(to: peerID)
        } else {
            underlyingDelegate.send(to: peerID, Self.ACK.data(using: .utf8)!, withName: Self.ACK, withOption: nil)
            handleReceive(from: peerID, data, withName: "")
        }
    }
    
    internal func handleAck(from peerID: MCPeerID) {
        var sendingDataQueue = sendingDataQueues[peerID]
        if sendingDataQueue?.isEmpty ?? true {
            sendingPendingAcks[peerID] = nil
            return
        }
        
        sendingDataQueue?.removeFirst()
        
        sendingPendingAcks[peerID] = nil
        sendingDataQueues[peerID] = sendingDataQueue
    }
    
    internal func handleReceive(from peerID: MCPeerID, _ message: Any, withName name: String) {
        if let data = message as? Data {
            underlyingDelegate.receiveData(from: peerID, data)
        } else if let url = message as? URL {
            underlyingDelegate.receivingUrlEnd(from: peerID, withName: name, url)
        }
    }
    
    func send(to peerID: MCPeerID?, _ message: Any, withName name: String?, withOption option: Any?) {
        let sendTo = peerID ?? MultipeerConnectionManager.shared.peers.first!
        addToSend(message, withName: name, withOption: option, to: sendTo)
    }
    
    internal func addToSend(_ data: Any, withName name: String?, withOption option: Any?, to peerID: MCPeerID) {
        
//        LogManager.shared.log(self, "addToSend \(withOption as? String ?? "nil")")
        
        addToQueue(data, withName: name, withOption: option, to: peerID)
        tryToSend(to: peerID)
    }
    
    internal func addToQueue(_ data: Any, withName name: String?, withOption option: Any?,to peerID: MCPeerID) {
        var sendingDataQueue = sendingDataQueues[peerID] ?? [(data:Any,name:String?,option:Any?)]()
        sendingDataQueue.append((data, name, option))
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
/*
        guard let toSend = sendingDataQueue?.removeFirst() else {
            sendingPendingAcks[peerID] = nil
            return
        }
        sendingDataQueues[peerID] = sendingDataQueue
 */
        if let toSend = sendingDataQueue?.first {
            sendingPendingAcks[peerID] = true
            
            underlyingDelegate.send(to: peerID, toSend.data, withName: toSend.name, withOption: toSend.option)
        }
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
