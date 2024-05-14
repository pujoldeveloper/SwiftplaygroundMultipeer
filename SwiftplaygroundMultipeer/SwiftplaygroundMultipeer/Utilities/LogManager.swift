//
//  Logger.swift
//  PujolGolfHelper
//
//  Created by Bruno PUJOL on 06/09/2023.
//

import Foundation
import os.log

class LogManager: ObservableObject {
    static var shared = LogManager()
        
    static let MAX_LOG_SIZE: Int = 10

    private var loggers = [String:Logger]()
    var inAppLog = [String]()
    @Published var logCount = 0

    func log(_ source: Any, _ message: String) {
        getLogger(source).log("\(message)")
        addInAppLog(type: "LOG", source: source, message: message)
    }
    
    func error(_ source: Any, _ message: String, _ error: Error? = nil) {
        getLogger(source).error("\(message)\(error?.localizedDescription ?? "")")
        addInAppLog(type: "ERROR", source: source, message: message)
    }
    
    func debug(_ source: Any, _ message: String) {
        getLogger(source).debug("\(message)")
        addInAppLog(type: "DEBUG", source: source, message: message)
    }
    
    func addInAppLog(type: String, source: Any, message: String) {
        DispatchQueue.main.async {
            self.logCount += 1
            
//print("\(type):\(self.getLoggerName(source)):\(message)")
            self.inAppLog.insert("\(type):\(self.getLoggerName(source)):\(message)", at: 0)
            if self.inAppLog.count >= Self.MAX_LOG_SIZE {
                self.inAppLog.removeLast()
            }
        }
    }
    
    private func getLoggerName(_ source: Any) -> String {
        return String(describing: source).extractLoggerName()
    }

     
    private func getLogger(_ source: Any) -> Logger {
        let name = getLoggerName(source)
        if let logger = loggers[name] {
            return logger
        }
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: name)
        loggers[name] = logger
        return logger
    }
}
