//
//  MultipeerConnectionDiscardableDelegate.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 14/05/2024.
//

import Foundation
import MultipeerConnectivity

class MultipeerConnectionDiscardableDelegate: MultipeerConnectionAckableDelegate {

    override internal func addToSend(_ data: Any, withName name: String?, withOption option: Any?, to peerID: MCPeerID) {
        
//        LogManager.shared.log(self, "addToSend \(withOption as? String ?? "nil")")
        if !checkIfPending(to: peerID, withOption: option) {
            super.addToSend(data, withName: name, withOption: option, to: peerID)
        } else {
//            LogManager.shared.log(self, "addToSend \(withOption as? String ?? "nil" ) => discarded")
        }
    }
    
    internal func checkIfPending(to: MCPeerID, withOption option: Any?) -> Bool {
        if let option = option as? String,
           let sendingDataQueue = sendingDataQueues[to] {
            
            for queuedData in sendingDataQueue {
//                LogManager.shared.log(self, "checkIfPending \(queuedData.option as? String ?? "nil") == \(option) ")
                if let queueOption = queuedData.option as? String,
                   queueOption == option {
                    return true
                }
            }
        }
        return false
    }
}
