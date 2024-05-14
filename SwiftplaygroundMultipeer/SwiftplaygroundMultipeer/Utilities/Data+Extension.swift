//
//  Data+Extension.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 09/05/2024.
//

import Foundation

extension Data {
    func getSize(_ unit: ByteCountFormatter.Units = .useMB) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(self.count))
        
        var floatValue = "unknown"
        if let part = string.getPart(" ", index: 0) {
            floatValue = "\((part as NSString).floatValue)"
        }

        return "\(string) (\(floatValue))"
/*
        if let part = string.getPart(" ", index: 0) {
            return (part as NSString).floatValue
        } else {
            return 0
        }
 */
    }
    
    func split(size: Int) -> [Data] {
        var splits = [Data]()
        
        self.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            let mutRawPointer = UnsafeMutableRawPointer(mutating: u8Ptr)
            let uploadChunkSize = size
            let totalSize = self.count
            var offset = 0
            
            while offset < totalSize {
                let chunkSize = offset + uploadChunkSize > totalSize ? totalSize - offset : uploadChunkSize
                let chunk = Data(bytesNoCopy: mutRawPointer+offset, count: chunkSize, deallocator: Data.Deallocator.none)
                offset += chunkSize
                splits.append(chunk)
            }
        }
        return splits
    }
    
    func getString() -> String? {
        if let string = String(data: self, encoding: .utf8) {
//        if getSize() == "0 MB", let string = String(data: self, encoding: .utf8) {
//            LogManager.shared.log(self, "getString(): message:'\(string)' \(getSize())")
            return string
        }
        return nil
    }
}
