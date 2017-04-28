//
//  CreateEventViewController.swift
//  IOSProject
//
//  Created by Steven Zhu on 3/24/17.
//  Copyright © 2017 Steven Zhu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class CreateEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var eventNameTextField: UITextField!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var stepper: UIStepper!
    
    var groups = [String]()
    
    var groupName = ""
    
    var didSelect = 0
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var groupTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupTableView.delegate = self
        groupTableView.dataSource = self
        eventNameTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().tintColor = Main.textColor
        UINavigationBar.appearance().barTintColor = Main.doNotDisturbCellColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Main.textColor]
        self.view.backgroundColor = Main.backgroundColor
        self.groupTableView.backgroundColor = Main.backgroundColor
        createButton.backgroundColor = Main.doNotDisturbCellColor
        createButton.layer.cornerRadius = 15
        stepper.tintColor = Main.doNotDisturbCellColor
        
        didSelect = 0
        let ref = FIRDatabase.database().reference().child("users").child((Main.user?.uid)!).child("groups")
        ref.observeSingleEvent(of: .value, with: { (Snapshot) in
            // Get user value
            let groupDict = Snapshot.value as! NSDictionary
            self.groups = groupDict.allKeys as! [String]
            self.groupTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stepperClicked(_ sender: UIStepper) {
        durationLabel.text = "\(stepper.value)"
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.groupName = (cell?.textLabel?.text)!
        didSelect += 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "group", for: indexPath)
        cell.textLabel?.text = groups[indexPath.row]
        cell.textLabel?.textColor = Main.textColor
        cell.backgroundColor = Main.backgroundColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func createClicked(_ sender: UIButton) {
        if (eventNameTextField.text == "")
        {
            let alert = UIAlertController(title: "Error", message: "Fill out event name", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if (didSelect == 0) {
            let alert = UIAlertController(title: "Error", message: "Select a group to compare", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let ref = FIRDatabase.database().reference().child("users").child((Main.user?.uid)!).child("events").child(self.eventNameTextField.text!)
        ref.child("duration").setValue(stepper.value)
        ref.child("group").setValue("\(self.groupName)")
    }
    
    // From the Apple documentation: Asks the delegate if the text field
    // should process the pressing of the return button.
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 'First Responder' is the same as 'input focus'.
        // We are removing input focus from the text field.
        eventNameTextField.resignFirstResponder()
        return true
    }
    
    // Called when the user touches on the main view (outside the UITextField).
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
