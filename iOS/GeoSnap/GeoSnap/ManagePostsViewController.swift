//
//  ManagePostsViewController.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 06/04/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

import UIKit
import Parse

class ManagePostsViewController: ViewControllerParent, UITableViewDataSource, UITableViewDelegate {
    
    struct Post {
        var postInformation: PFObject
        var photo: UIImage
    }

    @IBOutlet weak var postTableView: UITableView!
    var userPosts = [Post]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.tableFooterView = UIView() // Hide empty cells in comments table
        populateTableView()
    }
    
    func populateTableView() {
        getPosts()
    }
    
    func getPosts() {
        let query = PFQuery(className: "Post")
        query.includeKey("creator")
        query.whereKey("creator", equalTo: PFUser.currentUser()!)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (posts, error) in
            if let retrievedPosts = posts {
                var index = 0
                for returnedPost in retrievedPosts {
                    let newPost = Post(postInformation: returnedPost, photo: UIImage(named: "polaroid.pdf")!)
                    self.userPosts.append(newPost)
//                    self.postTableView.reloadData()
                    self.getThumbnailForPost(index)
                    index+=1
                }
            } else {
                print(error)
            }
        }
    }
    
    func getThumbnailForPost(index: Int) {
        var post = userPosts[index]
        if let userImageFile = post.postInformation["photo"] as? PFFile {
            userImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        post.photo = UIImage(data:imageData)!
                    } else {
                        post.photo = UIImage(named: "polaroid.pdf")!
                    }
                    
                    self.userPosts[index] = post
                    self.postTableView.reloadData()
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ManagePhotosTableViewCell
        let post = userPosts[indexPath.row]
        
        cell.photoThumbnail.image = UIImage(named: "polaroid.pdf")!
        cell.postComment.text = post.postInformation["comment"] as? String
        
        let (date, time) = super.humanReadableDate(post.postInformation.createdAt!)
        cell.postDate.text = "\(date) at \(time)"

        return cell
    }


    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
