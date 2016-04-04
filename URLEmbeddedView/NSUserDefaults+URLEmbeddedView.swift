//
//  NSUserDefaults+URLEmbeddedView.swift
//  Pods
//
//  Created by 鈴木大貴 on 2016/04/05.
//
//

import Foundation

extension NSUserDefaults {
    private static let UpdateIntervalForOGDataCacheKey = "UpdateIntervalForOGDataCache"
    
    var updateIntervalForOGData: NSTimeInterval? {
        get {
            let ud = NSUserDefaults.standardUserDefaults()
            guard let interval = (ud.objectForKey(self.dynamicType.UpdateIntervalForOGDataCacheKey) as? NSNumber)?.doubleValue else {
                return nil
            }
            return interval
        }
        set {
            guard let interval = newValue else { return }
            let ud = NSUserDefaults.standardUserDefaults()
            ud.setObject(NSNumber(double: interval), forKey: self.dynamicType.UpdateIntervalForOGDataCacheKey)
            ud.synchronize()
        }
    }
}