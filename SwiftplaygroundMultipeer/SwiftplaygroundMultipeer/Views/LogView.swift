//
//  LogView.swift
//  PujolGolfHelper
//
//  Created by Bruno PUJOL on 28/04/2024.
//

import SwiftUI

struct LogView: View {
    @ObservedObject var logManager: LogManager
    
    var body: some View {
        VStack {
            Text("Log \(logManager.logCount)").padding()
                Text(aggregate(LogManager.shared.inAppLog))
                    .scrollDisabled(false)
                    .background(.clear)
                    
#if os(iOS)
                    .font(.subheadline)
#endif
        }
    }
    
    func aggregate(_ logs: [String]) -> String {
        if logs.count == 0 {
            return ""
        }
        return logs.reversed().joined(separator: "\n")
        //return logs.joined(separator: "\n")
    }
}
