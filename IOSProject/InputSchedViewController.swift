 //
 //  Main.swift
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
    // properties
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    var isSidebarShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).tabBar = self.tabBarController
        
        scheduleTableView.allowsMultipleSelection = true
        
        let today = Main.today
        let maxDate = Calendar.current.date(byAdding: .day, value: Main.numDays, to: today)
        datePicker.minimumDate = today
        datePicker.maximumDate = maxDate
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)
        datePicker.addTarget(self, action: #selector(InputSchedViewController.dateChanged), for: UIControlEvents.valueChanged)
        
        self.reload()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Main.user?.populateWithDoNotDisturb(completion: { () in
            Main.user?.getSched(date: Main.today, completion: { () in
                self.scheduleTableView.reloadData()
            })
        })
    }
    
    // need to reload everytime tab view is switched
    //override func viewDidAppear(_ animated: Bool) {
    //    self.reload()
    //}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // converts from absolute time and returns standard local time
    
    // toggles navigation panel from the left
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
        let cell = scheduleTableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(red: 178/255.0, green: 1.0, blue: 102/255.0, alpha: 1.0)
        Main.user?.toggleEntry(index: indexPath.row, date: datePicker.date)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        Main.user?.toggleEntry(index: indexPath.row, date: datePicker.date)
    }
    
    func dateChanged () {
        Main.user?.getSched(date: datePicker.date, completion: { () in
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
        return Main.schedToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        cell = self.scheduleTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = Main.timeStrings[indexPath.row]
        switch Main.schedToDisplay[indexPath.row] {
        case 0:
            cell.isSelected = false
            cell.setSelected(false, animated: false)
            break
        case 1:
            cell.isSelected = true
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            cell.contentView.backgroundColor = UIColor(red: 178/255.0, green: 1.0, blue: 102/255.0, alpha: 1.0)
            break
        case 2:
            cell.isSelected = true
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            cell.contentView.backgroundColor = UIColor(red: 0.0, green: 128/255.0, blue: 1.0, alpha: 1.0)
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
