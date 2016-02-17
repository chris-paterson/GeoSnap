//
//  SharePhotoViewController.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 08/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

// TODO: fix Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen - This may be just an iOS bug.



import UIKit
import Parse

class SharePhotoViewController: ViewControllerParent, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    var imagePicker: UIImagePickerController!
    var userHasTakenPhoto: Bool = false
    var post: PFObject = PFObject(className: "Post")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func takePhoto(sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let image: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        imageView.image = image
        
        userHasTakenPhoto = true
    }
    
    
    @IBAction func share(sender: UIButton) {
        if (userHasTakenPhoto) {
            save()
        } else {
            displayAlert("Error", message: "You must take a photo to share.")
        }
    }
    
    
    func save() {
        displaySpinner()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents() // Prevent the user from pressing buttons while working.
        
        let photoData = UIImageJPEGRepresentation(imageView.image!, 0.7)!
        let coords = locationManager.location?.coordinate
        
        post["comment"] = comment.text
        post["creator"] = PFUser.currentUser()
        post["photo"] = PFFile(name: "image.jpg", data:photoData)
        post["location"] = PFGeoPoint(latitude: coords!.latitude, longitude: coords!.longitude)
        
        post.saveInBackgroundWithBlock { (success, error) -> Void in
            // Re-enable interaction
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            self.spinner.stopAnimating()
            
            if success {
                self.viewPost()
                
            } else {
                var errorMessage = "Please try again later." // Default error message in case Parse does not return one.
                
                // error is optional so check exists first
                if let savePostError = error?.userInfo["error"] as? String {
                    errorMessage = savePostError
                }
                
                self.displayAlert("Error saving post", message: errorMessage)
            }
        }

    }
    
    
    func viewPost() {
        performSegueWithIdentifier("viewPost", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "viewPost") {
            let viewPhotoViewController = (segue.destinationViewController as! ViewPhotoViewController)
            viewPhotoViewController.postId = post.objectId!
        }
    }
    
    
    func resetElements() {
        userHasTakenPhoto = false
        comment.text = ""
        imageView.image = UIImage(named: "polaroid.pdf")
    }
    
    
    @IBAction func cancelShare(sender: UIButton) {
        resetElements()
    }

    
    func displaySpinner() {
        spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        spinner.center = self.view.center
        spinner.activityIndicatorViewStyle = .Gray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.startAnimating()
    }
}
