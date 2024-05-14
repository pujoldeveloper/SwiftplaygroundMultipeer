//
//  MultipeerConnectionSplitableDelegateOld.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 12/05/2024.
//

import Foundation
import MultipeerConnectivity

/*
class MultipeerConnectionSplitableDelegateOld: MultipeerConnectionDelegate {
    let underlyingDelegate: MultipeerConnectionDelegate
    
    var receivingSplitCounts = [MCPeerID:Int]()
    var receivingSplitDatas = [MCPeerID:[Data]]()
    var sendingDataQueues = [MCPeerID:[Any]]()
    var sendingPendingAcks = [MCPeerID:Bool]()

    
    init (underlyingDelegate: MultipeerConnectionDelegate) {
        self.underlyingDelegate = underlyingDelegate
    }
    
    func send(_ message: Any, to peerID: MCPeerID? = nil) {
        let sendTo = peerID ?? MultipeerConnectionManager.shared.peers.first!
        
        if let splitData = splitData(message),
           splitData.count > 1 {
            addToSend(["split:\(splitData.count)"], to: sendTo)
            addToSend(splitData, to: sendTo)
        } else {
            addToSend([message], to: sendTo)
        }
    }
    
    func addToSend(_ data: [Any], to peerID: MCPeerID) {
        var sendingDataQueue = sendingDataQueues[peerID] ?? [Data]()
        sendingDataQueue.append(contentsOf: data)

        var toSend: Any? = nil
        if !(sendingPendingAcks[peerID] ?? false) {
            toSend = sendingDataQueue.removeFirst()
        }
        sendingDataQueues[peerID] = sendingDataQueue
        if let toSend = toSend {
            underlyingDelegate.send(toSend, to: peerID)
        }
    }
    
    func receiveData(_ data: Data, fromPeer peerID: MCPeerID) {
        if let splitCount = receivingSplitCounts[peerID] {
            var splitData = receivingSplitDatas[peerID] ?? [Data]()
            splitData.append(data)
            
            if splitData.count == splitCount {
                receivingSplitDatas[peerID] = nil
                receivingSplitCounts[peerID] = nil
                underlyingDelegate.receiveData(mergeData(splitData), fromPeer: peerID)
            } else {
                receivingSplitDatas[peerID] = splitData
            }
        } else if let message = String(data: data, encoding: .utf8),
                  let splitCount = getSplitCount(message) {
            receivingSplitDatas[peerID] = nil
            receivingSplitCounts[peerID] = splitCount
        } else {
            underlyingDelegate.receiveData(data, fromPeer: peerID)
        }
    }
    
    func receiveUrl(_ url: URL, fromPeer peerID: MCPeerID) {
        underlyingDelegate.receiveUrl(url, fromPeer: peerID)
    }
    
    func connect(_ peerID: MCPeerID) {
        underlyingDelegate.connect(peerID)
    }
    
    func disconnect(_ peerID: MCPeerID?) {
        underlyingDelegate.disconnect(peerID)
    }
    
    func mergeData(_ splittedData: [Data]) -> Data {
        var mergeData = Data()
        for splitDataElement in splittedData {
            mergeData.append(splitDataElement)
        }
        return mergeData
    }
    
    func getSplitCount(_ message: String) -> Int? {
        if !message.contains("split") {
            return nil
        }
        let split = message.split(separator: ":")
        return Int(split[1])
    }
    
    func splitData(_ message: Any) -> [Data]? {
        let data = message as? Data
        return data?.split(size: 2097152)
    }
}
*/
