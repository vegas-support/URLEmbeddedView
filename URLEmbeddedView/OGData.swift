//
//  OGData.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

import Foundation
import CoreData

public final class OGData: NSManagedObject {
    private enum PropertyName: String {
        case Description = "og:description"
        case Image       = "og:image"
        case SiteName    = "og:site_name"
        case Title       = "og:title"
        case Type        = "og:type"
        case Url         = "og:url"
    }
    
    private lazy var URL: NSURL? = {
        return NSURL(string: self.sourceUrl)
    }()

    class func fetchOrInsertOGData(url url: String) -> OGData {
        guard let ogData = fetchOGData(url: url) else {
            let managedObjectContext = OGDataCacheManager.sharedInstance.updateManagedObjectContext
            let newOGData = NSEntityDescription.insertNewObjectForEntityForName("OGData", inManagedObjectContext: managedObjectContext) as! OGData
            let date = NSDate()
            newOGData.createDate = date
            newOGData.updateDate = date
            return newOGData
        }
        return ogData
    }
    
    class func fetchOGData(url url: String) -> OGData? {
        let managedObjectContext = OGDataCacheManager.sharedInstance.updateManagedObjectContext
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("OGData", inManagedObjectContext: managedObjectContext)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "sourceUrl = %@", url)
        let fetchedList = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [OGData]
        return fetchedList?.first
    }
    
    func setValue(property property: String, content: String) {
        guard let propertyName = PropertyName(rawValue: property) else { return }
        switch propertyName  {
        case .SiteName    : siteName        = content
        case .Type        : pageType        = content
        case .Title       : pageTitle       = content
        case .Image       : imageUrl        = content
        case .Url         : url             = content
        case .Description : pageDescription = content.stringByReplacingOccurrencesOfString("\n", withString: " ")
        }
    }
    
    func save() {
        updateDate = NSDate()
        OGDataCacheManager.sharedInstance.saveContext(nil)
    }
}