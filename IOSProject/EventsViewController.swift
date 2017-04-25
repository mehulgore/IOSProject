//
//  EventsViewController.swift
//  IOSProject
//
//  Created by Steven Zhu on 3/24/17.
//  Copyright © 2017 Steven Zhu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var events = [String]()
    var groupName = ""
    var eventName = ""
    
    @IBOutlet weak var eventTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTableView.delegate = self
        eventTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ref = FIRDatabase.database().reference().child("users").child((Main.user?.uid)!).child("events")
        ref.observeSingleEvent(of: .value, with: { (Snapshot) in
            // Get user value
            guard Snapshot.exists() else {
                self.events = [""]
                return
            }
            
            let dict = Snapshot.value as! NSDictionary
            self.events = dict.allKeys as! [String]
            self.eventTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // pops out nav panel to the left
    @IBAction func toggleMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toggleMenu"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.eventName = (cell?.textLabel?.text)!
        Main.user?.findAvailableTimes(event: self.eventName, completion: { () in
            self.performSegue(withIdentifier: "eventDetail", sender: self)
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath)
        cell.textLabel?.text = events[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "eventDetail") {
            let destination = segue.destination as! EventDetailViewController
            destination.eventName = self.eventName
        }
    }
    
    
}
