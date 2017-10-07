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
    fileprivate enum PropertyName: String {
        case description = "og:description"
        case image       = "og:image"
        case siteName    = "og:site_name"
        case title       = "og:title"
        case type        = "og:type"
        case url         = "og:url"
    }

    class func fetchOrInsertOGData(url: String) -> OGData {
        guard let ogData = fetchOGData(url: url) else {
            let managedObjectContext = OGDataCacheManager.shared.updateManagedObjectContext
            let newOGData = NSEntityDescription.insertNewObject(forEntityName: "OGData", into: managedObjectContext) as! OGData
            let date = Date()
            newOGData.createDate = date
            newOGData.updateDate = date
            return newOGData
        }
        return ogData
    }
    
    class func fetchOGData(url: String) -> OGData? {
        let managedObjectContext = OGDataCacheManager.shared.updateManagedObjectContext
        let fetchRequest = NSFetchRequest<OGData>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "OGData", in: managedObjectContext)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "sourceUrl = %@", url)
        let fetchedList = (try? managedObjectContext.fetch(fetchRequest))
        return fetchedList?.first
    }

    func setValue(_ html: OpenGraph.HTML) {
        for meta in html.metaList {
            guard let propertyName = PropertyName(rawValue: meta.property) else { return }
            switch propertyName  {
            case .siteName    : siteName        = meta.content
            case .type        : pageType        = meta.content
            case .title       : pageTitle       = meta.content
            case .image       : imageUrl        = meta.content
            case .url         : url             = meta.content
            case .description : pageDescription = meta.content.replacingOccurrences(of: "\n", with: " ")
            }
        }
    }
    
    func setValue(_ youtube: OpenGraph.Youtube) {
        self.pageTitle = youtube.title
        self.pageType = youtube.type
        self.siteName = youtube.providerName
        self.imageUrl = youtube.thumbnailUrl
    }
    
    func save() {
        updateDate = Date()
        OGDataCacheManager.shared.saveContext(nil)
    }
}
