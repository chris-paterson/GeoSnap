//
//  SecondViewController.swift
//  Geo Snap
//
//  Created by Christopher Paterson on 01/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {
    @IBOutlet weak var loggedInLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUsername: String! = PFUser.currentUser()?.username
        loggedInLabel.text = "You are currently logged in as \(currentUsername)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logOut(sender: UIButton) {
        PFUser.logOutInBackground()
        
        // Redirect back to login screen
        performSegueWithIdentifier("login", sender: self)
    }

}

