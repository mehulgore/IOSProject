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
    let numOptions = 2
    let timeSlots = 48
    let numDays = 14
    let emptyArray =  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    let uid:String
    let firstName: String
    let lastName: String
    let email:String
    //let friends: [User]?
    //let schedules: NSDictionary
    var currentSched = [Int]()
    let minDate: Date
    let maxDate: Date
    var doNotDisturbStart = ""
    var doNotDisturbStop = ""
    
    init(uid:String, firstName: String, lastName: String, email: String, minDate: Date, maxDate: Date) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        //self.friends = []
        //self.schedules = NSDictionary()
        self.minDate = minDate
        self.maxDate = maxDate
    }
    
    func fill () {
        var temp = self.minDate
        while temp.compare(self.maxDate) != .orderedDescending {
            self.getSchedIfNull(date: temp)
            temp = Calendar.current.date(byAdding: .day, value: 1, to: temp)!
        }
    }
    
    func getSchedIfNull (date: Date) {
        let dateString = dateToString(date: date)
        let allSchedsRef = self.ref.child("users").child(self.uid).child("schedules")
        // dont know how to handle this closure shit
        allSchedsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let scheds = snapshot.value as! NSDictionary
            if (scheds[dateString] == nil) {
                allSchedsRef.child(dateString).setValue(self.emptyArray)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func toggleEntry (index: Int, date: Date) {
        let dateString = dateToString(date: date)
        InputSchedViewController.schedToDisplay[index] += 1
        if (InputSchedViewController.schedToDisplay[index] >= numOptions) {
            InputSchedViewController.schedToDisplay[index] = 0
        }
        let allSchedsRef = ref.child("users").child(self.uid).child("schedules")
        allSchedsRef.child(dateString).setValue(InputSchedViewController.schedToDisplay)
    }
    
    func getSched (date: Date, completion: @escaping ()->Void) {
        let dateString = dateToString(date: date)
        let allSchedsRef = self.ref.child("users").child(self.uid).child("schedules")
        // dont know how to handle this closure shit
        allSchedsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print ("PRINTING SHIT HERE LOOK")
            print(dateString)
            let scheds = snapshot.value as! NSDictionary
            //print(scheds)
            if (scheds[dateString] != nil) {
                print("schedule for \(dateString) is in the database")
                //print(scheds[dateString] ?? "array")
                //self.currentSched = (scheds[dateString] as? [Int])!
                InputSchedViewController.schedToDisplay = (scheds[dateString] as? [Int])!
                completion()
            }
            else {
                allSchedsRef.child(dateString).setValue(self.emptyArray)
                print("schedule for \(dateString) is NOT THERE SHIT")
                //print(scheds[dateString] ?? "array is nil")
                InputSchedViewController.schedToDisplay = self.emptyArray
                completion()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func dateToString (date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    private func getLocalTime () -> Date {
        let today = Date()
        print (today)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let local = dateFormatter.string(from: today)
        print (local)
        return dateFormatter.date(from: local)!
    }
    
    func clearPast () {
        let allSchedsRef = ref.child("users").child(self.uid).child("schedules")
        let today = getLocalTime()
        allSchedsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let scheds = snapshot.value as! NSDictionary
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
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func onDoNotDisturbChanged (dateString: String, sched: [Int]) {

 }
    
    func addDoNotDisturb  (dateString: String, startTime: String, stopTime: String, array: [Int]) {
        var currSched = array
        let startIndex = InputSchedViewController.timeStrings.index(of: startTime)!
        let stopIndex = InputSchedViewController.timeStrings.index(of: stopTime)!
        var counter = startIndex
        while (counter != stopIndex) {
            if (counter == self.timeSlots) {
                counter = 0
            }
            currSched[counter] = 2
            counter += 1
        }
        while (counter != startIndex) {
            if (counter == self.timeSlots) {
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
