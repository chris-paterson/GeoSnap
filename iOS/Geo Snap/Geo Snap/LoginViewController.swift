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
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
            displayAlert("Error", message: "Username and password can not be empty.")
        
        } else {
            // Let the user know something is happening
            spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            spinner.center = self.view.center
            spinner.activityIndicatorViewStyle = .Gray
            spinner.hidesWhenStopped = true
            view.addSubview(spinner)
            
            spinner.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents() // Prevent the user from pressing buttons while working.
            
            var user = PFUser()
            user.username = username.text
            user.password = password.text
            
            // Default error message in case Parse does not return one.
            var errorMessage = "Please try again later."
            
            // Attempt sign up.
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                self.spinner.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if success {
                    // Sign up successfull
                } else {
                    // error is optional so check exists first
                    if let signUpError = error?.userInfo["error"] as? String {
                        errorMessage = signUpError
                    }
                    
                    self.displayAlert("Sign up error", message: errorMessage)
                }
            })
        }
    }
    
    @IBAction func signUp(sender: UIButton) {
        // Ensure user has entered a username and password
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}