//
//  MultipeerConnectionSplitableDelegate.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 11/05/2024.
//

import Foundation
import MultipeerConnectivity

/*
class MultipeerConnectionSplitableDelegate: MultipeerConnectionAckableDelegate {
    private static let SPLIT = "Split"
    
    private var ongoingSplits = [MCPeerID:Data]()
    private var ongoingSplitCounts = [MCPeerID:Int]()
    
    internal override func addToQueue(_ data: Any, to peerID: MCPeerID) {
        guard let splits = splitData(data) else { return }
        if splits.isEmpty {
            return // should never happen
        } else if splits.count == 1 {
            super.addToQueue(data, to: peerID)
        } else {
            super.addToQueue("\(Self.SPLIT):\(splits.count)".data(using: .utf8)!, to: peerID)
            for split in splits {
                super.addToQueue(split, to: peerID)
            }
        }
    }
    
    internal override func handleReceive(_ data: Any, fromPeer peerID: MCPeerID) {
        if let count = ongoingSplitCounts[peerID] {
            var ongoingSplit =  ongoingSplits[peerID] ?? Data()
            ongoingSplit.append(data)
            
            if count <= 1 {
                ongoingSplits[peerID] = nil
                ongoingSplitCounts[peerID] = nil
                super.handleReceive(data, fromPeer: peerID)
            } else {
                ongoingSplits[peerID] = ongoingSplit
                ongoingSplitCounts[peerID] = count - 1
            }
        } else if let count = getSplitStart(data) {
            ongoingSplitCounts[peerID] = count
            ongoingSplits[peerID] = Data()
        } else {
            super.handleReceive(data, fromPeer: peerID)
        }
/*
        if isSplitEnd(data) {
            if let finalized = ongoingSplits[peerID] {
                super.handleReceive(finalized, fromPeer: peerID)
            }
            ongoingSplits[peerID] = nil
        } else if isSplitStart(data) {
            ongoingSplits[peerID] = Data()
        } else if var ongoingSplit = ongoingSplits[peerID] {
            ongoingSplit.append(data)
            ongoingSplits[peerID] = ongoingSplit
        } else {
            super.handleReceive(data, fromPeer: peerID)
        }
 */
    }
    
    func splitData(_ message: Any) -> [Data]? {
        let data = message as? Data
        return data?.split(size: 2097152)
    }
    
    internal func getSplitStart(_ data: Data) -> Int? {
        if let message = data.getString(),
           message.starts(with: Self.SPLIT),
           let split = message.getPart(":", index: 1) {
            return split.toInt()
        }
        return nil
    }
}
*/
