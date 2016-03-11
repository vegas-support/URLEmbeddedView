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

    @NSManaged public var createDate: NSDate
    @NSManaged public var imageUrl: String
    @NSManaged public var imageUUID: String
    @NSManaged public var pageDescription: String
    @NSManaged public var pageTitle: String
    @NSManaged public var pageType: String
    @NSManaged public var siteName: String
    @NSManaged public var sourceUrl: String
    @NSManaged public var updateDate: NSDate
    @NSManaged public var url: String
    @NSManaged public var faviconImageUUID: String

}
