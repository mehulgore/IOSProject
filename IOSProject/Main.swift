//
//  Main.swift
//  IOSProject
//
//  Created by Mehul Gore on 4/6/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import Foundation

class Main {
    internal static var user: User? = nil
    internal static var schedToDisplay = [Int]()
    internal static var timeStrings =
        ["12:00 AM", "12:30 AM", "1:00 AM", "1:30 AM",
         "2:00 AM", "2:30 AM", "3:00 AM", "3:30 AM",
         "4:00 AM", "4:30 AM", "5:00 AM", "5:30 AM",
         "6:00 AM", "6:30 AM", "7:00 AM", "7:30 AM",
         "8:00 AM", "8:30 AM", "9:00 AM", "9:30 AM",
         "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM",
         
         "12:00 PM", "12:30 PM", "1:00 PM", "1:30 PM",
         "2:00 PM", "2:30 PM", "3:00 PM", "3:30 PM",
         "4:00 PM", "4:30 PM", "5:00 PM", "5:30 PM",
         "6:00 PM", "6:30 PM", "7:00 PM", "7:30 PM",
         "8:00 PM", "8:30 PM", "9:00 PM", "9:30 PM",
         "10:00 PM", "10:30 PM", "11:00 PM", "11:30 PM"]
    
    internal static var numOptions = 2
    internal static var timeSlots = 48
    internal static var numDays = 14
    internal static var emptyArray =  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    internal static var rawDate = Date()
    internal static var today = rawDate.getLocalTime()
    internal static var maxDate = Calendar.current.date(byAdding: .day, value: Main.numDays, to: today)
    
    internal static func dateToString (date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

// adds these methods to the NSDate class
extension Date {
    // return local time date object
    func getLocalTime() -> Date {
        // set time zone
        let timeZone = NSTimeZone.local
        // used to set granularity of time
        let seconds : TimeInterval = Double(timeZone.secondsFromGMT(for:self as Date))
        // convert from absolute to local time
        let localDate = Date(timeInterval: seconds, since: self as Date)
        // return localDate
        return localDate
    }
}
