//
//  OGData.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

import Foundation
import CoreData

@objc public final class OGData: NSManagedObject {

    class func fetchOrInsertOGData(url: String,
                                   managedObjectContext: NSManagedObjectContext = OGDataCacheManager.shared.updateManagedObjectContext,
                                   completion: @escaping (OGData) -> ()) {
        fetchOGData(url: url, managedObjectContext: managedObjectContext) { ogData in
            if let ogData = ogData {
                completion(ogData)
            }
            let newOGData = NSEntityDescription.insertNewObject(forEntityName: "OGData", into: managedObjectContext) as! OGData
            let date = Date()
            newOGData.createDate = date
            newOGData.updateDate = date
            completion(newOGData)
        }
    }
    
    class func fetchOGData(url: String,
                           managedObjectContext: NSManagedObjectContext = OGDataCacheManager.shared.updateManagedObjectContext,
                           completion: @escaping (OGData?) -> ()) {
        managedObjectContext.perform {
            let fetchRequest = NSFetchRequest<OGData>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "OGData", in: managedObjectContext)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "sourceUrl = %@", url)
            let fetchedList = (try? managedObjectContext.fetch(fetchRequest))
            completion(fetchedList?.first)
        }
    }

    func update(with ogData: OpenGraph.Data) -> Bool {
        var changed: Bool = false
        if let newValue = ogData.imageUrl?.absoluteString, newValue != imageUrl {
            self.imageUrl = newValue
            changed = true
        }
        if let newValue = ogData.pageDescription, newValue != pageDescription {
            self.pageDescription = newValue
            changed = true
        }
        if let newValue = ogData.pageTitle, newValue != pageTitle {
            self.pageTitle = newValue
            changed = true
        }
        if let newValue = ogData.pageType, newValue != pageType {
            self.pageType = newValue
            changed = true
        }
        if let newValue = ogData.siteName, newValue != siteName {
            self.siteName = newValue
            changed = true
        }
        if let newValue = ogData.sourceUrl?.absoluteString, newValue != sourceUrl {
            self.sourceUrl = newValue
            changed = true
        }
        if let newValue = ogData.url?.absoluteString, newValue != url {
            self.url = newValue
            changed = true
        }
        return changed
    }
    
    func save() {
        updateDate = Date()
        OGDataCacheManager.shared.saveContext(nil)
    }
}
