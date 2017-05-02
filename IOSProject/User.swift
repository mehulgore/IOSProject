//
//  User.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/16/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase

class User {
    let ref = FIRDatabase.database().reference()
    let uid:String
    let firstName: String
    let lastName: String
    let email:String
    let fullName: String
    
    var currentSched = [Int]()
    var doNotDisturbStart = ""
    var doNotDisturbStop = ""
    
    init(uid:String, firstName: String, lastName: String, email: String) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.fullName = self.firstName + " " + self.lastName
    }
    
    func fill () {
        var temp = Main.today
        while temp.compare(Main.maxDate!) != .orderedDescending {
            self.getSchedIfNull(date: temp)
            temp = Calendar.current.date(byAdding: .day, value: 1, to: temp)!
        }
    }
    
    func firstTimeSetup (completion: @escaping () -> ()) {
        let allSchedsRef = self.ref.child("users").child(self.uid).child("schedules")
        var temp = Main.today
        while temp.compare(Main.maxDate!) != .orderedDescending {
            allSchedsRef.updateChildValues([Main.dateToString(date: temp): Main.emptyArray])
            temp = Calendar.current.date(byAdding: .day, value: 1, to: temp)!
        }
        Main.weeklyArray = Main.emptyWeeklyArray
        self.ref.child("users").child(self.uid).child("weeklyArray").setValue(Main.emptyWeeklyArray)
        self.setDoNotDisturbTime(type: "startTime", time: "12:00 AM")
        self.setDoNotDisturbTime(type: "stopTime", time: "8:00 AM")
        self.populateWithDoNotDisturb(completion: { () in
            completion()
        })
        // TODO make do not disturb populate on new registered user and set sched to display
        // to todays schedule
    }
    
    func getSchedIfNull (date: Date) {
        let dateString = Main.dateToString(date: date)
        let allSchedsRef = self.ref.child("users").child(self.uid).child("schedules")
        allSchedsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let scheds = snapshot.value as? NSDictionary {
                if (scheds[dateString] == nil) {
                    allSchedsRef.child(dateString).setValue(Main.emptyArray)
                }
            }
            else {
                allSchedsRef.child(dateString).setValue(Main.emptyArray)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setVal (index: Int, date: Date, val: Int) {
        let dateString = Main.dateToString(date: date)
        Main.schedToDisplay[index] = val
        let allSchedsRef = ref.child("users").child(self.uid).child("schedules")
        allSchedsRef.child(dateString).setValue(Main.schedToDisplay)
    }
    
    func setWeeklyVal (index: Int, date: Date, val: Int) {
        let dayNum = Main.getDayOfWeek(date: date)! - 1
        print (dayNum)
        let dayIndex = Main.timeSlots * dayNum
        let weeklyIndex = dayIndex + index
        print (weeklyIndex)
        Main.weeklyArray[weeklyIndex] = val
        self.ref.child("users").child(self.uid).child("weeklyArray").setValue(Main.weeklyArray)
    }

    func getWeeklyArray (completion: @escaping ()->Void) {
        let allSchedsRef = self.ref.child("users").child(self.uid).child("weeklyArray")
        allSchedsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let array = snapshot.value as? [Int]
            if (array != nil) {
                Main.weeklyArray = array!
                completion ()
            }
            else {
                Main.weeklyArray = Main.emptyWeeklyArray
                completion ()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getSched (date: Date, completion: @escaping ()->Void) {
        let dateString = Main.dateToString(date: date)
        let allSchedsRef = self.ref.child("users").child(self.uid).child("schedules")
        allSchedsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let scheds = snapshot.value as! NSDictionary
            if (scheds[dateString] != nil) {
                Main.schedToDisplay = (scheds[dateString] as? [Int])!
                completion()
            }
            else {
                allSchedsRef.child(dateString).setValue(Main.emptyArray)
                Main.schedToDisplay = Main.emptyArray
                completion()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func clearPast () {
        let allSchedsRef = ref.child("users").child(self.uid).child("schedules")
        let today = Main.today
        allSchedsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let scheds = snapshot.value as? NSDictionary {
                for (key, value) in scheds {
                    _ = value as! [Int]
                    let dateString = key as! String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    let date = dateFormatter.date(from: dateString)
                    let calendar = NSCalendar.current
                    
                    // Replace the hour (time) of both dates with 00:00
                    let date1 = calendar.startOfDay(for: date!)
                    let date2 = calendar.startOfDay(for: today)
                    let components = calendar.dateComponents([.day], from: date1, to: date2)
                    if (components.day! >= 1) {
                        allSchedsRef.child(dateString).removeValue()
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func onDoNotDisturbChanged (dateString: String, sched: [Int]) {
        
    }
    
    func addDoNotDisturb  (dateString: String, startTime: String, stopTime: String, array: [Int]) {
        var currSched = array
        let startIndex = Main.timeStrings.index(of: startTime)!
        let stopIndex = Main.timeStrings.index(of: stopTime)!
        var counter = startIndex
        while (counter != stopIndex) {
            if (counter == Main.timeSlots) {
                counter = 0
            }
            currSched[counter] = 3
            counter += 1
        }
        while (counter != startIndex) {
            if (currSched[counter] == 3) {
                currSched[counter] = 0
            }
            counter += 1
            if (counter == Main.timeSlots) {
                counter = 0
            }
        }
        let allSchedsRef = ref.child("users").child(self.uid).child("schedules")
        allSchedsRef.child(dateString).setValue(currSched)
    }
    
    func addWeekly (array: [Int], dateString: String) -> [Int] {
        var sched = array
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let date = dateFormatter.date(from: dateString)
        let dayNum = Main.getDayOfWeek(date: date!)! - 1
        let dayIndex = Main.timeSlots * dayNum
        for i in dayIndex ... dayIndex + Main.timeSlots - 1 {
            if (Main.weeklyArray[i] == 1)  {
                sched[i % 48] = 2
            }
        }
        return sched
    }
    
    func populateWithDoNotDisturb (completion: @escaping () -> ()) {
        let doNotDisturbRef = ref.child("users").child(self.uid).child("doNotDisturb")
        doNotDisturbRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let times = snapshot.value as! NSDictionary
            self.doNotDisturbStart = times["startTime"] as! String
            self.doNotDisturbStop = times["stopTime"] as! String
            let allSchedsRef = self.ref.child("users").child(self.uid).child("schedules")
            allSchedsRef.observeSingleEvent(of: .value, with: { (Snapshot) in
                // Get user value
                let scheds = Snapshot.value as! NSDictionary
                for (key, value) in scheds {
                    var sched = value as! [Int]
                    let dateString = key as! String
                    sched = self.addWeekly(array: sched, dateString: dateString)
                    self.addDoNotDisturb (dateString: dateString, startTime: self.doNotDisturbStart, stopTime: self.doNotDisturbStop, array: sched)
                }
                completion()
            }) { (error) in
                print(error.localizedDescription)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setDoNotDisturbTime (type: String, time: String) {
        //if ref.child("users").child(self.uid).va) == nil {
        ref.child("users").child(self.uid).child("doNotDisturb").child(type).setValue(time)
        self.populateWithDoNotDisturb(completion: {() in })
    }
    
    func getDoNotDisturbTime (type: String, completion: @escaping (String) -> Void) {
        let userRef = ref.child("users").child(self.uid)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let userDict = snapshot.value as! NSDictionary
            if (userDict["doNotDisturb"] == nil) {
                completion("")
            }
            else {
                let startOrStop = userDict["doNotDisturb"] as! NSDictionary
                //if (type == "startTime") {
                //    self.doNotDisturbStart = startOrStop[type] as! String
                //}
                //else {
                //    self.doNotDisturbStop = startOrStop[type] as! String
                //}
                completion(startOrStop[type] as! String)
            }
        })
    }
    
    func findAvailableTimes (event: String, completion: @escaping () -> ()) {
        var masterDict = fillMasterDict()
        self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as? NSDictionary
            
            let uidNode = users?[self.uid] as! [String: Any]
            let eventsNode = uidNode["events"] as! [String: Any]
            let eventNode = eventsNode[event] as! [String: Any]
            let groupName = eventNode["group"] as! String
            let duration = eventNode["duration"] as! Int
            let groupsNode = uidNode["groups"] as! [String: Any]
            let groupNode = groupsNode[groupName] as! [String: String]
            
            for (_, userID) in groupNode {
                let thisUid = users?[userID] as! [String: Any]
                let schedules = thisUid["schedules"] as! [String: [Int]]
                for (date, sched) in schedules {
                    if (masterDict?[date] != nil) {
                        masterDict = self.addToMasterDict(dict: masterDict!, date: date, array: sched)
                    }
                }
                
            }
            
        self.lookThroughMasterDict(dict: masterDict!, duration: duration, eventName: event)
        completion()
        })
        
        
    }
    
    func addToMasterDict (dict: [String: [Int]], date: String, array: [Int]) -> [String: [Int]]? {
        var result = dict
        var temp = result[date]
        for (index, element) in (array.enumerated()) {
            temp?[index] += element
        }
        
        result[date] = temp
        return result
    }
    
    
    func fillMasterDict () -> [String: [Int]]? {
        var result: [String: [Int]] = [:]
        var temp = Main.today
        while temp.compare(Main.maxDate!) != .orderedDescending {
            result[Main.dateToString(date: temp)] = Main.emptyArray
            temp = Calendar.current.date(byAdding: .day, value: 1, to: temp)!
        }
        return result
    }
    
    func lookThroughMasterDict (dict: [String: [Int]], duration: Int, eventName: String) {
        var result: [String: [String: String]] = [:]
        let slotsToSearch = duration * 2
        for (date, sched) in dict {
            var startIndex = 0
            var endIndex = 0
            var count = 0
            for (index, element) in sched.enumerated() {
                if (element == 0 && index != Main.timeSlots - 1) {
                    count += 1
                }
                else {
                    if (count > slotsToSearch) {
                        endIndex = index
                        startIndex = index - count
                        if (startIndex < 0) {
                            startIndex = 0
                        }
                        if (endIndex == Main.timeSlots - 1) {
                            endIndex = 0
                        }
                        if (startIndex == Main.timeSlots - 1) {
                            startIndex = 0
                        }
                        if result[date] == nil {
                            result[date] = [Main.timeStrings[startIndex] : Main.timeStrings[endIndex]]
                        }
                        else {
                            var inner = result[date]
                            inner?[Main.timeStrings[startIndex]] = Main.timeStrings[endIndex]
                            result[date] = inner
                        }
                    }
                    count = 0
                }
                
            }
        }
        self.ref.child("users").child(self.uid).child("events").child(eventName).child("availableTimes").setValue(result)
    }
    
}
