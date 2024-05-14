//
//  MultiPeerConnectionManager.swift
//
//  Created by Bruno PUJOL on 30/06/2023.
//

import Foundation
import MultipeerConnectivity

class MultipeerConnectionManager: NSObject, ObservableObject {
    
    static let shared = MultipeerConnectionManager()
    static let PING = "Ping"
    
    override init() {
        super.init()
        
        transformer = MultipeerConnectionDataTransformerImpl()
    }
    
    @Published var peers: [MCPeerID] = []
    @Published var connected = false
    @Published var role = MultipeerConnectionRole.None
    @Published var action = MultipeerConnectionRole.None
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var advertiserAssistant: MCNearbyServiceAdvertiser?
    private var session: MCSession?
    private var mcBrowserViewController: MCBrowserViewController?
    
    var delegate: MultipeerConnectionDelegate? = nil
    var transformer: MultipeerConnectionDataTransformer? = nil
    var connectionHandler: MutlipeerConnectionConnectionValidator? = nil
    
    var pingTimer: Timer? = nil
    
    func getServiceName() -> String { "service" }

    func isHost() -> Bool { role == .Host }
    
    func test() {
        role = .Test
        action = .Test
        connected = true
    }
        
    func host(startPing: Bool = false) {
        action = .Host
        role = .Host
        peers.removeAll()
        
        connected = true
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        
        startAdvertising()
        
        if startPing {
            startPingTimer()
        }
        
        LogManager.shared.log(self, "Server started")
    }

    func join() {
        action = .Join
        peers.removeAll()
        
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        guard
            //let window = UIApplication.shared.windows.first,
            let window = UIApplication.shared.keyWindow,
            let session = session
        else { return }
        
        mcBrowserViewController = MCBrowserViewController(serviceType: getServiceName(), session: session)
        mcBrowserViewController?.delegate = self
        window.rootViewController?.present(mcBrowserViewController!, animated: true)
        LogManager.shared.log(self, "Start client")
    }
    
    func disconnect() {
        stopAdvertising()

        action = .None
        role = .None
        peers.removeAll()
        session?.disconnect()
        session?.delegate = nil
        
        stopPingTimer()
        
        LogManager.shared.log(self, "Disconnected")
    }
    
    func send(_ message: Any, to peerID: MCPeerID? = nil) {
        guard let session = session
        else {
            // This means there is no one connected
            LogManager.shared.error(self, "Failed to send \(message) because session is nil")
            return
        }
        
        guard
            !session.connectedPeers.isEmpty
        else {
            LogManager.shared.error(self, "Failed to send \(message) because no one is connected")
            return
        }

        do {
            if let url = message as? URL {
                logSendReceive(data: url, fromTo: peerID, sending: true)
                session.sendResource(at: url, withName: "something", toPeer: peerID ?? session.connectedPeers.first!)
            } else if let data = transformer?.toData(message) {
                logSendReceive(data: data, fromTo: peerID, sending: true)
                try session.send(data, toPeers: peerID != nil ? [peerID!] : session.connectedPeers, with: .reliable)
            } else {
                LogManager.shared.error(self, "Failed to send \(message) because data is nil")
                return
            }
        } catch {
            LogManager.shared.error(self, "join failed: error \(error.localizedDescription)")
        }
    }
    
    func logSendReceive(data: Any, fromTo: MCPeerID?, sending: Bool) {
/*
        if isPing(data) {
            return
        }
  */
        var message = "\(sending ? "Sending" : "Receiving"): \(debugData(data))(\(data))"
        
        if let data = data as? Data {
            message.append("size:\(data.getSize(.useBytes))")
        }
        message.append(" \(sending ? "to" : "from") \(fromTo?.displayName ?? "unknown")")
        LogManager.shared.log(self, message)
    }
        
    func isPing(_ input: Any) -> Bool {
        if let data = input as? Data,
            ("\(data)" == "3 bytes" || "\(data)" == "4 bytes"),
           let message = data.getString() {
            return Self.PING == message
        }
        return false
    }
    
    func debugData(_ input: Any) -> String {
        if let message = input as? String {
            return message
        } else if let data = input as? Data {
             if let message = data.getString() {
             return message
             } else if let _ = UIImage(data: data) {
             return "Image"
             } else {
             return "Data"
             }
        } else if let _ = input as? URL {
            return "URL"
        } else {
            return "Unknown"
        }
    }
        
    func startPingTimer() {
        if isHost() && pingTimer == nil {
            pingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(pingTimerCallback), userInfo: nil, repeats: true)
        }
    }
    
    func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    @objc func pingTimerCallback() {
        if !peers.isEmpty {
            send(Self.PING)
        }
    }
    
    func startAdvertising() {
        if !isHost() { return }
        
        if advertiserAssistant == nil {
            advertiserAssistant = MCNearbyServiceAdvertiser(
                peer: myPeerId,
                discoveryInfo: nil,
                serviceType: getServiceName())
        }
        advertiserAssistant?.delegate = self
        advertiserAssistant?.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        if !isHost() { return }
        
        advertiserAssistant?.stopAdvertisingPeer()
    }
}

extension MultipeerConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        let connectionAccepted = connectionHandler?.accept(peerID, peers: peers) ?? true
        invitationHandler(connectionAccepted, session)
    }
}

extension MultipeerConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            LogManager.shared.log(self, "Connected to: \(peerID.displayName)")
                        
            if !peers.contains(peerID) {
                DispatchQueue.main.async {
                    self.peers.insert(peerID, at: 0)
                    
                    if !(self.connectionHandler?.shouldBeAdvertising(peers: self.peers) ?? true) {
                        self.stopAdvertising()
                    }
                    
                    if self.action == .Join {
                        self.role = self.action
                    }
                }
            }
            delegate?.connect(peerID)
        case .notConnected:
//            LogManager.shared.log(self, "Disconnected to: \(peerID.displayName)")
            DispatchQueue.main.async {
                if let index = self.peers.firstIndex(of: peerID) {
                    self.peers.remove(at: index)
                    self.delegate?.disconnect(peerID)
                    
                    if (self.connectionHandler?.shouldBeAdvertising(peers: self.peers) ?? true) {
                        self.startAdvertising()
                    }
                }
                if self.peers.isEmpty && !self.isHost() {
                    self.connected = false
                }
                if self.role == .Join {
                    self.role = .None
                    self.action = .None
                }
            }
            delegate?.disconnect(peerID)
        case .connecting:
            LogManager.shared.log(self, "Connecting to: \(peerID.displayName)")
        @unknown default:
            LogManager.shared.error(self, "Unknown state: \(state) to: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        logSendReceive(data: data, fromTo: peerID, sending: false)
        if !isPing(data) {
            delegate?.receiveData(from: peerID, data)
        }
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        delegate?.receivingUrlStart(from: peerID, with: progress)
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

        if let url = localURL {
            delegate?.receivingUrlEnd(from: peerID, url)
        } else {
            delegate?.receivingUrlCanceled(from: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
}

extension MultipeerConnectionManager: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        LogManager.shared.log(self, "browserViewControllerDidFinish")
        
        browserViewController.dismiss(animated: true) {
            self.connected = true
            self.mcBrowserViewController = nil
        }
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
        LogManager.shared.log(self, "browserViewControllerWasCancelled")
        
        session?.disconnect()
        browserViewController.dismiss(animated: true) {
            self.mcBrowserViewController = nil
        }
        delegate?.disconnect(nil)
    }
}
