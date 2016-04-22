//
//  ViewPhotoViewController.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 08/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

import UIKit
import Parse

class ViewPhotoViewController: ViewControllerParent, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var creatorUsername: UILabel!
    @IBOutlet weak var postComment: UILabel!
    @IBOutlet weak var postPhoto: UIImageView!
    @IBOutlet weak var tags: UILabel!
    
    @IBOutlet weak var commentOnPost: UITextField!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var submitCommentButton: UIButton!
    
    @IBOutlet weak var likeButton: UIImageView!
    
    var postId: String = String()
    var postSource: PostSource?
    var commentsForPost = [PFObject]()
    var photo: UIImage = UIImage(named: "polaroid.pdf")!
    
    var flickrFullImageURL: String = String()
    
    private var post: PFObject = PFObject(className: "Post")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        
        commentsTableView.tableFooterView = UIView() // Hide empty cells in comments table
        commentsTableView.allowsSelection = false;
        
        
        postPhoto.image = photo
        if let source = postSource {
            switch source {
            case .GeoSnap:
                retrievePost()
                
                let longPressRecognizerPhoto = UILongPressGestureRecognizer(target: self, action: #selector(ViewPhotoViewController.longPressPhoto(_:)))
                self.postPhoto.addGestureRecognizer(longPressRecognizerPhoto)
            case.Flickr:
                flickrPopulateView()
            }
        }
        retrieveUserLike()
        retrieveCommentsForPost()
        
        // User is able to report comments but not photos from flickr. 
        let longPressRecognizerComment = UILongPressGestureRecognizer(target: self, action: #selector(ViewPhotoViewController.longPressComment(_:)))
        self.view.addGestureRecognizer(longPressRecognizerComment)
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
        
        let creator: String! = post["creator"].username
        let (date, time) = super.humanReadableDate(post.createdAt!)
        creatorUsername.text = "\(creator) on \(date) at \(time)"
        getFullImageGeo()
        retrieveAndPopulateTags()
    }
    
    
    func getFullImageGeo() {
        if let userImageFile = post["photo"] as? PFFile {
            userImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.postPhoto.image = UIImage(data:imageData)!
                    }
                }
            }
        }
    }
    
    
    func retrieveAndPopulateTags() {
        let query = PFQuery(className: "Tag")
        query.whereKey("forPost", equalTo: postId)
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (tagList, error) in
            if error == nil && tagList != nil {
                var tagString = ""
                for i in 0...tagList!.count {
                    if i == 0 {
                        tagString = "Tags: \(tagList![i]["tag"])"
                    } else {
                        tagString = tagString + " | \(tagList![i]["tag"])"
                    }
                    
                    self.tags.text = tagString
                }
            } else {
                var errorMessage = "Could not retrieve tags at this time. Please try again." // Default error message
                
                if let errorString = error?.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                
                self.displayAlert("Error retrieving tags", message: errorMessage)
            }
        }
    }
    
    
    func flickrPopulateView() {
        creatorUsername.text = "Flickr"
        getFullImageFlickr()
    }
    
    
    func getFullImageFlickr() {
        let url = NSURL(string: flickrFullImageURL)
        let data = NSData(contentsOfURL: url!)
        
        let fullSizePhoto = UIImage(data: data!)!
        postPhoto.image = fullSizePhoto
    }
    
    
    func retrieveUserLike() {
        let query = PFQuery(className: "Like")
        let userId = PFUser.currentUser()!.objectId
        
        query.whereKey("userId", equalTo: userId!)
        query.whereKey("postId", equalTo: postId)
        query.getFirstObjectInBackgroundWithBlock { (like, error) in
            if like != nil {
                self.likeButton.image = UIImage(named: "heart.png")!
                
            } else if (error != nil && error!.code != 101) { // 101 = object not found so we don't need to display a message.
                var errorMessage = "Unable to retrieive like at the moment. Please try again."
                
                if let errorString = error?.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                
                self.displayAlert("Error retrieving like", message: errorMessage)
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
                var errorMessage = "Could not retrieve comments at this time. Please try again." // Default error message
                
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
            // Disable button to prevent posting multiple times
            submitCommentButton.enabled = false
            
            let userComment = PFObject(className: "Comment")
            userComment["comment"] =  commentOnPost.text
            userComment["creator"] = PFUser.currentUser()
            userComment["forPost"] = postId
            
            userComment.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    self.commentOnPost.text = "" // Clear comment box.
                    self.commentOnPost.resignFirstResponder() // Hide the keyboard.
                    
                    // Add comment to table and reload.
                    self.commentsForPost.insert(userComment, atIndex: 0)
                    self.commentsTableView.reloadData()
                    
                } else {
                    var errorMessage = "Unable to save comment at this time. Please try again later." // Default error message in case Parse does not return one.
                    
                    // error is optional so check exists first
                    if let savePostError = error?.userInfo["error"] as? String {
                        errorMessage = savePostError
                    }
                    
                    self.displayAlert("Error saving post", message: errorMessage)
                }
                
                
                self.submitCommentButton.enabled = true
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
    
    
    @IBAction func fullscreenTapped(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("showFullscreen", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFullscreen" {
            let fullscreenPhoto = (segue.destinationViewController as! FullscreenPhotoViewController)
            fullscreenPhoto.photo = photo
        }
    }
    
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        if likeButton.image == UIImage(named: "heart.png")! {
            likeButton.image = UIImage(named: "heartOutline.png")!
            unlike()
        } else {
            likeButton.image = UIImage(named: "heart.png")!
            like()
        }
    }
    
    func unlike() {
        let query = PFQuery(className: "Like")
        let userId = PFUser.currentUser()!.objectId
        
        query.whereKey("userId", equalTo: userId!)
        query.whereKey("postId", equalTo: postId)
        query.getFirstObjectInBackgroundWithBlock { (like, error) in
            if error == nil {
                like!.deleteInBackground();
                
            } else {
                var errorMessage = "Unable to unlike at the moment. Please try again."
                
                if let errorString = error?.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                
                self.displayAlert("Error removing like", message: errorMessage)
            }
        }
    }
    
    func like() {
        let like: PFObject = PFObject(className: "Like")
        
        like["userId"] = PFUser.currentUser()!.objectId
        like["postId"] = postId
        
        like.saveInBackground()
    }
    
    @IBAction func longPressComment(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = longPressGestureRecognizer.locationInView(self.commentsTableView)
            if let indexPath = self.commentsTableView.indexPathForRowAtPoint(touchPoint) {
                
                // your code here, get the row for the indexPath or do whatever you want
                let commentToReport = commentsForPost[indexPath.row]
                showReportDialog(commentToReport)
            }
        }
    }
    
    func longPressPhoto(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            post.objectId = postId
            showReportDialog(post)
        }
    }
        
    
    func showReportDialog(itemToReport: PFObject) {
        let reportAlert = UIAlertController(title: "Report", message: "Are you sure you wish to report this \(itemToReport.parseClassName.lowercaseString) as inappropriate?", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.report(itemToReport)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        reportAlert.addAction(confirmAction)
        reportAlert.addAction(cancelAction)
        
        presentViewController(reportAlert, animated: true, completion: nil)
    }
    
    func report(itemToReport: PFObject) {
        let report = PFObject(className: "Report")
        
        report["class"] = itemToReport.parseClassName
        report["reporter"] = PFUser.currentUser()
        report["reportedItem"] = itemToReport.objectId
        
        report.saveInBackground()
        
        displayAlert("Report Successful", message: "Your report has successfully been sent.")
    }
}
