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

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    var shouldLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
  
        addBorder(field: emailTextField)
        addBorder(field: passwordTextField)
        
        loginButton.layer.cornerRadius = 15

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
        
        let email = "jj@gmail.com"
        let password = "password"
        
        if (email == "" || password == "") {
            let alert = UIAlertController(title: "Error", message: "Did not fill out all fields!", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        

        
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
            
            
            let ref = FIRDatabase.database().reference()
            ref.child("users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                let nodes = snapshot.value as? NSDictionary
                let firstName = nodes?["firstName"] as? String ?? "default first name"
                let lastName = nodes?["lastName"] as? String ?? "default last name"
                let email = nodes?["email"] as? String ?? "default email"
                
                Main.user = User(uid: (user?.uid)!, firstName: firstName, lastName: lastName, email: email)
                
                Main.user?.getDoNotDisturbTime(type: "startTime",
                                               completion: { (value) in
                                                Main.user?.clearPast()
                                                Main.user?.fill()
                                                Main.user?.getSched(date: Main.today, completion: { () in
                                                    Main.user?.populateWithDoNotDisturb(completion: { () in
                                                        self.shouldLogin = true
                                                        self.performSegue(withIdentifier: "login", sender: self)
                                                    })
                                                })
                })
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func addBorder(field : UITextField){
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: field.frame.size.height - width, width:  field.frame.size.width, height: field.frame.size.height)
        
        border.borderWidth = width
        field.layer.addSublayer(border)
        field.layer.masksToBounds = true
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "login") {
            return self.shouldLogin
        }
        else {
            return true
        }
    }
    
    // From the Apple documentation: Asks the delegate if the text field
    // should process the pressing of the return button.
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 'First Responder' is the same as 'input focus'.
        // We are removing input focus from the text field.
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
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
