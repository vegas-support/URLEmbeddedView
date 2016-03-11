//
//  OGData+CoreDataProperties.swift
//  Pods
//
//  Created by 鈴木大貴 on 2016/03/12.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension OGData {

    @NSManaged var createDate: NSDate
    @NSManaged var imageUrl: String
    @NSManaged var imageUUID: String
    @NSManaged var pageDescription: String
    @NSManaged var pageTitle: String
    @NSManaged var pageType: String
    @NSManaged var siteName: String
    @NSManaged var sourceUrl: String
    @NSManaged var updateDate: NSDate
    @NSManaged var url: String
    @NSManaged var faviconImageUUID: String

}
