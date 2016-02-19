//
//  LoginViewController.swift
//  Geo Snap
//
//  Created by Christopher Paterson on 02/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: ViewControllerParent {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            self.performSegueWithIdentifier("home", sender: self)
        } else {
            self.view.hidden = false
        }
    }
    
    
    @IBAction func login(sender: UIButton) {
        // Ensure user has entered a username and password.
        if username.text == "" || password.text == "" {
            displayAlert("Error", message: "You must fill in all fields.")
        
        } else {
            // Let the user know something is happening
            displaySpinner(spinner)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents() // Prevent the user from pressing buttons while working.
            
            PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
                // Reenable button presses
                super.stopSpinner(self.spinner)
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if user != nil {
                    // We are logged in
                    // Redirect to home page
                    self.performSegueWithIdentifier("home", sender: self)
                    
                    
                } else {
                    var errorMessage = "Please try again later." // Default error message in case Parse does not give us one.
                    
                    if let loginError = error?.userInfo["error"] as? String {
                        errorMessage = loginError
                    }
                    
                    self.displayAlert("Log in error", message: errorMessage)
                }
            })
            
        }
    }
}