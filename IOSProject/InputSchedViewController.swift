//
//  InputSchedViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/9/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class InputSchedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var scheduleTableView: UITableView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var isSidebarShowing = false
    
    var daysToDisplay = 14
    
    internal static var user: User? = nil
    
    internal static var schedToDisplay = [Int]()
    
    internal static var timeStrings =
        ["12:00 AM",
         "12:30 AM",
         "1:00 AM",
         "1:30 AM",
         "2:00 AM",
         "2:30 AM",
         "3:00 AM",
         "3:30 AM",
         "4:00 AM",
         "4:30 AM",
         "5:00 AM",
         "5:30 AM",
         "6:00 AM",
         "6:30 AM",
         "7:00 AM",
         "7:30 AM",
         "8:00 AM",
         "8:30 AM",
         "9:00 AM",
         "9:30 AM",
         "10:00 AM",
         "10:30 AM",
         "11:00 AM",
         "11:30 AM",
         
         "12:00 PM",
         "12:30 PM",
         "1:00 PM",
         "1:30 PM",
         "2:00 PM",
         "2:30 PM",
         "3:00 PM",
         "3:30 PM",
         "4:00 PM",
         "4:30 PM",
         "5:00 PM",
         "5:30 PM",
         "6:00 PM",
         "6:30 PM",
         "7:00 PM",
         "7:30 PM",
         "8:00 PM",
         "8:30 PM",
         "9:00 PM",
         "9:30 PM",
         "10:00 PM",
         "10:30 PM",
         "11:00 AM",
         "11:30 PM"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleTableView.allowsMultipleSelection = true
        
        let today = Date()
        let maxDate = Calendar.current.date(byAdding: .day, value: self.daysToDisplay, to: today)
        datePicker.minimumDate = today
        datePicker.maximumDate = maxDate
        print (datePicker.minimumDate!)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)
        datePicker.addTarget(self, action: #selector(InputSchedViewController.dateChanged), for: UIControlEvents.valueChanged)
        
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            print ("NO USER SIGNED IN")
            return
        }
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let nodes = snapshot.value as? NSDictionary
            //print(nodes ?? "NODES")
            let firstName = nodes?["firstName"] as? String ?? "default first name"
            let lastName = nodes?["lastName"] as? String ?? "default last name"
            let email = nodes?["email"] as? String ?? "default email"
            
            InputSchedViewController.user = User(uid: currentUser.uid, firstName: firstName, lastName: lastName, email: email, minDate: self.datePicker.minimumDate!,
                                                 maxDate: self.datePicker.maximumDate!)
            
            InputSchedViewController.user?.getDoNotDisturbTime(type: "startTime",
                                                               completion: { (value) in
                                                                if (value == "") {
                                                                    InputSchedViewController.user?.setDoNotDisturbTime(type: "startTime", time: "12:00 AM")
                                                                    InputSchedViewController.user?.setDoNotDisturbTime(type: "stopTime", time: "8:00 AM")
                                                                }
                                                                InputSchedViewController.user?.clearPast()
                                                                InputSchedViewController.user?.fill()
                                                                InputSchedViewController.user?.getSched(date: today, completion: { () in
                                                                    self.reload()
                                                                })
            })
        }) { (error) in
            print(error.localizedDescription)
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toggleMenu"), object: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        InputSchedViewController.user?.toggleEntry(index: indexPath.row, date: datePicker.date)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        InputSchedViewController.user?.toggleEntry(index: indexPath.row, date: datePicker.date)
    }
    
    func dateChanged () {
        print ("date changed to \(datePicker.date)")
        InputSchedViewController.user?.getSched(date: datePicker.date, completion: { () in
            print (InputSchedViewController.schedToDisplay)
            self.reload()
        })
    }
    
    func reload () {
        if let selectedRows = self.scheduleTableView.indexPathsForSelectedRows {
            self.scheduleTableView.reloadData()
            for index in selectedRows {
                self.scheduleTableView.selectRow(at: index, animated: false, scrollPosition: UITableViewScrollPosition.none)
            }
        }
        else {
            self.scheduleTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(InputSchedViewController.schedToDisplay)
        return InputSchedViewController.schedToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        cell = self.scheduleTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = InputSchedViewController.timeStrings[indexPath.row]
        switch InputSchedViewController.schedToDisplay[indexPath.row] {
        case 0:
            cell.isSelected = false
            cell.setSelected(false, animated: false)
            break
        case 1:
            cell.isSelected = true
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected {
            cell.setSelected(true, animated: false)
        } else {
            cell.setSelected(false, animated: false)
        }
    }
    
//    func timeFromIndex (index: Int) -> String {
//        var hourOffset = ""
//        var numBeforeColon = index / 2
//        let numAfterColon = index % 2
//        var when = "AM"
//        if (numBeforeColon == 12) {
//            when = "PM"
//        }
//        if (numBeforeColon == 0) {
//            numBeforeColon += 12
//        }
//        if (numBeforeColon > 12) {
//            numBeforeColon -= 12
//            when = "PM"
//        }
//        if (numAfterColon == 0) {
//            hourOffset = ":00"
//        }
//        else {
//            hourOffset = ":30"
//        }
//        return "\(numBeforeColon)\(hourOffset) \(when)"
//        
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
}
