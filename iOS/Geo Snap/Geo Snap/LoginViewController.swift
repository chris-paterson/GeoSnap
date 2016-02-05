//
//  LoginViewController.swift
//  Geo Snap
//
//  Created by Christopher Paterson on 02/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: UIButton) {
        // Ensure user has entered a username and password.
        if username.text == "" || password.text == "" {
            let alert = UIAlertController(title: "Error", message: "Username or password is blank.", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUp(sender: UIButton) {
        // Ensure user has entered a username and password
    }
}