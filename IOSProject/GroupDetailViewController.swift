//
//  GroupDetailViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/12/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class GroupDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var groupMembersTableView: UITableView!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    var groupName = ""
    var members = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupNameLabel.text = groupName
        
        groupMembersTableView.delegate = self
        groupMembersTableView.dataSource = self
        
        let ref = FIRDatabase.database().reference().child("users").child((Main.user?.uid)!).child("groups").child(self.groupName)
        ref.observeSingleEvent(of: .value, with: { (Snapshot) in
            // Get user value
            let groupDict = Snapshot.value as! NSDictionary
            self.members = groupDict.allKeys as! [String]
            self.groupMembersTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        cell.backgroundColor = Main.backgroundColor
        cell.textLabel?.textColor = Main.textColor
        cell.textLabel?.text = members[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().tintColor = Main.textColor
        UINavigationBar.appearance().barTintColor = Main.doNotDisturbCellColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Main.textColor]
        self.view.backgroundColor = Main.backgroundColor
        self.groupMembersTableView.backgroundColor = Main.backgroundColor
        self.groupNameLabel.textColor = Main.textColor
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
