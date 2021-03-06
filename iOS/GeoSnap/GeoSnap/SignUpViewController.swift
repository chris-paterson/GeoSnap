//
//  SignUpViewController.swift
//  Geo Snap
//
//  Created by Christopher Paterson on 05/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: ViewControllerParent {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var retypePassword: UITextField!
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUp(sender: UIButton) {
        // Ensure user has entered a username and password.
        if username.text == "" || password.text == "" {
            displayAlert("Error", message: "You must fill in all fields.")
            
        } else if password.text != retypePassword.text {
            displayAlert("Error", message: "Passwords do not match.")
        } else {
            // Let the user know something is happening
            displaySpinner(spinner)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents() // Prevent the user from pressing buttons while working.
            
            let user = PFUser()
            user.username = username.text
            user.password = password.text
            
            // Attempt sign up.
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                super.stopSpinner(self.spinner)
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if success {
                    // Sign up successfull
                    self.signInAndRedirect()
                    
                } else {
                    var errorMessage = "Please try again later." // Default error message in case Parse does not return one.
                    
                    // error is optional so check exists first
                    if let signUpError = error?.userInfo["error"] as? String {
                        errorMessage = signUpError
                    }
                    
                    self.displayAlert("Sign up error", message: errorMessage)
                }
            })
        }

    }
    
    func signInAndRedirect() {
        PFUser.logInWithUsernameInBackground(username.text!, password: password.text!)
        self.performSegueWithIdentifier("home", sender: self)
    }
    
    
    @IBAction func returnToLogin(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
