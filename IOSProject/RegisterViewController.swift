//
//  RegisterViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/9/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var shouldAllowRegistration = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerClicked(_ sender: UIButton) {
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!
        let password1 = passwordTextField.text!
        let password2 = confirmPasswordTextField.text!
        
        if (firstName == "" || lastName == "" || email == "" ||
            password1 == "" || password2 == "") {
            let alert = UIAlertController(title: "Error", message: "Did not fill out all fields!", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if (password1 != password2) {
            let alert = UIAlertController(title: "Error", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password1, completion:
            { (user:  FIRUser?, error) in
                
                if error != nil {
                    print(error ?? "error")
                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                guard let uid = user?.uid else {
                    return
                }
                
                let ref = FIRDatabase.database().reference()
                let userRef = ref.child("users").child(uid)
                let context = ["firstName": firstName,
                               "lastName": lastName,
                               "email": email]
                userRef.updateChildValues(context)
                
                let userNamesRef = ref.child("userNames")
                let fullName = firstName + " " + lastName
                userNamesRef.updateChildValues([fullName: uid])
                
                self.shouldAllowRegistration = true
                self.performSegue(withIdentifier: "register", sender: self)
                
                Main.user = User(uid: uid, firstName: firstName, lastName: lastName, email: email)
                Main.user?.firstTimeSetup()
        })
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "register") {
            return shouldAllowRegistration
        }
        else {
            return true
        }
    }
    
    @IBAction func userHasAccountBtn(_ sender: Any) {
        //shouldAllowRegistration = true
        //self.performSegue(withIdentifier: "hasAccount", sender: self)
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
