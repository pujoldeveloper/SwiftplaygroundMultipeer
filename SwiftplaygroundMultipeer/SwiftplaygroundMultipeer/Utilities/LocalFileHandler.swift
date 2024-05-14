//
//  LocalFileHandler.swift
//  PujolGolfHelper
//
//  Created by Bruno PUJOL on 07/09/2023.
//

import Foundation

class LocalFileHandler {
    static let shared = LocalFileHandler()
        
    static let DEFAULT_MOVIE_FILE_NAME = "temp"
    static let DEFAULT_MOVIE_FILE_EXTENSION = "mp4"
    let TMP_VIDEO_URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(LocalFileHandler.DEFAULT_MOVIE_FILE_NAME).\(LocalFileHandler.DEFAULT_MOVIE_FILE_EXTENSION)")

    
    func saveToTemp(data: Data, name: String, extension fileExtension: String) {
        let url = getUrlFor(name: name, extension: fileExtension)
        
        do {
            try data.write(to: url)
            LogManager.shared.log(self, "Success saving")
        } catch let error {
            LogManager.shared.error(self, "Error saving. ", error)
        }
    }
    
    
    func get(fileName: String, fileExtension: String, from: FileManager.SearchPathDirectory? = nil) -> Data? {
        let url = getUrlFor(directory: from, name: fileName, extension: fileExtension)
        return get(from: url)
    }
    
    func get(from url: URL) -> Data? {
        if !FileManager.default.fileExists(atPath: url.path) {
            LogManager.shared.error(self, "Error: file doesn't exist")
            return nil
        }
        guard let data = FileManager.default.contents(atPath: url.path) else {
            LogManager.shared.error(self, "Data unavailable at path \(url.path)")
            return nil
        }
        return data
    }
    
    func save(data: Data, fileName: String, fileExtension: String, from: FileManager.SearchPathDirectory? = nil) -> URL? {
        let url = getUrlFor(directory: from, name: fileName, extension: fileExtension)
        return save(data: data, to: url)
    }
    
    func save(data: Data, to url: URL) -> URL? {
        do {
            try data.write(to: url)
            return url
        } catch let error {
            LogManager.shared.error(self, "Error saving. ", error)
            return nil
        }
    }
    
    func move(url: URL, fileName: String, fileExtension: String, from: FileManager.SearchPathDirectory? = nil) -> URL? {
        do {
            let newUrl = getUrlFor(directory: from, name: fileName, extension: fileExtension)
            try FileManager.default.moveItem(at: url, to: newUrl)
            return newUrl
        } catch let error {
            LogManager.shared.error(self, "Error moving file: ",error)
            return nil
        }
    }
    
    func getUrlFor(directory: FileManager.SearchPathDirectory? = nil, name: String, extension fileExtension: String) -> URL {
        let directory = getDirectoryUrl(directory: directory)
        return directory.appendingPathComponent("\(name).\(fileExtension)")
    }
    
    func getDirectoryUrl(directory: FileManager.SearchPathDirectory? = nil) -> URL {
        return directory == nil ? FileManager.default.temporaryDirectory : FileManager.default.urls(for: directory!, in: .userDomainMask)[0]
    }
    
    func delete(url: URL) throws {
        if #available(iOS 16.0, *) {
            try FileManager.default.removeItem(atPath: url.path())
        } else {
            LogManager.shared.log(self, "Delete not implement for lower than iOS 16")
        }
    }
}
