//
//  OGImageCacheManager.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

/*
 * In this file, CommonCrypto is used to create md5 hash.
 * CommonCrypto is created by Marcin Krzyżanowski.
 * https://github.com/krzyzanowskim/CryptoSwift
 * The original copyright is here.
 */

/*
 * Copyright (C) 2014 Marcin Krzyżanowski marcin.krzyzanowski@gmail.com
 * This software is provided 'as-is', without any express or implied warranty.
 *
 * In no event will the authors be held liable for any damages arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 *
 * - The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
 *   If you use this software in a product, an acknowledgment in the product documentation is required.
 * - Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * - This notice may not be removed or altered from any source or binary distribution.
 */

import UIKit
import CryptoSwift

class OGImageCacheManager {
    static let sharedInstance = OGImageCacheManager()
    private static let TimeOfExpirationForOGImageCacheKey = "TimeOfExpirationForOGImageCache"
    
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
    
//    var timeOfExpiration: NSTimeInterval {
//        get {
//            let ud = NSUserDefaults.standardUserDefaults()
//            return ud.doubleForKey(self.dynamicType.TimeOfExpirationForOGImageCacheKey)
//        }
//        set {
//            let ud = NSUserDefaults.standardUserDefaults()
//            ud.setDouble(newValue, forKey: self.dynamicType.TimeOfExpirationForOGImageCacheKey)
//            ud.synchronize()
//        }
//    }
    
    private init() {
        createDirectoriesIfNeeded()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.dynamicType.didReceiveMemoryWarning(_:)), name: UIApplicationDidReceiveMemoryWarningNotification , object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
    
    dynamic func didReceiveMemoryWarning(notification: NSNotification) {
        clearMemoryCache()
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
    private func pathForURLString(urlString: String) -> String {
        let md5String = urlString.md5()
        if md5String.characters.count < 2 { return cacheDirectory + "/" }
        return cacheDirectory + "/" +  md5String.substringToIndex(md5String.startIndex.advancedBy(2)) + "/" + md5String
    }
    
    func cachedImage(urlString urlString: String) -> UIImage? {
        if let image = memoryCache.objectForKey(urlString) as? UIImage {
            return image
        }
        if let image = UIImage(contentsOfFile: pathForURLString(urlString)) {
            memoryCache.setObject(image, forKey: urlString)
            return image
        }
        return nil
    }
    
    func storeImage(image: UIImage, data: NSData, urlString: String) {
        memoryCache.setObject(image, forKey: urlString)
        data.writeToFile(pathForURLString(urlString), atomically: false)
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