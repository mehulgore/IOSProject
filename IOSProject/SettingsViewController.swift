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
    
    @IBOutlet weak var themePicker: UISegmentedControl!
    
    var startTime = ""
    var stopTime = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)
        
        
        startTimePicker.addTarget(self, action: #selector(SettingsViewController.startTimeChanged), for: UIControlEvents.valueChanged)
        stopTimePicker.addTarget(self, action: #selector(SettingsViewController.stopTimeChanged), for: UIControlEvents.valueChanged)
        
        Main.user?.getDoNotDisturbTime(type: "startTime", completion: { (value) in
            self.startTime = value
            Main.user?.getDoNotDisturbTime(type: "stopTime", completion: { (value) in
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
        })
        
        self.view.backgroundColor = Main.backgroundColor
        self.view.backgroundColor = Main.backgroundColor
        self.startTimePicker.setValue(Main.textColor, forKeyPath: "textColor")
        self.startTimePicker.setValue(false, forKey: "highlightsToday")
        self.stopTimePicker.setValue(Main.textColor, forKeyPath: "textColor")
        self.stopTimePicker.setValue(false, forKey: "highlightsToday")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().tintColor = Main.textColor
        self.navigationController!.navigationBar.barTintColor = Main.doNotDisturbCellColor
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Main.textColor]
        self.view.backgroundColor = Main.backgroundColor
        self.view.backgroundColor = Main.backgroundColor
        self.view.backgroundColor = Main.backgroundColor
        self.startTimePicker.setValue(Main.textColor, forKeyPath: "textColor")
        self.startTimePicker.setValue(false, forKey: "highlightsToday")
        self.stopTimePicker.setValue(Main.textColor, forKeyPath: "textColor")
        self.stopTimePicker.setValue(false, forKey: "highlightsToday")
        (themePicker.subviews[0] as UIView).tintColor = Main.doNotDisturbCellColor
        (themePicker.subviews[1] as UIView).tintColor = Main.doNotDisturbCellColor
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
        Main.user?.setDoNotDisturbTime(type: "startTime", time: startTime)
    }
    
    func stopTimeChanged () {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let stopTime = dateFormatter.string(from: stopTimePicker.date)
        Main.user?.setDoNotDisturbTime(type: "stopTime", time: stopTime)
    }
    
    @IBAction func themePickerChanged(_ sender: UISegmentedControl) {
        switch themePicker.selectedSegmentIndex {
        case 0:
            // default
            Main.selectedCellColor = UIColor(red: 178/255.0, green: 1.0, blue: 102/255.0, alpha: 1.0)
            Main.doNotDisturbCellColor = UIColor(red: 0.0, green: 128/255.0, blue: 1.0, alpha: 1.0)
            Main.backgroundColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 1.0)
            Main.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            Main.weeklyColor = UIColor(red: 178/255, green: 102/255, blue: 1, alpha: 1.0)
            self.viewWillAppear(false)
            //Main.reloadNavBar()
        case 1:
            // night
            Main.selectedCellColor = UIColor(red: 227/255, green: 90/255, blue: 15/255, alpha: 1.0)
            Main.doNotDisturbCellColor = UIColor(red: 238/255, green: 175/255, blue: 24/255, alpha: 1)
            Main.backgroundColor = UIColor(red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 1.0)
            Main.textColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 1.0)
            Main.weeklyColor = UIColor(red: 178/255, green: 34/255, blue: 34/255, alpha: 1.0)
            self.viewWillAppear(false)
            //Main.reloadNavBar()
        default:
            break
        }
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
