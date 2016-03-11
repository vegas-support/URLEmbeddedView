//
//  ImageCacheManager.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

import UIKit

class ImageCacheManager: NSObject {
    static let sharedInstance = ImageCacheManager()
    
    private let fileManager = NSFileManager()
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        print(urls)
        return urls[urls.count-1]
    }()
    private lazy var cacheDirectory: String = {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        return (paths[paths.count-1] as NSString).stringByAppendingPathComponent("images")
    }()
    
    private override init() {
        super.init()
        createDirectoriesIfNeeded()
    }
}

//MARK: - Create directories
extension ImageCacheManager {
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
                    try fileManager.createDirectoryAtPath(cacheDirectory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    continue
                }
            }
        }
    }
}

extension ImageCacheManager {
    func pathForUUIDString(uuidString: String) -> String {
        if uuidString.characters.count < 2 { return "" }
        return cacheDirectory + "/" +  uuidString.substringToIndex(uuidString.startIndex.advancedBy(2)) + "/" + uuidString
    }
    
    func cachedImage(uuidString uuidString: String) -> UIImage? {
        let image = UIImage(contentsOfFile: pathForUUIDString(uuidString))
        
        return image
    }
    
    func storeImage(image: UIImage, data: NSData, uuidString: String) -> Bool {
        let path = pathForUUIDString(uuidString)
        return data.writeToFile(path, atomically: false)
    }
}