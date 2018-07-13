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
    private enum PropertyName {
        case description
        case image
        case siteName
        case title
        case type
        case url

        init?(_ meta: OpenGraph.HTML.Metadata) {
            let property = meta.property
            let content = meta.content
            if property.contains("og:description") {
                self = .description
            } else if property.contains("og:image") && content.contains("http") {
                self = .image
            } else if property.contains("og:site_name") {
                self = .siteName
            } else if property.contains("og:title") {
                self = .title
            } else if property.contains("og:type") {
                self = .type
            } else if property.contains("og:url") {
                self = .url
            } else {
                return nil
            }
        }
    }

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

    func setValue(_ html: OpenGraph.HTML) {
        html.metaList.forEach {
            guard let propertyName = PropertyName($0) else { return }
            switch propertyName  {
            case .siteName    : siteName        = $0.content
            case .type        : pageType        = $0.content
            case .title       : pageTitle       = (try? $0.unescapedContent()) ?? ""
            case .image       : imageUrl        = $0.content
            case .url         : url             = $0.content
            case .description : pageDescription = $0.content.replacingOccurrences(of: "\n", with: " ")
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
