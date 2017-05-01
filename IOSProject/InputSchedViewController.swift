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
        
        UINavigationBar.appearance().tintColor = Main.textColor
        UINavigationBar.appearance().barTintColor = Main.doNotDisturbCellColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Main.textColor]
        self.view.backgroundColor = Main.backgroundColor
        self.reload()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Main.user?.populateWithDoNotDisturb(completion: { () in
            Main.user?.getSched(date: Main.today, completion: { () in
                UINavigationBar.appearance().tintColor = Main.textColor
                UINavigationBar.appearance().barTintColor = Main.doNotDisturbCellColor
                UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Main.textColor]
                self.view.backgroundColor = Main.backgroundColor
                self.datePicker.setValue(Main.textColor, forKeyPath: "textColor")
                self.datePicker.setValue(false, forKey: "highlightsToday")
                self.scheduleTableView.reloadData()
            })
        })
    }
    
    
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
        clickedCell(tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        clickedCell(tableView, indexPath: indexPath)
    }
    
    func clickedCell (_ tableView: UITableView, indexPath: IndexPath) {
        let cell = scheduleTableView.cellForRow(at: indexPath) as! SchedTableViewCell
        cell.toggleCell()
        if (cell.count == 0){
            Main.user?.setWeeklyVal (index: indexPath.row, date: datePicker.date, val: 0)
            cell.backgroundColor = Main.backgroundColor
            cell.textLabel?.textColor = Main.textColor
            cell.isSelected = false
            cell.setSelected(false, animated: false)
        }
        if (cell.count == 1) {
            cell.isSelected = true
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            cell.contentView.backgroundColor = Main.selectedCellColor
            cell.textLabel?.textColor = Main.textColor
        }
        if (cell.count == 2) {
            Main.user?.setWeeklyVal (index: indexPath.row, date: datePicker.date, val: 1)
            cell.isSelected = true
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            cell.contentView.backgroundColor = Main.weeklyColor
            cell.textLabel?.textColor = Main.textColor
        }
        Main.user?.setVal(index: indexPath.row, date: datePicker.date, val: cell.count)
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
            cell.backgroundColor = Main.backgroundColor
            cell.textLabel?.textColor = Main.textColor
            cell.isSelected = false
            cell.setSelected(false, animated: false)
            break
        case 1:
            cell.isSelected = true
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            cell.contentView.backgroundColor = Main.selectedCellColor
            cell.textLabel?.textColor = Main.textColor
            break
        case 3:
            cell.isSelected = true
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            cell.contentView.backgroundColor = Main.doNotDisturbCellColor
            cell.textLabel?.textColor = Main.textColor
            break
        case 2:
            cell.isSelected = true
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
            cell.contentView.backgroundColor = Main.weeklyColor
            cell.textLabel?.textColor = Main.textColor
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
 }
