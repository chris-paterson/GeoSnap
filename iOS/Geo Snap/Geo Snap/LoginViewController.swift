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
            displayAlert("Error", message: "You must fill in all fields.")
        
        } else {
            // Let the user know something is happening
            spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            spinner.center = self.view.center
            spinner.activityIndicatorViewStyle = .Gray
            spinner.hidesWhenStopped = true
            view.addSubview(spinner)
            
            spinner.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents() // Prevent the user from pressing buttons while working.
            var errorMessage = "Please try again later."
            
            PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
                // Reenable button presses
                self.spinner.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if user != nil {
                    // We are logged in
                    // Redirect to home page
                    
                    
                } else {
                    if let signUpError = error?.userInfo["error"] as? String {
                        errorMessage = signUpError
                    }
                    
                    self.displayAlert("Sign up error", message: errorMessage)
                }
            })
            
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}