//
//  Image+Extension.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 09/05/2024.
//

import Foundation
import SwiftUI

extension Image {
    @MainActor
    func getUIImage() -> UIImage? {
        if #available(iOS 16.0, *) {
            return ImageRenderer(content: self).uiImage
        } else {
            LogManager.shared.error(self, "getUIImage not supported")
            return nil
        }
    }
    
    @MainActor func getData() -> Data? {
        let uiImage = self.getUIImage()
        return uiImage?.jpegData(compressionQuality: 1.0)
    }
    
    @MainActor func createLocalTempUrl() -> URL? {
        
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("temp.png")
        
        if fileManager.fileExists(atPath: url.path) {
            do {
                try LocalFileHandler.shared.delete(url: url)
            } catch {
                LogManager.shared.error(self, "fail to delete temp file \(url)")
                return nil
            }
        }
        guard
            let data = self.getData()
        else {
            LogManager.shared.error(self, "fail to generate data")
            return nil
        }
        fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
        return url
    }
}
