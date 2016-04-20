//
//  SharePhotoViewController.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 08/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

import UIKit
import Parse
import TagListView

class SharePhotoViewController: ViewControllerParent, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TagListViewDelegate {

    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var tagField: UITextField!
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    var imagePicker: UIImagePickerController!
    var userHasTakenPhoto: Bool = false
    var post: PFObject = PFObject(className: "Post")
    var tags = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard when user clicks outside of it.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SharePhotoViewController.dismissKeyboard)))
        
        spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        
        tagListView.delegate = self
        
    }
    
    func dismissKeyboard() {
        comment.resignFirstResponder()
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
        displaySpinner(spinner)
        UIApplication.sharedApplication().beginIgnoringInteractionEvents() // Prevent the user from pressing buttons while working.
        
        let photoData = UIImageJPEGRepresentation(imageView.image!, 0.7)!
        let coords = locationManager.location?.coordinate
        
        post["comment"] = comment.text
        post["creator"] = PFUser.currentUser()
        post["photo"] = PFFile(name: "image.jpg", data:photoData)
        post["location"] = PFGeoPoint(latitude: coords!.latitude, longitude: coords!.longitude)
        
//        if (Reachability.connectedToNetwork()) {
            saveInBackground(post)
//        } else {
//            saveEventually(post)
//        }
    }
    
    func saveInBackground(post: PFObject) {
        post.saveInBackgroundWithBlock { (success, error) -> Void in
            // Re-enable interaction
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            super.stopSpinner(self.spinner)
            
            if success {
                self.saveTags(self.post.objectId!)
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
    
    func saveEventually(post: PFObject) {
        // Re-enable interaction
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        super.stopSpinner(self.spinner)
        
        post.saveEventually()
        let alert = UIAlertController(title: "No network connection",
                                      message: "Photo will be uploaded once network connection has been restored.",
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            self.resetElements()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func saveTags(id: String) {
        var tagsToSave = [PFObject]()
        
        for tagName in tags {
            let tag: PFObject = PFObject(className: "Tag")
            tag["tag"] = tagName
            tag["forPost"] = id
            
            tagsToSave.append(tag)
        }
        
        PFObject.saveAllInBackground(tagsToSave)
    }
    
    
    func viewPost() {
        performSegueWithIdentifier("viewPost", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "viewPost") {
            let viewPhotoViewController = (segue.destinationViewController as! ViewPhotoViewController)
            viewPhotoViewController.postId = post.objectId!
            viewPhotoViewController.postSource = PostSource.GeoSnap
            viewPhotoViewController.photo = imageView.image!
            
            resetElements()
        }
    }

    
    @IBAction func addTag(sender: AnyObject) {
        if tagField.text != "" {
            let tag = tagField.text!
            tags.append(tag)
            tagListView.addTag(tag)
            tagField.text = ""
        } else {
            displayAlert("Unable to add tag", message: "Can not add an empty tag.")
        }
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        tags = tags.filter{$0 != title}
        sender.removeTagView(tagView)
    }
    
    func resetElements() {
        userHasTakenPhoto = false
        comment.text = ""
        imageView.image = UIImage(named: "polaroid.pdf")
        tags.removeAll()
        tagListView.removeAllTags()
    }
    
    
    @IBAction func cancelShare(sender: UIButton) {
        resetElements()
    }

    
    
}
