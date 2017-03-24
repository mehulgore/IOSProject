//
//  SettingsViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/19/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    @IBOutlet weak var stopTimePicker: UIDatePicker!
    
    var user: User? = nil
    
    var startTime = ""
    var stopTime = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)
        
        startTimePicker.addTarget(self, action: #selector(SettingsViewController.startTimeChanged), for: UIControlEvents.valueChanged)
        stopTimePicker.addTarget(self, action: #selector(SettingsViewController.stopTimeChanged), for: UIControlEvents.valueChanged)
        
        InputSchedViewController.user?.getDoNotDisturbTime(type: "startTime", completion: { (value) in
            self.startTime = value
        })
        InputSchedViewController.user?.getDoNotDisturbTime(type: "stopTime", completion: { (value) in
            self.stopTime = value
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            let startTimeAsDate = dateFormatter.date(from: self.startTime)
            let stopTimeAsDate = dateFormatter.date(from: self.stopTime)
            self.startTimePicker.date = startTimeAsDate!
            self.stopTimePicker.date = stopTimeAsDate!
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toggleMenu"), object: nil)
    }

    func startTimeChanged () {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let startTime = dateFormatter.string(from: startTimePicker.date)
        print ("new start time should be \(startTime)") 
        InputSchedViewController.user?.setDoNotDisturbTime(type: "startTime", time: startTime)
    }
    
    func stopTimeChanged () {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let stopTime = dateFormatter.string(from: stopTimePicker.date)
        InputSchedViewController.user?.setDoNotDisturbTime(type: "stopTime", time: stopTime)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
