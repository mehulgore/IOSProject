//
//  EventDetailViewController.swift
//  IOSProject
//
//  Created by Jully Zhu on 3/24/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var eventNameLabel: UILabel!
    
    @IBOutlet weak var availableTimesTableView: UITableView!
    
    var eventName = ""
    var availableTimes: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        availableTimesTableView.delegate = self
        availableTimesTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        eventNameLabel.text = eventName
        FIRDatabase.database().reference().child("users").child((Main.user?.uid)!).child("events").child(eventName).child("availableTimes").observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                self.availableTimes = []
                return
            }
            
            let dict = snapshot.value as! NSDictionary
            for (date, times) in dict {
                let dateString = date as! String
                let timesDict = times as! [String: String]
                for (key, value) in timesDict {
                    self.availableTimes.append("\(dateString) \(key) - \(value)")
                }
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            self.availableTimes = self.availableTimes.sorted(by: {dateFormatter.date(from: $0.substring(to: $0.index($0.startIndex, offsetBy: 20)))! < dateFormatter.date(from: $1.substring(to: $1.index($1.startIndex, offsetBy: 20)))!})
            self.availableTimesTableView.reloadData()
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "time", for: indexPath)
        cell.textLabel?.text = self.availableTimes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableTimes.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
