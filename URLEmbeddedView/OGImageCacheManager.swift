//
//  OGImageCacheManager.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

import UIKit

class OGImageCacheManager {
    static let sharedInstance = OGImageCacheManager()
    
    private let fileManager = NSFileManager()
    private lazy var memoryCache: NSCache = {
        let cache = NSCache()
        cache.countLimit = 30
        return cache
    }()
    private lazy var cacheDirectory: String = {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        return (paths[paths.count-1] as NSString).stringByAppendingPathComponent("images")
    }()
    
    private init() {
        createDirectoriesIfNeeded()
    }
}

//MARK: - Create directories
extension OGImageCacheManager {
    private func createDirectoriesIfNeeded() {
        createRootDirectoryIfNeeded()
        createSubDirectoriesIfNeeded()
    }
    
    private func createRootDirectoryIfNeeded() {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExistsAtPath(cacheDirectory, isDirectory: &isDirectory)
        if exists && isDirectory { return }
        do {
            try fileManager.createDirectoryAtPath(cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {}
    }
    
    private func createSubDirectoriesIfNeeded() {
        for i in 0..<16 {
            for j in 0..<16 {
                let directoryName = String(format: "%@/%x%x", self.cacheDirectory, i, j)
                var isDirectory: ObjCBool = false
                let exists = fileManager.fileExistsAtPath(directoryName, isDirectory: &isDirectory)
                if exists && isDirectory { continue }
                do {
                    try fileManager.createDirectoryAtPath(directoryName, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    continue
                }
            }
        }
    }
}

//MARK: - Read and write
extension OGImageCacheManager {
    private func pathForUUIDString(uuidString: String) -> String {
        if uuidString.characters.count < 2 { return "" }
        return cacheDirectory + "/" +  uuidString.substringToIndex(uuidString.startIndex.advancedBy(2)) + "/" + uuidString
    }
    
    func cachedImage(uuidString uuidString: String) -> UIImage? {
        if let image = memoryCache.objectForKey(uuidString) as? UIImage {
            return image
        }
        if let image = UIImage(contentsOfFile: pathForUUIDString(uuidString)) {
            memoryCache.setObject(image, forKey: uuidString)
            return image
        }
        return nil
    }
    
    func storeImage(image: UIImage, data: NSData, uuidString: String) {
        memoryCache.setObject(image, forKey: uuidString)
        data.writeToFile(pathForUUIDString(uuidString), atomically: false)
    }
}

//MARK: - Cache clear
extension OGImageCacheManager {
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    func clearAllCache() {
        clearMemoryCache()
        if !fileManager.fileExistsAtPath(cacheDirectory) {
            createDirectoriesIfNeeded()
            return
        }
        do {
            try fileManager.removeItemAtPath(cacheDirectory)
            createDirectoriesIfNeeded()
        } catch {}
    }
}