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

    var currentSched = [Int]()
    var doNotDisturbStart = ""
    var doNotDisturbStop = ""
    
    init(uid:String, firstName: String, lastName: String, email: String) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    func fill () {
        var temp = Main.today
        print ("in fill the time is \(temp)")
        while temp.compare(Main.maxDate!) != .orderedDescending {
            self.getSchedIfNull(date: temp)
            temp = Calendar.current.date(byAdding: .day, value: 1, to: temp)!
        }
    }
    
    func firstTimeSetup () {
        let allSchedsRef = self.ref.child("users").child(self.uid).child("schedules")
        var temp = Main.today
        print ("in first time setup today is \(temp)")
        while temp.compare(Main.maxDate!) != .orderedDescending {
            allSchedsRef.updateChildValues([Main.dateToString(date: temp): Main.emptyArray])
            temp = Calendar.current.date(byAdding: .day, value: 1, to: temp)!
        }
        self.setDoNotDisturbTime(type: "startTime", time: "12:00 AM")
        self.setDoNotDisturbTime(type: "stopTime", time: "8:00 AM")
        self.populateWithDoNotDisturb()
        
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
    
    func toggleEntry (index: Int, date: Date) {
        let dateString = Main.dateToString(date: date)
        Main.schedToDisplay[index] += 1
        if (Main.schedToDisplay[index] >= Main.numOptions) {
            Main.schedToDisplay[index] = 0
        }
        let allSchedsRef = ref.child("users").child(self.uid).child("schedules")
        allSchedsRef.child(dateString).setValue(Main.schedToDisplay)
    }
    
    func getSched (date: Date, completion: @escaping ()->Void) {
        let dateString = Main.dateToString(date: date)
        let allSchedsRef = self.ref.child("users").child(self.uid).child("schedules")
        allSchedsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print(dateString)
            let scheds = snapshot.value as! NSDictionary
            //print(scheds)
            if (scheds[dateString] != nil) {
                print("getsched: schedule for \(dateString) is in the database")
                //print(scheds[dateString] ?? "array")
                //self.currentSched = (scheds[dateString] as? [Int])!
                Main.schedToDisplay = (scheds[dateString] as? [Int])!
                completion()
            }
            else {
                allSchedsRef.child(dateString).setValue(Main.emptyArray)
                print("getsched: schedule for \(dateString) is NOT THERE")
                //print(scheds[dateString] ?? "array is nil")
                Main.schedToDisplay = Main.emptyArray
                completion()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func clearPast () {
        let allSchedsRef = ref.child("users").child(self.uid).child("schedules")
        let today = Main.getLocalTime()
        print ("in clear past function todays date is \(today)")
        allSchedsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let scheds = snapshot.value as? NSDictionary {
            for (key, value) in scheds {
                _ = value as! [Int]
                let dateString = key as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let date = dateFormatter.date(from: key as! String)
                if (date?.compare(today) == .orderedAscending) {
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
            currSched[counter] = 2
            counter += 1
        }
        while (counter != startIndex) {
            if (counter == Main.timeSlots) {
                counter = 0
            }
            if (currSched[counter] == 2) {
                currSched[counter] = 0
            }
            counter += 1
        }
        let allSchedsRef = ref.child("users").child(self.uid).child("schedules")
        allSchedsRef.child(dateString).setValue(currSched)
    }
    
    func populateWithDoNotDisturb () {
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
                    let sched = value as! [Int]
                    let dateString = key as! String
                    print (key)
                    self.addDoNotDisturb (dateString: dateString, startTime: self.doNotDisturbStart, stopTime: self.doNotDisturbStop, array: sched)
                }
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
        print ("set a time to \(time)")
        self.populateWithDoNotDisturb()
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
    
}
