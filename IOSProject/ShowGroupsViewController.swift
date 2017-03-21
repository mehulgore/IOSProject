//
//  ShowGroupsViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/12/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit

class ShowGroupsViewController: UIViewController {
    
    var user: User? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleMenu(_ sender: UIBarButtonItem) {
        print ("clicked toggle menu from groups")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toggleMenu"), object: nil)
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
