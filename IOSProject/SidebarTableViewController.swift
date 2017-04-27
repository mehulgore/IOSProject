//
//  SidebarTableViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/14/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SidebarTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).sidebar = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 5) {
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        else {
            (UIApplication.shared.delegate as! AppDelegate).tabBar!.selectedIndex = indexPath.row - 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 100.0
        }
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.backgroundColor = Main.backgroundColor
        var cell = UITableViewCell()
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)
            cell.backgroundColor = Main.doNotDisturbCellColor
            break
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "inputSchedule", for: indexPath)
            cell.backgroundColor = Main.backgroundColor
            cell.textLabel?.textColor = Main.doNotDisturbCellColor
            break
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "groups", for: indexPath)
            cell.backgroundColor = Main.backgroundColor
            cell.textLabel?.textColor = Main.doNotDisturbCellColor
            break
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "events", for: indexPath)
            cell.backgroundColor = Main.backgroundColor
            cell.textLabel?.textColor = Main.doNotDisturbCellColor
            break
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "settings", for: indexPath)
            cell.backgroundColor = Main.backgroundColor
            cell.textLabel?.textColor = Main.doNotDisturbCellColor
            break
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "signOut", for: indexPath)
            cell.backgroundColor = Main.backgroundColor
            cell.textLabel?.textColor = Main.doNotDisturbCellColor
            break
        default:
            break
        }
        // Configure the cell...
        return cell
    }
    
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
