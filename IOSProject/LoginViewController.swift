//
//  LoginViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/9/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var shouldLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        //let email = emailTextField.text!
        //let password = passwordTextField.text!
        
        let email = "wiz@gmail.com"
        let password = "password"
        
//        if (email == "" || password == "") {
//            let alert = UIAlertController(title: "Error", message: "Did not fill out all fields!", preferredStyle: UIAlertControllerStyle.alert)
//            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
//            }
//            alert.addAction(action)
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            
            if (error != nil) {
                print (error ?? "error")
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.shouldLogin = true
            self.performSegue(withIdentifier: "login", sender: self)
            
                        
            let ref = FIRDatabase.database().reference()
            ref.child("users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                let nodes = snapshot.value as? NSDictionary
                //print(nodes ?? "NODES")
                let firstName = nodes?["firstName"] as? String ?? "default first name"
                let lastName = nodes?["lastName"] as? String ?? "default last name"
                let email = nodes?["email"] as? String ?? "default email"
                
                Main.user = User(uid: (user?.uid)!, firstName: firstName, lastName: lastName, email: email) 
                
                Main.user?.getDoNotDisturbTime(type: "startTime",
                                               completion: { (value) in
                                                Main.user?.clearPast()
                                                Main.user?.fill()
                                                Main.user?.getSched(date: Main.today, completion: { () in
                                                    Main.user?.populateWithDoNotDisturb()
                                                })
                })
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
  
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "login") {
            return self.shouldLogin
        }
        else {
            return true
        }
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
