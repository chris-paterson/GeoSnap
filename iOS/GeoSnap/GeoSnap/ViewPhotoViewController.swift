//
//  ViewPhotoViewController.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 08/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

// TODO: Click image to make larger.

import UIKit
import Parse

class ViewPhotoViewController: ViewControllerParent {
    
    @IBOutlet weak var creatorUsername: UILabel!
    @IBOutlet weak var postComment: UILabel!
    @IBOutlet weak var postPhoto: UIImageView!

    var postId: String = String()
    
    private var post: PFObject = PFObject(className: "Post")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrievePost()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrievePost() {
        let query = PFQuery(className:"Post")
        query.includeKey("creator")
        query.getObjectInBackgroundWithId(postId) {
            (post: PFObject?, error: NSError?) -> Void in
            if error == nil && post != nil {
                self.post = post!
                self.populateView()
            } else {
                var errorMessage = "Could not retrieve post at this time. Please try again." // Defaul error message
                
                if let errorString = error?.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                
                self.displayAlert("Error retrieving post", message: errorMessage)
            }
        }
    }
    
    func populateView() {
        postComment.text = post["comment"] as? String
        creatorUsername.text = post["creator"].username
    
        retrievePhoto()
    }
    
    func retrievePhoto() {
        let photo = post["photo"] as! PFFile
        
        photo.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.postPhoto.image = UIImage(data:imageData)!
                } else {
                    self.postPhoto.image = UIImage(named: "polaroid.pdf")!
                    self.displayAlert("Error retrieving photo", message: "Unable to retrieve photo at this time. Please try again.")
                }
            }
        }
    }
    
    
    @IBAction func makePhotoFullscreen(sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .blackColor()
        newImageView.contentMode = UIViewContentMode.ScaleToFill
        newImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "dismissFullscreenImage:")
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
}
