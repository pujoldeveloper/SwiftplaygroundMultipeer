//
//  MultipeerConnectionAckableDelegate_ActualSend_Test.swift
//  SwiftplaygroundMultipeerTests
//
//  Created by Bruno PUJOL on 11/05/2024.
//

import XCTest
import MultipeerConnectivity

final class MultipeerConnectionAckableDelegate_ActualSend_Test: XCTestCase {

    private var multipeerConnectionDelegateMock: MultipeerConnectionDelegateMock!
    private var test: MultipeerConnectionAckableDelegate!
    private var to: MCPeerID!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        multipeerConnectionDelegateMock = MultipeerConnectionDelegateMock()
        test = MultipeerConnectionAckableDelegate(underlyingDelegate: multipeerConnectionDelegateMock)
        
        to = MCPeerID(displayName: "test")
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        test = nil
        multipeerConnectionDelegateMock = nil
        to = nil
    }

    func testActualSend_should_doNothing_when_noPendingMessage() throws {
        test.actualSend(to: to)
        
        XCTAssertEqual(multipeerConnectionDelegateMock.sentData.count, 0)
    }

    func testActualSend_should_sendAMessage_if_pendingMessage() throws {
        test.sendingDataQueues[to] = ["aMessage", "anotherMessage"]
        
        test.actualSend(to: to)
        
        XCTAssertEqual(multipeerConnectionDelegateMock.sentData[to]!.count, 1)
        XCTAssertEqual(multipeerConnectionDelegateMock.sentData[to]!.first as? String, "aMessage")
        
        XCTAssertEqual(test.sendingDataQueues[to]!.count, 1)
        XCTAssertEqual(test.sendingDataQueues[to]!.first as? String, "anotherMessage")
        XCTAssertEqual(test.sendingPendingAcks[to]!, true)
    }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
