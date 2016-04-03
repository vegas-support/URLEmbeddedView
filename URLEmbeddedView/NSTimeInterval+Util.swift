//
//  NSTimeInterval+Util.swift
//  Pods
//
//  Created by 鈴木大貴 on 2016/04/04.
//
//

import Foundation

extension NSTimeInterval {
    public var minutes: NSTimeInterval {
        return self * 60
    }
    
    public var hours: NSTimeInterval {
        return minutes * 60
    }
    
    public var days: NSTimeInterval {
        return hours * 24
    }
    
    public var weeks: NSTimeInterval {
        return days * 7
    }
    
    public var months: NSTimeInterval {
        return days * 30
    }
    
    public var years: NSTimeInterval {
        return days * 365
    }
}

extension NSNumber {
    public class func minutes(time: NSTimeInterval) -> NSTimeInterval {
        return time.minutes
    }
    
    public class func hours(time: NSTimeInterval) -> NSTimeInterval {
        return time.hours
    }
    
    public class func days(time: NSTimeInterval) -> NSTimeInterval {
        return time.days
    }
    
    public class func weeks(time: NSTimeInterval) -> NSTimeInterval {
        return time.weeks
    }
    
    public class func months(time: NSTimeInterval) -> NSTimeInterval {
        return time.months
    }
    
    public class func years(time: NSTimeInterval) -> NSTimeInterval {
        return time.years
    }
}