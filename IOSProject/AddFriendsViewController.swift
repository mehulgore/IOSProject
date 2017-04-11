//
//  AddFriendsViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 4/10/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class AddFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate  {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var userArray = [String]()
    var filteredUsers = [String]()
    var userNamesDict = [String: String]()
    var isSearching: Bool = false
    var name = ""
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
//        searchController.dimsBackgroundDuringPresentation = false
//        definesPresentationContext = true
//        tableView.tableHeaderView = searchController.searchBar
        
        let ref = FIRDatabase.database().reference().child("userNames")
        ref.observeSingleEvent(of: .value, with: { (Snapshot) in
            // Get user value
            self.userNamesDict = Snapshot.value as! [String: String]
            self.userArray = Array(self.userNamesDict.keys)
        }) { (error) in
            print(error.localizedDescription)
        }
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
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearching) {
            return self.filteredUsers.count
        }
        return self.userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        if(isSearching){
            cell.textLabel?.text = self.filteredUsers[indexPath.row]
        } else {
            cell.textLabel?.text = self.userArray[indexPath.row];
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.name = (cell?.textLabel?.text)!
        self.uid = self.userNamesDict[name]!
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let groupVC = segue.destination as! CreateGroupViewController
        groupVC.groupUsers[self.name] = self.uid
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
