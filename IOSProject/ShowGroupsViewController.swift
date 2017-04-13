//
//  ShowGroupsViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/12/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class ShowGroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var groupTableView: UITableView!

    var groups = [String]()
    var currentGroup = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)

        groupTableView.delegate = self
        groupTableView.dataSource = self
        
        let ref = FIRDatabase.database().reference().child("users").child((Main.user?.uid)!).child("groups")
        ref.observeSingleEvent(of: .value, with: { (Snapshot) in
            // Get user value
            let groupDict = Snapshot.value as! NSDictionary
            self.groups = groupDict.allKeys as! [String]
            self.groupTableView.reloadData()
            print (self.groups)
        }) { (error) in
            print(error.localizedDescription)
        }
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.currentGroup = (cell?.textLabel?.text)!
        performSegue(withIdentifier: "groupDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        print (groups[indexPath.row])
        cell.textLabel?.text = groups[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleMenu(_ sender: UIBarButtonItem) {
        print ("clicked toggle menu from groups")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toggleMenu"), object: nil)
    }
    
    @IBAction func createClicked(_ sender: UIBarButtonItem) {
    }
    

    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! GroupDetailViewController
        destination.groupName = self.currentGroup
    }
 

}
