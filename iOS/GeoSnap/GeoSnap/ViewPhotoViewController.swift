//
//  ViewPhotoViewController.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 08/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

// TODO: Clear when user clicks submit. 
// TODO: Prevent user from clicking submit a bunch of times
// TODO: Add comment straight to tableview once the user submits
// TODO: Remove excess cells in tableview
// TODO: Change tableview cell layout a little. Bold the name too.

import UIKit
import Parse

class ViewPhotoViewController: ViewControllerParent, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var creatorUsername: UILabel!
    @IBOutlet weak var postComment: UILabel!
    @IBOutlet weak var postPhoto: UIImageView!
    
    @IBOutlet weak var commentOnPost: UITextField!
    @IBOutlet weak var commentsTableView: UITableView!
    
    var postId: String = String()
    var commentsForPost = [PFObject]()
    
    
    private var post: PFObject = PFObject(className: "Post")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        
        retrievePost()
        retrieveCommentsForPost()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrievePost() {
        let query = PFQuery(className: "Post")
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
    
    func retrieveCommentsForPost() {
        let query = PFQuery(className: "Comment")
        query.includeKey("creator")
        query.whereKey("forPost", equalTo: postId)
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (comments, error) in
            if error == nil && comments != nil {
                self.commentsForPost = comments!
                self.commentsTableView.reloadData()
            } else {
                var errorMessage = "Could not retrieve comments at this time. Please try again." // Defaul error message
                
                if let errorString = error?.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                
                self.displayAlert("Error retrieving comments", message: errorMessage)
            }
        }
    }
    
    @IBAction func submitComment(sender: UIButton) {
        if commentOnPost.text == "" {
            displayAlert("Error submitting comment", message: "Comment box is empty.")
        } else {
            let userComment = PFObject(className: "Comment")
            userComment["comment"] =  commentOnPost.text
            userComment["creator"] = PFUser.currentUser()
            userComment["forPost"] = postId
            
            userComment.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    
                    
                } else {
                    var errorMessage = "Unable to save comment at this time. Please try again later." // Default error message in case Parse does not return one.
                    
                    // error is optional so check exists first
                    if let savePostError = error?.userInfo["error"] as? String {
                        errorMessage = savePostError
                    }
                    
                    self.displayAlert("Error saving post", message: errorMessage)
                }
            }
        }
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsForPost.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postComment", forIndexPath: indexPath) as! CommentTableViewCell
        let comment = commentsForPost[indexPath.row]
        
        cell.commentCreator.text = comment["creator"].username
        cell.comment.text = comment["comment"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("clicked")
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
