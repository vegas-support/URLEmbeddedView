//
//  OGDataCacheManager.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

import UIKit
import CoreData

final class OGDataCacheManager {
    static let sharedInstance = OGDataCacheManager()
    private static let TimeOfExpirationForOGDataCacheKey = "TimeOfExpirationForOGDataCache"
    private static let TimeOfUpdationForOGDataCacheKey = "TimeOfUpdationForOGDataCache"
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle(forClass: self.dynamicType).URLForResource("URLEmbeddedViewOGData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("URLEmbeddedViewOGData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "URLEmbeddedView-OGDataCache Error", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var writerManagedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.writerManagedObjectContext
        return managedObjectContext
    }()
    
    lazy var updateManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.parentContext = self.mainManagedObjectContext
        return managedObjectContext
    }()
    
//    var timeOfExpiration: NSTimeInterval {
//        get {
//            let ud = NSUserDefaults.standardUserDefaults()
//            return ud.doubleForKey(self.dynamicType.TimeOfExpirationForOGDataCacheKey)
//        }
//        set {
//            let ud = NSUserDefaults.standardUserDefaults()
//            ud.setDouble(newValue, forKey: self.dynamicType.TimeOfExpirationForOGDataCacheKey)
//            ud.synchronize()
//        }
//    }
    
    private var _timeOfUpdation: NSTimeInterval?
    var timeOfUpdation: NSTimeInterval {
        get {
            guard let _timeOfUpdation = _timeOfUpdation else {
                let ud = NSUserDefaults.standardUserDefaults()
                guard let time = (ud.objectForKey(self.dynamicType.TimeOfUpdationForOGDataCacheKey) as? NSNumber)?.doubleValue else {
                    let time: NSTimeInterval = 10.days //default 10 days
                    saveTimeOfUpdation(time)
                    self._timeOfUpdation = time
                    return time
                }
                return time
            }
            return _timeOfUpdation
        }
        set {
            saveTimeOfUpdation(newValue)
            _timeOfUpdation = newValue
        }
    }
    
    private func saveTimeOfUpdation(timeOfUpdation: NSTimeInterval) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(NSNumber(double: timeOfUpdation), forKey: self.dynamicType.TimeOfUpdationForOGDataCacheKey)
        ud.synchronize()
    }
}

extension OGDataCacheManager {
    func delete(object: NSManagedObject, completion: ((NSError?) -> Void)?) {
        object.managedObjectContext?.deleteObject(object)
        saveContext(completion)
    }
    
    func saveContext (completion: ((NSError?) -> Void)?) {
        saveContext(updateManagedObjectContext, success: { [weak self] in
            guard let mainManagedObjectContext = self?.mainManagedObjectContext else {
                completion?(NSError(domain: "mainManagedObjectContext is not avairable", code: 9999, userInfo: nil))
                return
            }
            self?.saveContext(mainManagedObjectContext, success: { [weak self] in
                guard let writerManagedObjectContext = self?.writerManagedObjectContext else {
                    completion?(NSError(domain: "writerManagedObjectContext is not avairable", code: 9999, userInfo: nil))
                    return
                }
                self?.saveContext(writerManagedObjectContext, success: {
                    completion?(nil)
                }, failure: { [weak self] in
                    self?.mainManagedObjectContext.rollback()
                    self?.updateManagedObjectContext.rollback()
                    completion?($0)
                })
            }, failure: { [weak self] in
                self?.updateManagedObjectContext.rollback()
                completion?($0)
            })
        }, failure: {
            completion?($0)
        })
    }
    
    private func saveContext(context: NSManagedObjectContext, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        if !context.hasChanges {
            success?()
        }
        context.performBlock {
            do {
                try context.save()
                success?()
            } catch let e as NSError {
                context.rollback()
                failure?(e)
            }
        }
    }
}
