//
//  GetCacheImage.swift
//  VK Project
//
//  Created by Denis Abramov on 09/10/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import Foundation
import UIKit

class GetCacheImage: Operation {
    private let cacheLifeTime: TimeInterval = 86400
    private let url: String
    var outputImage: UIImage?
    private static let pathName: String = {
        let pathName = "image"
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return pathName }
        let url = cachesDirectory.appendingPathComponent(pathName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            print(url)
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return pathName
    }()
    private lazy var filePath: String? = {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let hasheName = String(describing: url.hashValue)
        return cachesDirectory.appendingPathComponent(GetCacheImage.pathName + "/" + hasheName).path
    }()
    init(url: String) {
        self.url = url
    }
    override func main() {
        guard filePath != nil && !isCancelled else { return }
        if getImageFormCache() { return }
        guard !isCancelled else { return }
        if !downloadImage() { return }
        guard !isCancelled else { return }
        saveImageToChache()
    }
    private func getImageFormCache() -> Bool {
        guard let fileName = filePath,
            let info = try? FileManager.default.attributesOfItem(atPath: fileName),
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date else { return false }
        let lifeTime = Date().timeIntervalSince(modificationDate)
        guard lifeTime <= cacheLifeTime,
            let image = UIImage(contentsOfFile: fileName) else { return false }
        self.outputImage = image
        return true
    }
    private func downloadImage() -> Bool {
        guard let url = URL(string: url),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) else { return false }
        self.outputImage = image
        return true
    }
    private func saveImageToChache() {
        guard let fileName = filePath, let image = outputImage else { return }
        let data = image.pngData()
        FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil)
    }
}
