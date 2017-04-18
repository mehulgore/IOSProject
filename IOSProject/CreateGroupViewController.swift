//
//  CreateGroupViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/12/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CreateGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    lazy var groupUsers: [String: String] = [:]
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var groupTableView: UITableView!
    
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var groupNameTextField: UITextField!
    
    let searchController = UISearchController(searchResultsController: nil)
    var userArray = [String]()
    var filteredUsers = [String]()
    var userNamesDict = [String: String]()
    var isSearching: Bool = false
    var name = ""
    var uid = ""
    var groupName = ""
    var shouldPerform: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groupTableView.delegate = self
        self.groupTableView.dataSource = self
        self.groupTableView.register(UITableViewCell.self, forCellReuseIdentifier: "groupcell")
        
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        self.groupTableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendcell")
        
        self.searchBar.delegate = self
        
        let ref = FIRDatabase.database().reference().child("userNames")
        ref.observeSingleEvent(of: .value, with: { (Snapshot) in
            // Get user value
            self.userNamesDict = Snapshot.value as! [String: String]
            self.userArray = Array(self.userNamesDict.keys)
            if let index = self.userArray.index(of: (Main.user?.fullName)!) {
                self.userArray.remove(at: index)
            }
            self.friendsTableView.reloadData()
            //print (self.userArray)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        //        let ref = FIRDatabase.database().reference().child("users").child((Main.user?.uid)!).child("groups").child(self.groupName).child(self.name)
        // Do any additional setup after loading the view.
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredUsers = self.userArray.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: String.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(self.filteredUsers.count == 0){
            isSearching = false;
        } else {
            isSearching = true;
        }
        self.friendsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.groupTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupcell", for: indexPath)
            let groupNames = Array(groupUsers.keys)
            //print (groupNames)
            cell.textLabel?.text = groupNames[indexPath.row]
            return cell
        }
        else {
            //print (self.userArray)
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendcell", for: indexPath)
            if(isSearching){
                cell.textLabel?.text = self.filteredUsers[indexPath.row]
            } else {
                cell.textLabel?.text = self.userArray[indexPath.row]
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.groupTableView) {
            return groupUsers.count
        }
        else {
            if(isSearching) {
                return self.filteredUsers.count
            }
            return self.userArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.friendsTableView) {
            let cell = tableView.cellForRow(at: indexPath)
            print (cell?.textLabel?.text ?? "")
            self.name = (cell?.textLabel?.text)!
            self.uid = self.userNamesDict[name]!
            groupUsers[self.name] = self.uid
            print (self.groupUsers)
            self.groupTableView.reloadData()
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func addClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func createClicked(_ sender: UIButton) {
        if (groupNameTextField.text == "")
        {
            let alert = UIAlertController(title: "Error", message: "Fill out group name", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        else {
            self.groupName = groupNameTextField.text!
            print (self.name)
            print (self.uid)
            print (self.groupName)
            groupUsers[(Main.user?.fullName)!] = Main.user?.uid
            let ref = FIRDatabase.database().reference().child("users").child((Main.user?.uid)!).child("groups").child(self.groupName)
            ref.setValue(self.groupUsers)
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}
